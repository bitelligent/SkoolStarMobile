import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

import '../../fixtures/fixtures.dart' as fx;

http.Response _json(Object body, [int status = 200]) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late InMemoryTokenStore tokens;

  AuthRepositoryImpl build(MockClient mock, {InMemoryTokenStore? store}) {
    tokens = store ?? InMemoryTokenStore();
    return AuthRepositoryImpl(
      apiClient: ApiClient(
        baseUrl: 'https://api.test',
        httpClient: mock,
        accessToken: () => tokens.accessToken,
      ),
      tokenStore: tokens,
    );
  }

  test(
    'login posts credentials, stores tokens and the teacher context',
    () async {
      late http.Request captured;
      final repo = build(
        MockClient((r) async {
          captured = r;
          return _json(fx.loginResponse);
        }),
      );

      final res = await repo.login(email: ' a@b.com ', password: 'pw');

      expect(captured.url.path, '/api/Users/enhanced-login');
      expect(jsonDecode(captured.body), {'email': 'a@b.com', 'password': 'pw'});
      expect(res.expiresIn, 86400);
      expect(tokens.accessToken, 'at');
      expect(tokens.refreshToken, 'rt');
      expect(repo.isSignedIn, isTrue);
      expect(repo.currentContext?.staffId, 3);
      expect(repo.currentContext?.instituteName, 'ISL AC');
      expect(tokens.contextJson, isNotNull);
    },
  );

  test('rejects a non-teacher account and keeps nothing', () async {
    final parent = {
      ...fx.teacherContext,
      'contextKey': 'Guardian:9',
      'role': 'Guardian',
      'staffId': null,
    };
    final repo = build(
      MockClient(
        (_) async => _json({
          ...fx.loginResponse,
          'availableContexts': [parent],
          'activeContextKey': 'Guardian:9',
        }),
      ),
    );

    await expectLater(
      repo.login(email: 'a@b.com', password: 'pw'),
      throwsA(isA<ForbiddenException>()),
    );
    expect(tokens.accessToken, isNull);
    expect(repo.isSignedIn, isFalse);
  });

  test('does not store a token when context selection is required', () async {
    final repo = build(
      MockClient(
        (_) async => _json({
          'requiresContextSelection': true,
          'availableContexts': [fx.teacherContext],
        }),
      ),
    );

    final res = await repo.login(email: 'a@b.com', password: 'pw');

    expect(res.requiresContextSelection, isTrue);
    expect(res.availableContexts, hasLength(1));
    expect(tokens.accessToken, isNull);
    expect(repo.isSignedIn, isFalse);
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

  test('logout clears tokens/context and notifies listeners', () async {
    final repo = build(MockClient((_) async => _json(fx.loginResponse)));
    await repo.login(email: 'a@b.com', password: 'pw');
    final changes = <bool>[];
    repo.signedIn.addListener(() => changes.add(repo.signedIn.value));

    await repo.logout();

    expect(repo.isSignedIn, isFalse);
    expect(tokens.accessToken, isNull);
    expect(tokens.contextJson, isNull);
    expect(repo.currentContext, isNull);
    expect(changes, [false]);
  });

  test('restores session and context from storage', () async {
    final store = InMemoryTokenStore();
    await store.save(accessToken: 'saved');
    await store.saveContext(jsonEncode(fx.teacherContext));
    final repo = build(
      MockClient((_) async => throw StateError('no network expected')),
      store: store,
    );

    expect(repo.isSignedIn, isTrue);
    expect((await repo.requireContext()).staffId, 3);
  });

  test('requireContext fetches my-contexts for an old session', () async {
    final store = InMemoryTokenStore();
    await store.save(accessToken: 'saved');
    var calls = 0;
    final repo = build(
      MockClient((r) async {
        calls++;
        expect(r.url.path, '/api/Users/my-contexts');
        expect(r.headers['Authorization'], 'Bearer saved');
        return _json([fx.teacherContext]);
      }),
      store: store,
    );

    expect((await repo.requireContext()).instituteId, 8);
    await repo.requireContext(); // cached
    expect(calls, 1);
  });

  test('requireContext without a teacher context is Forbidden', () async {
    final store = InMemoryTokenStore();
    await store.save(accessToken: 'saved');
    final repo = build(MockClient((_) async => _json([])), store: store);

    await expectLater(
      repo.requireContext(),
      throwsA(isA<ForbiddenException>()),
    );
  });
}
