import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_top_bar.dart';
import 'package:skoolstar_teacher_module/core/widgets/shell_scaffold.dart';
import 'package:skoolstar_teacher_module/data/models/auth/app_role.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_session.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/assignment_submission_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_progress_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/guardian_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/leave_repository.dart';
import 'package:skoolstar_teacher_module/features/auth/view/login_screen.dart';
import 'package:skoolstar_teacher_module/features/auth/view/role_selection_screen.dart';
import 'package:skoolstar_teacher_module/features/chat/chat_perspective.dart';
import 'package:skoolstar_teacher_module/features/chat/view/chat_screen.dart';
import 'package:skoolstar_teacher_module/features/chat/view/direct_chat_screen.dart';
import 'package:skoolstar_teacher_module/features/chat/view/feedback_chat_screen.dart';
import 'package:skoolstar_teacher_module/features/dashboard/view/dashboard_screen.dart';
import 'package:skoolstar_teacher_module/features/notifications/view/notifications_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/attendance/parent_attendance_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/attendance/parent_attendance_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/leave/parent_leave_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/leave/parent_leave_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/profile/parent_profile_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/profile/parent_profile_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/session_detail/parent_session_detail_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/shell/parent_shell.dart';
import 'package:skoolstar_teacher_module/features/profile/view/profile_screen.dart';
import 'package:skoolstar_teacher_module/features/schedule/view/schedule_screen.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/session_detail_screen.dart';
import 'package:skoolstar_teacher_module/features/splash/view/splash_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _dashboardKey = GlobalKey<NavigatorState>();
final _scheduleKey = GlobalKey<NavigatorState>();
final _chatKey = GlobalKey<NavigatorState>();
final _profileKey = GlobalKey<NavigatorState>();

final _parentHomeKey = GlobalKey<NavigatorState>();
final _parentAttendanceKey = GlobalKey<NavigatorState>();
final _parentAssignmentsKey = GlobalKey<NavigatorState>();
final _parentChatKey = GlobalKey<NavigatorState>();
final _parentProfileKey = GlobalKey<NavigatorState>();

/// Pure redirect rules (kept free of widgets so they can be unit tested).
///
/// * signed out → login
/// * signed in, no usable role chosen → role list
/// * signed in with a role → that role's module; the other module's URLs and
///   the login screen are redirected away
String? authRedirect(AuthSession session, String location) {
  if (location == AppRoutes.splashPath) return null;
  final onLogin = location == AppRoutes.loginPath;
  final onSelectRole = location == AppRoutes.selectRolePath;

  if (!session.signedIn) return onLogin ? null : AppRoutes.loginPath;

  final role = session.role;
  if (role == null) return onSelectRole ? null : AppRoutes.selectRolePath;

  if (onLogin) return AppRoutes.homeFor(role);
  if (onSelectRole) return null; // "Switch role" from inside a module
  final inParent = AppRoutes.isParentPath(location);
  if (role == AppRole.parent && !inParent) return AppRoutes.parentHomePath;
  if (role == AppRole.teacher && inParent) return AppRoutes.dashboardPath;
  return null;
}

/// [authListenable] drives re-evaluation of `GoRouter.redirect` so signing in
/// or out (or a session expiring) moves the user to the right place from
/// anywhere in the app.
GoRouter buildRouter({
  required ValueListenable<AuthSession> session,
  required ChatRepository parentChatRepository,
}) {
  // Parent chat reuses the teacher chat screens with mock parent data.
  Widget parentChat(Widget child) => ChatPerspectiveScope(
    perspective: ChatPerspective.parent,
    child: RepositoryProvider<ChatRepository>.value(
      value: parentChatRepository,
      child: child,
    ),
  );

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splashPath,
    refreshListenable: session,
    redirect: (context, state) =>
        authRedirect(session.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.selectRolePath,
        name: AppRoutes.selectRole,
        builder: (_, _) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentNotificationsPath,
        name: AppRoutes.parentNotifications,
        parentNavigatorKey: _rootKey,
        // Opening a notification needs the parent's chat repository and
        // routes.
        builder: (_, _) => parentChat(const NotificationsScreen()),
      ),
      GoRoute(
        path: AppRoutes.parentProgressPath,
        name: AppRoutes.parentProgress,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => parentChat(
          BlocProvider(
            create: (ctx) => ParentProgressCubit(
              children: ctx.read<ChildrenCubit>(),
              attendance: ctx.read<ChildAttendanceRepository>(),
              assignments: ctx.read<ChildAssignmentsRepository>(),
              progress: ctx.read<ChildProgressRepository>(),
              chat: ctx.read<ChatRepository>(),
              handedIn: ctx.read<AssignmentSubmissionRepository>().submitted,
            )..load(),
            child: const ParentProgressScreen(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.parentLeavePath,
        name: AppRoutes.parentLeave,
        parentNavigatorKey: _rootKey,
        builder: (context, _) => BlocProvider(
          create: (ctx) => ParentLeaveCubit(
            children: ctx.read<ChildrenCubit>(),
            repository: ctx.read<LeaveRepository>(),
          )..load(),
          child: const ParentLeaveScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.parentSessionDetailPath,
        name: AppRoutes.parentSessionDetail,
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final child = context.read<ChildrenCubit>().state.selectedChild;
          if (child == null) {
            return const Scaffold(
              appBar: AppTopBar(title: 'Session'),
              body: AppEmptyState(
                icon: Icons.child_care_rounded,
                title: 'No child selected',
                subtitle: 'Go back and choose a child first.',
              ),
            );
          }
          return ParentSessionDetailScreen(
            child: child,
            sessionId: state.pathParameters['id']!,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.parentFeedbackChatPath,
        name: AppRoutes.parentFeedbackChat,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => parentChat(
          FeedbackChatScreen(threadId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: AppRoutes.parentDirectChatPath,
        name: AppRoutes.parentDirectChat,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => parentChat(
          DirectChatScreen(threadId: state.pathParameters['id']!),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ParentShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _parentHomeKey,
            routes: [
              GoRoute(
                path: AppRoutes.parentHomePath,
                name: AppRoutes.parentHome,
                builder: (context, _) => BlocProvider(
                  create: (ctx) => ParentHomeCubit(
                    children: ctx.read<ChildrenCubit>(),
                    schedule: ctx.read<ChildScheduleRepository>(),
                    assignments: ctx.read<ChildAssignmentsRepository>(),
                    attendance: ctx.read<ChildAttendanceRepository>(),
                    handedIn: ctx
                        .read<AssignmentSubmissionRepository>()
                        .submitted,
                  )..load(),
                  child: const ParentHomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _parentAttendanceKey,
            routes: [
              GoRoute(
                path: AppRoutes.parentAttendancePath,
                name: AppRoutes.parentAttendance,
                builder: (context, _) => BlocProvider(
                  create: (ctx) => ParentAttendanceCubit(
                    children: ctx.read<ChildrenCubit>(),
                    repository: ctx.read<ChildAttendanceRepository>(),
                  )..load(),
                  child: const ParentAttendanceScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _parentAssignmentsKey,
            routes: [
              GoRoute(
                path: AppRoutes.parentAssignmentsPath,
                name: AppRoutes.parentAssignments,
                builder: (context, _) => BlocProvider(
                  create: (ctx) => ParentAssignmentsCubit(
                    children: ctx.read<ChildrenCubit>(),
                    repository: ctx.read<ChildAssignmentsRepository>(),
                  )..load(),
                  child: const ParentAssignmentsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _parentChatKey,
            routes: [
              GoRoute(
                path: AppRoutes.parentChatPath,
                name: AppRoutes.parentChat,
                builder: (context, _) => parentChat(const ChatScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _parentProfileKey,
            routes: [
              GoRoute(
                path: AppRoutes.parentProfilePath,
                name: AppRoutes.parentProfile,
                builder: (context, _) => BlocProvider(
                  create: (ctx) => ParentProfileCubit(
                    children: ctx.read<ChildrenCubit>(),
                    repository: ctx.read<GuardianRepository>(),
                  )..load(),
                  child: const ParentProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.notificationsPath,
        name: AppRoutes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/session/:id',
        name: AppRoutes.sessionDetail,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            SessionDetailScreen(sessionId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.feedbackChatPath,
        name: AppRoutes.feedbackChat,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            FeedbackChatScreen(threadId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.directChatPath,
        name: AppRoutes.directChat,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            DirectChatScreen(threadId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardKey,
            routes: [
              GoRoute(
                path: AppRoutes.dashboardPath,
                name: AppRoutes.dashboard,
                builder: (_, _) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _scheduleKey,
            routes: [
              GoRoute(
                path: AppRoutes.schedulePath,
                name: AppRoutes.schedule,
                builder: (_, _) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _chatKey,
            routes: [
              GoRoute(
                path: AppRoutes.chatPath,
                name: AppRoutes.chat,
                builder: (_, _) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profilePath,
                name: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
