import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/core/router/app_router.dart';
import 'package:skoolstar_teacher_module/core/theme/app_theme.dart';
import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/teacher_catalog.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';

class SkoolStarApp extends StatefulWidget {
  const SkoolStarApp({required this.tokenStore, super.key});

  /// Already loaded with any persisted session (see `main`).
  final TokenStore tokenStore;

  @override
  State<SkoolStarApp> createState() => _SkoolStarAppState();
}

class _SkoolStarAppState extends State<SkoolStarApp> {
  final LocalJsonDataSource _dataSource = const LocalJsonDataSource();
  late final ApiClient _apiClient = ApiClient(
    accessToken: () => widget.tokenStore.accessToken,
    // A 401 on an authenticated call means the session is no longer valid
    // (the backend's refresh endpoint can't renew it), so sign out and let the
    // router send the user to login.
    onUnauthorized: () async {
      await _authRepository.logout();
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
  late final GoRouter _router = buildRouter(
    authListenable: _authRepository.signedIn,
  );

  @override
  void dispose() {
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
        // Chat and notifications have no backend yet: they keep using the
        // bundled mock JSON.
        RepositoryProvider<ChatRepository>(
          create: (_) => ChatRepositoryImpl(_dataSource),
        ),
        RepositoryProvider<NotificationsRepository>(
          create: (_) => NotificationsRepositoryImpl(_dataSource),
        ),
      ],
      child: MaterialApp.router(
        title: 'SkoolStar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
        builder: (context, child) {
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.15,
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
