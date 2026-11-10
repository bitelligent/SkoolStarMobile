import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Tiny async string store for small user preferences (e.g. the selected
/// child). Abstract so tests and the in-memory fallback need no platform.
abstract interface class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> remove(String key);
}

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> remove(String key) async => _values.remove(key);
}

/// Backed by the Keychain / Keystore. Failures never throw: a preference that
/// cannot be saved must not break the screen that set it.
class SecureKeyValueStore implements KeyValueStore {
  SecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on Object {
      // Best effort.
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _storage.delete(key: key);
    } on Object {
      // Best effort.
    }
  }
}
