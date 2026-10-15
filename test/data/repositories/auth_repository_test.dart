import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/app_role.dart';
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

  group('roles', () {
    final parentContext = {
      ...fx.teacherContext,
      'contextKey': 'Parent:8',
      'role': 'Parent',
      'staffId': null,
      'studentId': 2,
      'guardianId': 2,
    };
    final adminContext = {
      ...fx.teacherContext,
      'contextKey': 'ClientAdmin:2',
      'role': 'ClientAdmin',
      'staffId': null,
      'instituteName': 'test',
    };

    test(
      'a single parent role signs in straight to the parent module',
      () async {
        final repo = build(
          MockClient(
            (_) async => _json({
              ...fx.loginResponse,
              'availableContexts': [parentContext],
              'activeContextKey': 'Parent:8',
            }),
          ),
        );
        await repo.login(email: 'a@b.com', password: 'pw');

        final s = repo.session.value;
        expect(s.role, AppRole.parent);
        expect(s.needsRoleSelection, isFalse);
        expect(tokens.accessToken, 'at');
      },
    );

    test(
      'several roles: token stored, no role active, role list ready',
      () async {
        final repo = build(
          MockClient(
            (_) async => _json({
              'accessToken': 'pre',
              'refreshToken': 'rt',
              'requiresContextSelection': true,
              'activeContextKey': null,
              'availableContexts': [adminContext, parentContext],
            }),
          ),
        );
        await repo.login(email: 'a@b.com', password: 'pw');

        final s = repo.session.value;
        expect(s.signedIn, isTrue);
        expect(s.context, isNull);
        expect(s.needsRoleSelection, isTrue);
        expect(s.contexts.map((c) => c.contextKey), [
          'ClientAdmin:2',
          'Parent:8',
        ]);
        expect(tokens.accessToken, 'pre'); // needed to call select-context
        expect(tokens.contextJson, isNull);
        expect(tokens.contextsJson, isNotNull);
      },
    );

    test('an account whose only role is unsupported must pick/leave', () async {
      final repo = build(
        MockClient(
          (_) async => _json({
            ...fx.loginResponse,
            'availableContexts': [adminContext],
            'activeContextKey': 'ClientAdmin:2',
          }),
        ),
      );
      await repo.login(email: 'a@b.com', password: 'pw');

      final s = repo.session.value;
      expect(s.role, isNull); // unsupported → no module
      expect(s.needsRoleSelection, isTrue);
    });

    test('selectContext exchanges the token and activates the role', () async {
      late http.Request captured;
      var call = 0;
      final repo = build(
        MockClient((r) async {
          call++;
          if (call == 1) {
            return _json({
              'accessToken': 'pre',
              'requiresContextSelection': true,
              'availableContexts': [adminContext, parentContext],
            });
          }
          captured = r;
          return _json({
            'accessToken': 'parent-token',
            'refreshToken': 'rt2',
            'requiresContextSelection': false,
            'activeContextKey': 'Parent:8',
            'availableContexts': [adminContext, parentContext],
          });
        }),
      );
      await repo.login(email: 'a@b.com', password: 'pw');
      final changes = <String?>[];
      repo.session.addListener(
        () => changes.add(repo.session.value.contextKey),
      );

      final active = await repo.selectContext('Parent:8');

      expect(captured.url.path, '/api/Users/select-context');
      expect(captured.headers['Authorization'], 'Bearer pre');
      expect(jsonDecode(captured.body), {'contextKey': 'Parent:8'});
      expect(active.appRole, AppRole.parent);
      expect(tokens.accessToken, 'parent-token');
      expect(repo.session.value.role, AppRole.parent);
      expect(changes, ['Parent:8']);
    });

    test('selectContext failure keeps the previous session', () async {
      var call = 0;
      final repo = build(
        MockClient((_) async {
          call++;
          if (call == 1) {
            return _json({
              ...fx.loginResponse,
              'availableContexts': [fx.teacherContext, parentContext],
            });
          }
          return http.Response('', 500);
        }),
      );
      await repo.login(email: 'a@b.com', password: 'pw');

      await expectLater(
        repo.selectContext('Parent:8'),
        throwsA(isA<ServerException>()),
      );
      expect(repo.session.value.role, AppRole.teacher);
      expect(tokens.accessToken, 'at');
    });

    test('the role list survives an app restart', () async {
      final store = InMemoryTokenStore();
      final first = build(
        MockClient(
          (_) async => _json({
            ...fx.loginResponse,
            'availableContexts': [fx.teacherContext, parentContext],
          }),
        ),
        store: store,
      );
      await first.login(email: 'a@b.com', password: 'pw');

      final second = build(
        MockClient((_) async => throw StateError('no network expected')),
        store: store,
      );
      expect(second.session.value.signedIn, isTrue);
      expect(second.session.value.role, AppRole.teacher);
      expect(second.availableContexts, hasLength(2));
    });

    test('an account with no roles cannot sign in', () async {
      final repo = build(
        MockClient(
          (_) async => _json({
            'accessToken': 'x',
            'availableContexts': <Object>[],
          }),
        ),
      );
      await expectLater(
        repo.login(email: 'a@b.com', password: 'pw'),
        throwsA(isA<ForbiddenException>()),
      );
      expect(repo.isSignedIn, isFalse);
    });
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
