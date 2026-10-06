/// Centralised route name/path constants. Use these instead of raw strings
/// when calling `context.goNamed(...)` or `context.pushNamed(...)`.
class AppRoutes {
  AppRoutes._();

  static const String splash = 'splash';
  static const String splashPath = '/';

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
}
