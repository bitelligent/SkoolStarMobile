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

  /// Where accounts with a role the mobile app does not cover (client admin,
  /// institute admin, …) are sent. Override per environment with
  /// `--dart-define=WEB_APP_URL=...`.
  static const String webAppUrl = String.fromEnvironment(
    'WEB_APP_URL',
    defaultValue: 'http://194.164.89.239:85',
  );

  static const Duration requestTimeout = Duration(seconds: 30);
}
