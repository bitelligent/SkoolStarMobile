import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/children_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/guardian_repository.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';

ApiClient _api(MockClient mock) => ApiClient(
  baseUrl: 'https://api.test',
  httpClient: mock,
  timeout: const Duration(seconds: 2),
);

void main() {
  late FakeAuthRepository auth;
  late List<http.Request> requests;

  setUp(() {
    auth = FakeAuthRepository(context: AuthContext.fromJson(fx.parentContext));
    requests = [];
  });

  MockClient client(FutureOr<http.Response> Function(http.Request) handler) =>
      MockClient((r) async {
        requests.add(r);
        return handler(r);
      });

  group('ChildrenRepository', () {
    test('loads once, caches, refresh bypasses the cache', () async {
      final repo = ChildrenRepositoryImpl(
        apiClient: _api(client((_) => jsonResponse(fx.myChildren))),
        authRepository: auth,
      );
      expect(await repo.getChildren(), hasLength(2));
      await repo.getChildren();
      expect(requests, hasLength(1));
      expect(requests.single.url.path, '/api/Users/my-children');

      await repo.getChildren(refresh: true);
      expect(requests, hasLength(2));
    });

    test('a failure is not cached', () async {
      var fail = true;
      final repo = ChildrenRepositoryImpl(
        apiClient: _api(
          client((_) => fail ? http.Response('', 503) : jsonResponse([])),
        ),
        authRepository: auth,
      );
      await expectLater(repo.getChildren(), throwsA(isA<ServerException>()));
      fail = false;
      expect(await repo.getChildren(), isEmpty);
    });

    test('cache is dropped when the role changes', () async {
      final repo = ChildrenRepositoryImpl(
        apiClient: _api(client((_) => jsonResponse(fx.myChildren))),
        authRepository: auth,
      );
      await repo.getChildren();
      await auth.selectContext('Parent:8'); // same → no change
      await repo.getChildren();
      expect(requests, hasLength(1));

      auth = auth..signInAs(AuthContext.fromJson(fx.teacherContext));
      await repo.getChildren();
      expect(requests, hasLength(2));
    });
  });

  group('attendance / assignments', () {
    test('request the child and keep only that child\'s rows', () async {
      final mixed = [
        ...fx.childAttendance,
        {
          'studentId': 3,
          'sessionDate': '2026-10-09',
          'statusId': 1,
        },
      ];
      final repo = ChildAttendanceRepositoryImpl(
        apiClient: _api(client((_) => jsonResponse(mixed))),
        authRepository: auth,
      );
      final rows = await repo.getForChild('2');
      expect(requests.single.url.queryParameters['studentId'], '2');
      expect(rows, hasLength(3));
      expect(rows.every((r) => r.childId == '2'), isTrue);
    });

    test('per-child caches are independent', () async {
      final repo = ChildAssignmentsRepositoryImpl(
        apiClient: _api(client((_) => jsonResponse(fx.childAssignments))),
        authRepository: auth,
      );
      await repo.getForChild('2');
      await repo.getForChild('2');
      expect(requests, hasLength(1));
      await repo.getForChild('3');
      expect(requests, hasLength(2));
      await repo.getForChild('2', refresh: true);
      expect(requests, hasLength(3));
    });

    test('errors propagate and are not cached', () async {
      var calls = 0;
      final repo = ChildAssignmentsRepositoryImpl(
        apiClient: _api(
          client((_) {
            calls++;
            return calls == 1
                ? http.Response('', 401)
                : jsonResponse(fx.childAssignments);
          }),
        ),
        authRepository: auth,
      );
      await expectLater(
        repo.getForChild('2'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(await repo.getForChild('2'), hasLength(2));
    });
  });

  group('ChildScheduleRepository', () {
    ChildScheduleRepositoryImpl build(
      FutureOr<http.Response> Function(http.Request) h,
    ) => ChildScheduleRepositoryImpl(
      apiClient: _api(client(h)),
      authRepository: auth,
    );

    test('fetches the student endpoint per month and names subjects', () async {
      final repo = build((_) => jsonResponse(fx.studentOccurrences));
      final out = await repo.getBetween(
        '2',
        DateTime(2026, 10),
        DateTime(2026, 10, 31),
      );

      expect(requests.single.url.path, '/api/Schedules/occurrences/student/2');
      expect(requests.single.url.queryParameters, {
        'from': '2026-10-01',
        'to': '2026-10-31',
      });
      expect(out.sessions, hasLength(2));
      expect(out.subjects.map((s) => s.name), ['Computer', 'English', 'Math']);
    });

    test('caches months per child; another child fetches again', () async {
      final repo = build((_) => jsonResponse(fx.studentOccurrences));
      await repo.getBetween('2', DateTime(2026, 10), DateTime(2026, 10, 31));
      await repo.getBetween('2', DateTime(2026, 10), DateTime(2026, 10, 31));
      expect(requests, hasLength(1));
      await repo.getBetween('3', DateTime(2026, 10), DateTime(2026, 10, 31));
      expect(requests, hasLength(2));
      await repo.getBetween(
        '2',
        DateTime(2026, 10),
        DateTime(2026, 10, 31),
        refresh: true,
      );
      expect(requests, hasLength(3));
    });

    test('filters to the requested days inside a cached month', () async {
      final repo = build((_) => jsonResponse(fx.studentOccurrences));
      final out = await repo.getBetween(
        '2',
        DateTime(2026, 10, 9),
        DateTime(2026, 10, 9),
      );
      expect(out.sessions.single.startTime, '14:40');
    });

    test('withClass labels sessions with the child\'s own class', () async {
      final repo = build((_) => jsonResponse(fx.studentOccurrences));
      final out = (await repo.getBetween(
        '3',
        DateTime(2026, 10),
        DateTime(2026, 10, 31),
      )).withClass('Class 2');
      expect(out.classes.single.name, 'Class 2');
      expect(
        out.sessions.every((s) => s.classIds.single == out.classes.single.id),
        isTrue,
      );
      expect(
        (await repo.getBetween(
          '3',
          DateTime(2026, 10),
          DateTime(2026, 10, 31),
        )).withClass('').classes,
        isEmpty,
      );
    });

    test(
      'getById uses the cache, then the guid endpoint, 404 → null',
      () async {
        final repo = build((r) {
          if (r.url.path.endsWith('/missing')) return http.Response('', 404);
          if (r.url.path.contains('/guid/')) {
            return jsonResponse(fx.studentOccurrences.last);
          }
          return jsonResponse(fx.studentOccurrences);
        });
        await repo.getBetween('2', DateTime(2026, 10), DateTime(2026, 10, 31));
        final cached = await repo.getById(
          '2',
          'cc459182-a077-4a98-a55d-0b702091dfbf',
        );
        expect(cached?.occurrenceId, 1019);
        expect(requests, hasLength(1)); // served from cache

        expect(await repo.getById('2', 'unknown-id'), isNotNull); // guid fetch
        expect(await repo.getById('2', 'missing'), isNull);
      },
    );
  });

  group('GuardianRepository', () {
    test('combines manage/info and the child contact person', () async {
      final repo = GuardianRepositoryImpl(
        apiClient: _api(
          client(
            (r) => r.url.path.endsWith('manage/info')
                ? jsonResponse({'email': 'zealmughal@gmail.com'})
                : jsonResponse(fx.contactPersons),
          ),
        ),
        authRepository: auth,
      );
      final g = await repo.getProfile(childId: '2');
      expect(g.name, 'Muhammad Amir');
      expect(g.relationship, 'Father');
      await repo.getProfile(childId: '2');
      expect(requests, hasLength(2)); // second call cached
    });

    test('a failing name lookup still returns the e-mail', () async {
      final repo = GuardianRepositoryImpl(
        apiClient: _api(
          client(
            (r) => r.url.path.endsWith('manage/info')
                ? jsonResponse({'email': 'a@b.com'})
                : http.Response('', 500),
          ),
        ),
        authRepository: auth,
      );
      final g = await repo.getProfile(childId: '2');
      expect(g.name, '');
      expect(g.email, 'a@b.com');
    });
  });
}
