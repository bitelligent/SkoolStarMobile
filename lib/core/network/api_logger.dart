import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Debug-only HTTP logging with secrets redacted.
class ApiLogger {
  const ApiLogger();

  static const _sensitiveKeys = {
    'password',
    'currentpassword',
    'newpassword',
    'confirmnewpassword',
    'oldpassword',
    'accesstoken',
    'refreshtoken',
    'token',
    'authorization',
  };

  void request(String method, Uri url, Object? body) {
    if (!kDebugMode) return;
    developer.log(
      '→ $method $url${body == null ? '' : '\n${_pretty(body)}'}',
      name: 'API',
    );
  }

  void response(String method, Uri url, int status, String body) {
    if (!kDebugMode) return;
    Object? decoded;
    try {
      decoded = body.isEmpty ? null : jsonDecode(body);
    } on FormatException {
      decoded = body;
    }
    developer.log(
      '← $status $method $url${decoded == null ? '' : '\n${_pretty(decoded)}'}',
      name: 'API',
    );
  }

  void error(String method, Uri url, Object error) {
    if (!kDebugMode) return;
    developer.log('✗ $method $url → $error', name: 'API');
  }

  String _pretty(Object value) =>
      const JsonEncoder.withIndent('  ').convert(_redact(value));

  Object? _redact(Object? value) {
    if (value is Map) {
      return {
        for (final e in value.entries)
          e.key: _sensitiveKeys.contains('${e.key}'.toLowerCase())
              ? '***'
              : _redact(e.value),
      };
    }
    if (value is List) return value.map(_redact).toList();
    return value;
  }
}
