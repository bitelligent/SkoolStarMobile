import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/widgets/shell_scaffold.dart';
import 'package:skoolstar_teacher_module/features/chat/view/chat_screen.dart';
import 'package:skoolstar_teacher_module/features/chat/view/direct_chat_screen.dart';
import 'package:skoolstar_teacher_module/features/chat/view/feedback_chat_screen.dart';
import 'package:skoolstar_teacher_module/features/dashboard/view/dashboard_screen.dart';
import 'package:skoolstar_teacher_module/features/notifications/view/notifications_screen.dart';
import 'package:skoolstar_teacher_module/features/profile/view/profile_screen.dart';
import 'package:skoolstar_teacher_module/features/schedule/view/schedule_screen.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/session_detail_screen.dart';
import 'package:skoolstar_teacher_module/features/splash/view/splash_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _dashboardKey = GlobalKey<NavigatorState>();
final _scheduleKey = GlobalKey<NavigatorState>();
final _chatKey = GlobalKey<NavigatorState>();
final _profileKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splashPath,
    routes: [
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationsPath,
        name: AppRoutes.notifications,
        parentNavigatorKey: _rootKey,
        builder: (_, __) => const NotificationsScreen(),
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
                builder: (_, __) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _scheduleKey,
            routes: [
              GoRoute(
                path: AppRoutes.schedulePath,
                name: AppRoutes.schedule,
                builder: (_, __) => const ScheduleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _chatKey,
            routes: [
              GoRoute(
                path: AppRoutes.chatPath,
                name: AppRoutes.chat,
                builder: (_, __) => const ChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: AppRoutes.profilePath,
                name: AppRoutes.profile,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
