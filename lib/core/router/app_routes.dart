import 'package:skoolstar_teacher_module/data/models/auth/app_role.dart';

/// Centralised route name/path constants. Use these instead of raw strings
/// when calling `context.goNamed(...)` or `context.pushNamed(...)`.
class AppRoutes {
  AppRoutes._();

  static const String splash = 'splash';
  static const String splashPath = '/';

  static const String login = 'login';
  static const String loginPath = '/login';

  // Bottom-nav shell tabs (match the web product's structure: Dashboard,
  // My Schedule, Profile).
  static const String dashboard = 'dashboard';
  static const String dashboardPath = '/dashboard';

  static const String schedule = 'schedule';
  static const String schedulePath = '/schedule';

  static const String chat = 'chat';
  static const String chatPath = '/chat';

  static const String feedbackChat = 'feedbackChat';
  static const String feedbackChatPath = '/chat/feedback/:id';

  static const String directChat = 'directChat';
  static const String directChatPath = '/chat/direct/:id';

  static const String profile = 'profile';
  static const String profilePath = '/profile';

  // Pushed routes
  static const String sessionDetail = 'sessionDetail';
  static const String sessionDetailPath = 'session/:id';

  static const String notifications = 'notifications';
  static const String notificationsPath = '/notifications';

  // Role selection (post-login and Profile → Switch role).
  static const String selectRole = 'selectRole';
  static const String selectRolePath = '/select-role';

  // Parent module
  static const String parentHome = 'parentHome';
  static const String parentHomePath = '/parent/home';

  static const String parentAttendance = 'parentAttendance';
  static const String parentAttendancePath = '/parent/attendance';

  static const String parentAssignments = 'parentAssignments';
  static const String parentAssignmentsPath = '/parent/assignments';

  static const String parentChat = 'parentChat';
  static const String parentChatPath = '/parent/chat';

  static const String parentProfile = 'parentProfile';
  static const String parentProfilePath = '/parent/profile';

  static const String parentSessionDetail = 'parentSessionDetail';
  static const String parentSessionDetailPath = '/parent/session/:id';

  static const String parentFeedbackChat = 'parentFeedbackChat';
  static const String parentFeedbackChatPath = '/parent/chat/feedback/:id';

  static const String parentDirectChat = 'parentDirectChat';
  static const String parentDirectChatPath = '/parent/chat/direct/:id';

  static const String parentNotifications = 'parentNotifications';
  static const String parentNotificationsPath = '/parent/notifications';

  /// Landing path of each module.
  static String homeFor(AppRole role) =>
      role == AppRole.parent ? parentHomePath : dashboardPath;

  static bool isParentPath(String location) =>
      location == '/parent' || location.startsWith('/parent/');
}
