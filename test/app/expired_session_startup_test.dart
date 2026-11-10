import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/app.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';

/// Cold start with a saved session the server no longer accepts. Regression
/// for an ANR: the first 401 signed the user out and left the dashboard while
/// its other requests were still in flight; each late response then threw an
/// uncaught "Cannot emit new states after calling close", which pauses a
/// debugger and freezes the app.
Future<InMemoryTokenStore> _savedSession() async {
  final tokens = InMemoryTokenStore();
  await tokens.save(accessToken: 'not-a-readable-jwt');
  await tokens.saveContext(
    jsonEncode(
      const AuthContext(
        contextKey: 'Teacher:3',
        role: 'Teacher',
        instituteId: 8,
        staffId: 3,
      ).toJson(),
    ),
  );
  return tokens;
}

void main() {
  testWidgets('401 on every request: signs out once, lands on login, '
      'no uncaught errors', (tester) async {
    final uncaught = <Object>[];
    final previous = FlutterError.onError;
    FlutterError.onError = (d) => uncaught.add(d.exception);

    final tokens = await _savedSession();
    final calls = <String>[];
    final client = MockClient((r) async {
      calls.add('${r.method} ${r.url.path}');
      // Slow server: the dashboard fires all its requests before the first
      // 401 comes back (as on the device).
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      return http.Response(
        jsonEncode({'message': 'Unauthorized'}),
        401,
        headers: {'content-type': 'application/json'},
      );
    });

    await runZonedGuarded(
      () async {
        await tester.pumpWidget(
          SkoolStarApp(tokenStore: tokens, httpClient: client),
        );
        for (var i = 0; i < 120; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      },
      (e, st) => uncaught.add('zone: $e\n$st'),
    );

    final location = GoRouter.of(
      tester.element(find.byType(Navigator).first),
    ).state.matchedLocation;
    FlutterError.onError = previous;

    // The dashboard really did start its burst of requests.
    expect(calls.length, greaterThan(4), reason: '$calls');
    expect(location, '/login');
    expect(tokens.accessToken, isNull);
    expect(uncaught, isEmpty);
  });
}
