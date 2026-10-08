import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

void main() {
  late InMemoryTokenStore tokens;

  AuthRepository build(MockClient mock) {
    tokens = InMemoryTokenStore();
    return AuthRepositoryImpl(
      apiClient: ApiClient(baseUrl: 'https://api.test', httpClient: mock),
      tokenStore: tokens,
    );
  }

  test('login posts credentials and stores tokens', () async {
    late http.Request captured;
    final repo = build(
      MockClient((r) async {
        captured = r;
        return http.Response(
          jsonEncode({
            'accessToken': 'at',
            'refreshToken': 'rt',
            'activeContextKey': 'ctx1',
          }),
          200,
        );
      }),
    );

    final res = await repo.login(email: ' a@b.com ', password: 'pw');

    expect(captured.url.path, '/api/Users/enhanced-login');
    expect(jsonDecode(captured.body), {'email': 'a@b.com', 'password': 'pw'});
    expect(res.activeContextKey, 'ctx1');
    expect(tokens.accessToken, 'at');
    expect(tokens.refreshToken, 'rt');
  });

  test('does not store a token when context selection is required', () async {
    final repo = build(
      MockClient(
        (_) async => http.Response(
          jsonEncode({
            'requiresContextSelection': true,
            'availableContexts': [
              {'contextKey': 'c1', 'role': 'Teacher'},
            ],
          }),
          200,
        ),
      ),
    );

    final res = await repo.login(email: 'a@b.com', password: 'pw');

    expect(res.requiresContextSelection, isTrue);
    expect(res.availableContexts, hasLength(1));
    expect(tokens.accessToken, isNull);
  });

  test('wrong credentials surface as UnauthorizedException', () async {
    final repo = build(MockClient((_) async => http.Response('', 401)));

    await expectLater(
      repo.login(email: 'a@b.com', password: 'bad'),
      throwsA(isA<UnauthorizedException>()),
    );
    expect(tokens.accessToken, isNull);
  });

  test('non-object body is a ParseException', () async {
    final repo = build(MockClient((_) async => http.Response('[]', 200)));

    await expectLater(
      repo.login(email: 'a@b.com', password: 'pw'),
      throwsA(isA<ParseException>()),
    );
  });

  test('parses the real UAT login payload', () async {
    final repo = build(
      MockClient(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'tokenType': 'Bearer',
              'accessToken': 'at',
              'expiresIn': 86400,
              'refreshToken': 'rt',
              'availableContexts': [
                {
                  'contextKey': 'Teacher:3',
                  'role': 'Teacher',
                  'clientId': 2,
                  'clientName': 'Client',
                  'instituteId': 8,
                  'instituteName': 'ISL AC',
                  'instituteTypeId': 2,
                  'staffId': 3,
                  'studentId': null,
                  'guardianId': null,
                  'displayName': 'Teacher — ISL AC',
                },
              ],
              'requiresContextSelection': false,
              'activeContextKey': 'Teacher:3',
            }),
          ),
          200,
        ),
      ),
    );

    final res = await repo.login(email: 'a@b.com', password: 'pw');

    expect(res.expiresIn, 86400);
    expect(res.availableContexts.single.staffId, 3);
    expect(res.availableContexts.single.guardianId, isNull);
    expect(repo.isSignedIn, isTrue);
  });

  test('logout clears tokens and notifies listeners', () async {
    final repo = build(
      MockClient(
        (_) async => http.Response(jsonEncode({'accessToken': 'at'}), 200),
      ),
    );
    await repo.login(email: 'a@b.com', password: 'pw');
    final changes = <bool>[];
    repo.signedIn.addListener(() => changes.add(repo.signedIn.value));

    await repo.logout();

    expect(repo.isSignedIn, isFalse);
    expect(tokens.accessToken, isNull);
    expect(changes, [false]);
  });

  test('starts signed in when a persisted token exists', () async {
    tokens = InMemoryTokenStore();
    await tokens.save(accessToken: 'saved');
    final repo = AuthRepositoryImpl(
      apiClient: ApiClient(
        baseUrl: 'https://api.test',
        httpClient: MockClient((_) async => http.Response('', 200)),
      ),
      tokenStore: tokens,
    );

    expect(repo.isSignedIn, isTrue);
  });
}
