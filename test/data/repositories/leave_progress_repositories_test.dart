import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_subjects_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_progress_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/leave_repository.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';

ApiClient _api(MockClient mock) => ApiClient(
  baseUrl: 'https://api.test',
  httpClient: mock,
  timeout: const Duration(seconds: 2),
);

const _leaveJson = {
  'id': 18,
  'studentId': 42,
  'studentName': 'Jannat',
  'startDate': '2026-11-04T00:00:00',
  'endDate': '2026-11-06T00:00:00',
  'durationDays': 3,
  'reason': 'Family travel',
  'statusId': 1,
};

void main() {
  group('LeaveRepository', () {
    late List<http.Request> requests;

    LeaveRepositoryImpl build(
      http.Response Function(http.Request) handler,
    ) {
      requests = [];
      return LeaveRepositoryImpl(
        _api(
          MockClient((r) async {
            requests.add(r);
            return handler(r);
          }),
        ),
      );
    }

    test('list asks for the child, status and page', () async {
      final repo = build(
        (_) => jsonResponse({
          'items': [_leaveJson],
          'pageNumber': 2,
          'totalCount': 26,
          'hasNextPage': false,
        }),
      );
      final page = await repo.list(
        childId: '42',
        status: LeaveStatus.pending,
        page: 2,
      );
      final q = requests.single.url.queryParameters;
      expect(requests.single.url.path, '/api/LeaveApplications/mine');
      expect(q['studentId'], '42');
      expect(q['statusId'], '1');
      expect(q['pageNumber'], '2');
      expect(q['pageSize'], '25');
      expect(page.items.single.id, '18');
    });

    test('list without filters sends neither', () async {
      final repo = build((_) => jsonResponse({'items': <Object>[]}));
      await repo.list();
      final q = requests.single.url.queryParameters;
      expect(q.containsKey('studentId'), isFalse);
      expect(q.containsKey('statusId'), isFalse);
      expect(q['pageNumber'], '1');
    });

    test(
      'create sends dates only, trimmed reason and no ids of ours',
      () async {
        final repo = build((_) => jsonResponse(_leaveJson, 201));
        final r = await repo.create(
          childId: '42',
          start: DateTime(2026, 11, 4, 15, 30),
          end: DateTime(2026, 11, 6),
          reason: '  Family travel ',
        );
        final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
        expect(requests.single.method, 'POST');
        expect(requests.single.url.path, '/api/LeaveApplications');
        expect(body, {
          'studentId': 42,
          'startDate': '2026-11-04',
          'endDate': '2026-11-06',
          'reason': 'Family travel',
        });
        expect(r.status, LeaveStatus.pending);
      },
    );

    test("a 400 carries the server's message", () async {
      final repo = build(
        (_) => jsonResponse({
          'message':
              'This student already has a pending or approved leave request '
              'for those dates.',
        }, 400),
      );
      await expectLater(
        repo.create(
          childId: '42',
          start: DateTime(2026, 11, 4),
          end: DateTime(2026, 11, 4),
          reason: 'x',
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            contains('already has a pending'),
          ),
        ),
      );
    });

    test('cancel posts to the id and returns the cancelled request', () async {
      final repo = build(
        (_) => jsonResponse({..._leaveJson, 'statusId': 4}),
      );
      final r = await repo.cancel('18');
      expect(requests.single.method, 'POST');
      expect(requests.single.url.path, '/api/LeaveApplications/18/cancel');
      expect(r.status, LeaveStatus.cancelled);
    });

    test('an unreadable body is a ParseException, not a crash', () async {
      final repo = build((_) => jsonResponse({'unexpected': true}));
      await expectLater(repo.cancel('18'), throwsA(isA<ParseException>()));
    });
  });

  group('ChildProgressRepository', () {
    late int calls;
    late ChildProgressRepositoryImpl repo;
    late FakeAuthRepository auth;

    setUp(() {
      calls = 0;
      auth = FakeAuthRepository(
        context: AuthContext.fromJson(fx.parentContext),
      );
      repo = ChildProgressRepositoryImpl(
        apiClient: _api(
          MockClient((r) async {
            calls++;
            if (r.url.path.endsWith('/progress')) {
              return jsonResponse([
                {
                  'studentId': 42,
                  'completedAssignments': 6,
                  'totalAssignments': 8,
                  'totalResults': 3,
                  'averageScore': 78.5,
                },
              ]);
            }
            return jsonResponse([
              {
                'studentId': 42,
                'examName': 'Mid term',
                'score': 82,
                'createdAt': '2026-10-20T08:00:00',
              },
            ]);
          }),
        ),
        authRepository: auth,
      );
    });

    test('reads summary and results, caching each per child', () async {
      final s = await repo.getSummary('42');
      final r = await repo.getResults('42');
      expect(s!.averageScore, 78.5);
      expect(r.single.examName, 'Mid term');
      await repo.getSummary('42');
      await repo.getResults('42');
      expect(calls, 2, reason: 'second reads come from the cache');
      await repo.getSummary('42', refresh: true);
      expect(calls, 3);
    });

    test('a failed read is not cached', () async {
      var fail = true;
      final flaky = ChildProgressRepositoryImpl(
        apiClient: _api(
          MockClient(
            (_) async => fail ? http.Response('', 500) : jsonResponse([]),
          ),
        ),
        authRepository: auth,
      );
      await expectLater(flaky.getResults('1'), throwsA(isA<ApiException>()));
      fail = false;
      expect(await flaky.getResults('1'), isEmpty);
    });
  });

  group('FeedbackSubjectsRepository', () {
    test('one call per student; only shared subjects are offered', () async {
      final asked = <String?>[];
      final repo = FeedbackSubjectsRepositoryImpl(
        _api(
          MockClient((r) async {
            final id = r.url.queryParameters['studentId'];
            asked.add(id);
            expect(
              r.url.path,
              '/api/TeacherModule/weekly-feedback-report/subjects',
            );
            return jsonResponse(
              id == '1'
                  ? [
                      {'subjectId': 1, 'subjectName': 'Maths'},
                      {'subjectId': 2, 'subjectName': 'English'},
                    ]
                  : [
                      {'subjectId': 1, 'subjectName': 'Maths'},
                      {'subjectId': 9, 'subjectName': 'English'},
                    ],
            );
          }),
        ),
      );
      final subjects = await repo.commonFor(['1', '2']);
      expect(asked, unorderedEquals(['1', '2']));
      expect(subjects.map((s) => s.name), ['Maths']);
    });

    test('nobody selected means no request', () async {
      var calls = 0;
      final repo = FeedbackSubjectsRepositoryImpl(
        _api(
          MockClient((_) async {
            calls++;
            return jsonResponse([]);
          }),
        ),
      );
      expect(await repo.commonFor(const []), isEmpty);
      expect(calls, 0);
    });

    test('duplicate ids are asked once', () async {
      var calls = 0;
      final repo = FeedbackSubjectsRepositoryImpl(
        _api(
          MockClient((_) async {
            calls++;
            return jsonResponse([]);
          }),
        ),
      );
      await repo.commonFor(['1', '1']);
      expect(calls, 1);
    });
  });
}
