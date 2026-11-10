/// Holds the current auth tokens. The interface lets us swap the in-memory
/// implementation for a `flutter_secure_storage`-backed one without touching
/// `ApiClient` or repositories.
abstract interface class TokenStore {
  String? get accessToken;
  String? get refreshToken;

  /// JSON of the active `AuthContext` (role + institute), persisted with the
  /// tokens so a cold start knows the staff/institute without a network call.
  String? get contextJson;

  /// JSON list of every context the account can use (for role switching).
  String? get contextsJson;

  Future<void> save({required String accessToken, String? refreshToken});
  Future<void> saveContext(String? json);
  Future<void> saveContexts(String? json);
  Future<void> clear();
}

class InMemoryTokenStore implements TokenStore {
  String? _accessToken;
  String? _refreshToken;
  String? _contextJson;
  String? _contextsJson;

  @override
  String? get contextJson => _contextJson;

  @override
  String? get contextsJson => _contextsJson;

  @override
  Future<void> saveContexts(String? json) async => _contextsJson = json;

  @override
  Future<void> saveContext(String? json) async => _contextJson = json;

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  @override
  Future<void> save({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken ?? _refreshToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _contextJson = null;
    _contextsJson = null;
  }
}
