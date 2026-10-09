import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';

/// Persists tokens in the iOS Keychain / Android Keystore-backed storage.
///
/// Reads are served from memory so `TokenStore.accessToken` stays
/// synchronous for `ApiClient`; call [load] once at startup.
class SecureTokenStore implements TokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessKey = 'auth.access_token';
  static const _refreshKey = 'auth.refresh_token';
  static const _contextKey = 'auth.context';

  final FlutterSecureStorage _storage;
  String? _accessToken;
  String? _refreshToken;
  String? _contextJson;

  @override
  String? get contextJson => _contextJson;

  @override
  String? get accessToken => _accessToken;

  @override
  String? get refreshToken => _refreshToken;

  /// Restores tokens saved by a previous run. A storage failure (e.g. a
  /// corrupted keystore) is treated as "signed out" rather than crashing.
  Future<void> load() async {
    try {
      _accessToken = await _storage.read(key: _accessKey);
      _refreshToken = await _storage.read(key: _refreshKey);
      _contextJson = await _storage.read(key: _contextKey);
    } on Object {
      await clear();
    }
  }

  @override
  Future<void> save({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken ?? _refreshToken;
    await _storage.write(key: _accessKey, value: _accessToken);
    if (_refreshToken != null) {
      await _storage.write(key: _refreshKey, value: _refreshToken);
    }
  }

  @override
  Future<void> saveContext(String? json) async {
    _contextJson = json;
    try {
      if (json == null) {
        await _storage.delete(key: _contextKey);
      } else {
        await _storage.write(key: _contextKey, value: json);
      }
    } on Object {
      // Context is re-fetched from `my-contexts` if it can't be restored.
    }
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    _contextJson = null;
    try {
      await _storage.delete(key: _contextKey);
      await _storage.delete(key: _accessKey);
      await _storage.delete(key: _refreshKey);
    } on Object {
      // Memory is already cleared; nothing more we can do.
    }
  }
}
