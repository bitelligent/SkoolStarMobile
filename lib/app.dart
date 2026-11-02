import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/config/app_config.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/core/router/app_router.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_engine.dart';
import 'package:skoolstar_teacher_module/core/utils/stream_merge.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_scope.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/core/theme/app_theme.dart';
import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/branding.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/branding_repository.dart';
import 'package:skoolstar_teacher_module/data/realtime/chat_realtime.dart';
import 'package:skoolstar_teacher_module/data/repositories/api_chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/teacher_catalog.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/children_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/guardian_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/branding/cubit/brand_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

class SkoolStarApp extends StatefulWidget {
  const SkoolStarApp({
    required this.tokenStore,
    this.keyValueStore,
    this.initialBranding,
    this.httpClient,
    super.key,
  });

  /// Already loaded with any persisted session (see `main`).
  final TokenStore tokenStore;

  /// Small-preferences store (defaults to the secure store).
  final KeyValueStore? keyValueStore;

  /// Branding cached by the previous run (see `main`).
  final Branding? initialBranding;

  /// Overrides the HTTP client (tests).
  final http.Client? httpClient;

  @override
  State<SkoolStarApp> createState() => _SkoolStarAppState();
}

class _SkoolStarAppState extends State<SkoolStarApp>
    with WidgetsBindingObserver {
  final LocalJsonDataSource _dataSource = const LocalJsonDataSource();
  late final ApiClient _apiClient = ApiClient(
    httpClient: widget.httpClient,
    accessToken: () => widget.tokenStore.accessToken,
    // A 401 on an authenticated call means the session is no longer valid
    // (the backend's refresh endpoint can't renew it), so sign out and let the
    // router send the user to login.
    // Several requests are usually in flight when the token dies; sign out
    // once, not once per response.
    onUnauthorized: () async {
      if (_authRepository.isSignedIn) await _authRepository.logout();
      return false;
    },
  );
  late final AuthRepository _authRepository = AuthRepositoryImpl(
    apiClient: _apiClient,
    tokenStore: widget.tokenStore,
  );
  late final TeacherCatalogSource _catalog = TeacherCatalogSource(
    apiClient: _apiClient,
    authRepository: _authRepository,
  );
  // Parent module data.
  late final ChildrenRepository _childrenRepository = ChildrenRepositoryImpl(
    apiClient: _apiClient,
    authRepository: _authRepository,
  );
  // Chat: REST + SignalR. One realtime link shared by both perspectives.
  late final ChatRealtime _realtime = ChatRealtime.forServer(
    baseUrl: AppConfig.apiBaseUrl,
    accessToken: () => widget.tokenStore.accessToken,
  );
  late final ApiChatRepository _teacherChatRepository = ApiChatRepository(
    apiClient: _apiClient,
    realtime: _realtime,
    asParent: false,
  );
  late final ApiChatRepository _parentChatRepository = ApiChatRepository(
    apiClient: _apiClient,
    realtime: _realtime,
    asParent: true,
  );
  late final KeyValueStore _keyValueStore =
      widget.keyValueStore ?? SecureKeyValueStore();
  // White-label branding: refreshed on every login / institute switch.
  late final BrandCubit _brandCubit = BrandCubit(
    repository: BrandingRepositoryImpl(
      apiClient: _apiClient,
      store: _keyValueStore,
    ),
    auth: _authRepository,
    initial: widget.initialBranding,
  );
  // Voice dictation is only offered where the OS has a recogniser.
  late final DictationEngine? _dictation =
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS
      ? SpeechToTextEngine()
      : null;
  // In-app notifications (bell badge + list), fed by the API and nudged by
  // chat events so a new message shows on the badge quickly.
  late final NotificationsRepository _notificationsRepository =
      NotificationsRepositoryImpl(_apiClient);
  late final NotificationsCubit _notificationsCubit = NotificationsCubit(
    repository: _notificationsRepository,
    auth: _authRepository,
    events: mergeStreams([
      _teacherChatRepository.events,
      _parentChatRepository.events,
    ]),
  );
  late final GoRouter _router = buildRouter(
    session: _authRepository.session,
    parentChatRepository: _parentChatRepository,
  );

  String? _realtimeKey;
  Future<void> _realtimeChain = Future.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authRepository.session.addListener(_syncRealtime);
    _syncRealtime();
  }

  /// Keeps the chat link tied to the active role: connect when a teacher /
  /// parent role is active, reconnect (new token) when it changes, close on
  /// sign-out.
  void _syncRealtime() {
    final session = _authRepository.session.value;
    final key = session.role != null ? session.contextKey : null;
    if (key == _realtimeKey) return;
    _realtimeKey = key;
    _realtimeChain = _realtimeChain.then((_) async {
      await _realtime.stop();
      if (mounted && _realtimeKey == key && key != null) _realtime.start();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _realtimeKey != null) {
      _realtime.onAppResumed();
      _notificationsCubit.onResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authRepository.session.removeListener(_syncRealtime);
    _teacherChatRepository.dispose();
    _parentChatRepository.dispose();
    unawaited(_realtime.dispose());
    unawaited(_notificationsCubit.close());
    unawaited(_brandCubit.close());
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<InstituteRepository>(
          create: (_) => InstituteRepositoryImpl(_authRepository),
        ),
        RepositoryProvider<UserRepository>(
          create: (_) => UserRepositoryImpl(
            apiClient: _apiClient,
            authRepository: _authRepository,
          ),
        ),
        RepositoryProvider<SessionRepository>(
          create: (_) => SessionRepositoryImpl(
            apiClient: _apiClient,
            authRepository: _authRepository,
          ),
        ),
        RepositoryProvider<ClassRepository>(
          create: (_) => ClassRepositoryImpl(_catalog),
        ),
        RepositoryProvider<SubjectRepository>(
          create: (_) => SubjectRepositoryImpl(_catalog),
        ),
        RepositoryProvider<AttendanceRepository>(
          create: (_) => AttendanceRepositoryImpl(_apiClient),
        ),
        RepositoryProvider<HomeworkRepository>(
          create: (_) => HomeworkRepositoryImpl(_apiClient),
        ),
        RepositoryProvider<FeedbackRepository>(
          create: (_) => FeedbackRepositoryImpl(_apiClient),
        ),
        // Parent routes override this with the parent-perspective instance
        // (see `buildRouter`).
        RepositoryProvider<ChatRepository>.value(
          value: _teacherChatRepository,
        ),
        // Notifications have no backend yet: bundled mock JSON.
        RepositoryProvider<NotificationsRepository>.value(
          value: _notificationsRepository,
        ),
        // ── Parent module ──
        RepositoryProvider<ChildrenRepository>.value(
          value: _childrenRepository,
        ),
        RepositoryProvider<ChildScheduleRepository>(
          create: (_) => ChildScheduleRepositoryImpl(
            apiClient: _apiClient,
            authRepository: _authRepository,
          ),
        ),
        RepositoryProvider<ChildAttendanceRepository>(
          create: (_) => ChildAttendanceRepositoryImpl(
            apiClient: _apiClient,
            authRepository: _authRepository,
          ),
        ),
        RepositoryProvider<ChildAssignmentsRepository>(
          create: (_) => ChildAssignmentsRepositoryImpl(
            apiClient: _apiClient,
            authRepository: _authRepository,
          ),
        ),
        RepositoryProvider<GuardianRepository>(
          create: (_) => GuardianRepositoryImpl(
            apiClient: _apiClient,
            authRepository: _authRepository,
          ),
        ),
      ],
      // Above the router so the parent shell, its tabs and pushed screens
      // all share one "selected child".
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BrandCubit>.value(value: _brandCubit),
          BlocProvider<NotificationsCubit>.value(value: _notificationsCubit),
          BlocProvider<ChildrenCubit>(
            create: (_) => ChildrenCubit(
              repository: _childrenRepository,
              store: _keyValueStore,
              auth: _authRepository,
            ),
          ),
        ],
        child: BlocBuilder<BrandCubit, BrandState>(
          buildWhen: (a, b) => a.colors != b.colors || a.appName != b.appName,
          builder: (context, brand) => MaterialApp.router(
            title: brand.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(brand.colors),
            routerConfig: _router,
            builder: (context, child) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: mq.textScaler.clamp(
                    minScaleFactor: 0.85,
                    maxScaleFactor: 1.1,
                  ),
                ),
                child: DictationScope(engine: _dictation, child: child!),
              );
            },
          ),
        ),
      ),
    );
  }
}
