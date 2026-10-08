import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';

ApiClient _client(
  MockClient mock, {
  String? token,
  UnauthorizedHandler? onUnauthorized,
  Duration timeout = const Duration(seconds: 5),
}) => ApiClient(
  baseUrl: 'https://api.test',
  httpClient: mock,
  accessToken: () => token,
  onUnauthorized: onUnauthorized,
  timeout: timeout,
);

http.Response _json(Object body, int status) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  group('ApiClient', () {
    test(
      'builds URL with query, sends bearer token and decodes JSON',
      () async {
        late http.Request captured;
        final api = _client(
          MockClient((r) async {
            captured = r;
            return _json({'ok': true}, 200);
          }),
          token: 'abc',
        );

        final result = await api.get(
          '/api/x',
          query: {
            'a': 1,
            'skip': null,
            'ids': [1, 2],
          },
        );

        expect(result, {'ok': true});
        expect(
          captured.url.toString(),
          'https://api.test/api/x?a=1&ids=1&ids=2',
        );
        expect(captured.headers['Authorization'], 'Bearer abc');
      },
    );

    test('POST encodes JSON body; authenticated:false omits token', () async {
      late http.Request captured;
      final api = _client(
        MockClient((r) async {
          captured = r;
          return http.Response('', 204);
        }),
        token: 'abc',
      );

      final result = await api.post(
        '/p',
        body: {'k': 'v'},
        authenticated: false,
      );

      expect(result, isNull);
      expect(captured.headers['Content-Type'], 'application/json');
      expect(captured.headers.containsKey('Authorization'), isFalse);
      expect(jsonDecode(captured.body), {'k': 'v'});
    });

    test('maps 400 ProblemDetails to ValidationException', () async {
      final api = _client(
        MockClient(
          (_) async => _json({
            'title': 'Validation',
            'errors': {
              'Email': ['Email is invalid'],
            },
          }, 400),
        ),
      );

      await expectLater(
        api.get('/x'),
        throwsA(
          isA<ValidationException>()
              .having((e) => e.message, 'message', 'Email is invalid')
              .having((e) => e.fieldErrors['Email'], 'fields', [
                'Email is invalid',
              ]),
        ),
      );
    });

    test('maps status codes to typed exceptions', () async {
      Future<Object?> call(int status) =>
          _client(MockClient((_) async => http.Response('', status))).get('/x');

      await expectLater(call(401), throwsA(isA<UnauthorizedException>()));
      await expectLater(call(403), throwsA(isA<ForbiddenException>()));
      await expectLater(call(404), throwsA(isA<NotFoundException>()));
      await expectLater(call(503), throwsA(isA<ServerException>()));
      await expectLater(call(418), throwsA(isA<UnknownApiException>()));
    });

    test('maps socket errors, timeouts and bad JSON', () async {
      await expectLater(
        _client(
          MockClient((_) async => throw const SocketException('down')),
        ).get('/x'),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        _client(
          MockClient((_) => Completer<http.Response>().future),
          timeout: const Duration(milliseconds: 20),
        ).get('/x'),
        throwsA(isA<ApiTimeoutException>()),
      );
      await expectLater(
        _client(
          MockClient((_) async => http.Response('<html>', 200)),
        ).get('/x'),
        throwsA(isA<ParseException>()),
      );
    });

    test('retries once after a successful refresh on 401', () async {
      var token = 'old';
      var calls = 0;
      final api = ApiClient(
        baseUrl: 'https://api.test',
        httpClient: MockClient((r) async {
          calls++;
          return r.headers['Authorization'] == 'Bearer new'
              ? _json({'ok': 1}, 200)
              : http.Response('', 401);
        }),
        accessToken: () => token,
        onUnauthorized: () async {
          token = 'new';
          return true;
        },
      );

      expect(await api.get('/x'), {'ok': 1});
      expect(calls, 2);
    });

    test('does not retry when refresh fails', () async {
      var calls = 0;
      final api = _client(
        MockClient((_) async {
          calls++;
          return http.Response('', 401);
        }),
        onUnauthorized: () async => false,
      );

      await expectLater(api.get('/x'), throwsA(isA<UnauthorizedException>()));
      expect(calls, 1);
    });
  });
}
