import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/jwt.dart';

String _jwt(Map<String, Object?> payload) {
  String enc(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${enc({'alg': 'HS256'})}.${enc(payload)}.sig';
}

void main() {
  final now = DateTime.utc(2026, 10, 19, 12);
  int secs(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;

  test('reads the exp claim', () {
    final exp = now.add(const Duration(hours: 1));
    expect(jwtExpiry(_jwt({'exp': secs(exp)})), exp);
  });

  test('expired, valid, and about-to-expire tokens', () {
    expect(
      isJwtExpired(
        _jwt({'exp': secs(now.subtract(const Duration(days: 4)))}),
        now: now,
      ),
      isTrue,
    );
    expect(
      isJwtExpired(
        _jwt({'exp': secs(now.add(const Duration(hours: 5)))}),
        now: now,
      ),
      isFalse,
    );
    // Inside the 30 s safety margin counts as expired.
    expect(
      isJwtExpired(
        _jwt({'exp': secs(now.add(const Duration(seconds: 10)))}),
        now: now,
      ),
      isTrue,
    );
  });

  test('unreadable tokens are left for the server to judge', () {
    expect(isJwtExpired(null), isFalse);
    expect(isJwtExpired(''), isFalse);
    expect(isJwtExpired('opaque-token'), isFalse);
    expect(isJwtExpired('a.b.c'), isFalse);
    expect(isJwtExpired(_jwt({'sub': 'x'})), isFalse); // no exp
    expect(jwtExpiry('a.!!!.c'), isNull);
  });
}
