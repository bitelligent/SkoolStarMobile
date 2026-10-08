/// Holds the current auth tokens. The interface lets us swap the in-memory
/// implementation for a `flutter_secure_storage`-backed one without touching
/// `ApiClient` or repositories.
abstract interface class TokenStore {
  String? get accessToken;
  String? get refreshToken;

  Future<void> save({required String accessToken, String? refreshToken});
  Future<void> clear();
}

class InMemoryTokenStore implements TokenStore {
  String? _accessToken;
  String? _refreshToken;

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
  }
}
