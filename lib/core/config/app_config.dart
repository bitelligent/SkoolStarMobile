/// Build-time configuration.
///
/// Override per environment without touching code:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
class AppConfig {
  AppConfig._();

  /// Origin of the SkoolStar API (no trailing slash, no `/api` suffix).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://194.164.89.239:86',
  );

  static const Duration requestTimeout = Duration(seconds: 30);
}
