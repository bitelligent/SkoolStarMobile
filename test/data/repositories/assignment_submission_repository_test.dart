import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/assignment_submission_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';

import '../../helpers/fakes.dart';

class _Assignments implements ChildAssignmentsRepository {
  final List<({String id, bool refresh})> calls = [];
  Object? error;

  @override
  Future<List<ChildAssignment>> getForChild(
    String childId, {
    bool refresh = false,
  }) async {
    calls.add((id: childId, refresh: refresh));
    if (error != null) throw error!;
    return const [];
  }
}

void main() {
  late List<http.Request> requests;
  late _Assignments assignments;

  AssignmentSubmissionRepositoryImpl build(
    http.Response Function(http.Request) handler,
  ) {
    requests = [];
    assignments = _Assignments();
    return AssignmentSubmissionRepositoryImpl(
      apiClient: ApiClient(
        baseUrl: 'https://api.test',
        httpClient: MockClient((r) async {
          requests.add(r);
          return handler(r);
        }),
        timeout: const Duration(seconds: 2),
      ),
      assignments: assignments,
    );
  }

  group('uploadFile', () {
    test(
      'sends one multipart "file" part and returns the stored url',
      () async {
        final repo = build(
          (_) => jsonResponse({
            'fileUrl': '/uploads/teacher-module/submissions/1-a.pdf',
            'fileName': 'a.pdf',
          }),
        );
        final stored = await repo.uploadFile(
          fileName: 'a.pdf',
          bytes: [1, 2, 3],
        );
        expect(stored.url, '/uploads/teacher-module/submissions/1-a.pdf');
        expect(stored.name, 'a.pdf');

        final r = requests.single;
        expect(r.method, 'POST');
        expect(
          r.url.path,
          '/api/TeacherModule/children/assignments/upload-file',
        );
        expect(r.headers['content-type'], startsWith('multipart/form-data'));
        final body = latin1.decode(r.bodyBytes);
        expect(body, contains('name="file"'));
        expect(body, contains('filename="a.pdf"'));
      },
    );

    test('a refused file never reaches the network', () async {
      final repo = build((_) => jsonResponse({'fileUrl': '/x'}));
      await expectLater(
        repo.uploadFile(fileName: 'a.exe', bytes: [1]),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        repo.uploadFile(
          fileName: 'a.pdf',
          bytes: List.filled(SubmissionRules.maxFileBytes + 1, 0),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        repo.uploadFile(fileName: 'a.pdf', bytes: const []),
        throwsA(isA<ValidationException>()),
      );
      expect(requests, isEmpty);
    });

    test(
      'a response without fileUrl is an error, not a dead reference',
      () async {
        final repo = build((_) => jsonResponse({'fileName': 'a.pdf'}));
        await expectLater(
          repo.uploadFile(fileName: 'a.pdf', bytes: [1]),
          throwsA(isA<ParseException>()),
        );
      },
    );

    test('the server explains a refusal', () async {
      final repo = build(
        (_) => jsonResponse({
          'message': 'File is too large. Maximum allowed size is 15 MB.',
        }, 400),
      );
      await expectLater(
        repo.uploadFile(fileName: 'a.pdf', bytes: [1]),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('too large'),
          ),
        ),
      );
    });

    test('wrong role (empty 403) is a permission error', () async {
      final repo = build((_) => http.Response('', 403));
      await expectLater(
        repo.uploadFile(fileName: 'a.pdf', bytes: [1]),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });

  group('submit', () {
    http.Response ok(Map<String, Object?> extra) => jsonResponse({
      'message': 'Assignment submitted successfully.',
      'taskId': 90,
      'studentId': 42,
      'completedAt': '2026-11-10T14:15:30',
      ...extra,
    });

    test(
      'posts the child, note, links and file urls as the guide says',
      () async {
        final repo = build((_) => ok({}));
        await repo.submit(
          childId: '42',
          taskId: '90',
          note: '  Finished all five.  ',
          links: ['https://example.com/x'],
          fileUrls: ['/uploads/a.pdf'],
        );
        final r = requests.single;
        expect(r.method, 'POST');
        expect(r.url.path, '/api/TeacherModule/children/assignments/90/submit');
        expect(jsonDecode(r.body), {
          'studentId': 42,
          'feedback': 'Finished all five.',
          'links': ['https://example.com/x'],
          'files': ['/uploads/a.pdf'],
        });
      },
    );

    test('a blank note is sent as null; a bare hand-in is valid', () async {
      final repo = build((_) => ok({}));
      await repo.submit(childId: '42', taskId: '90', note: '   ');
      expect(jsonDecode(requests.single.body), {
        'studentId': 42,
        'feedback': null,
        'links': <Object>[],
        'files': <Object>[],
      });
    });

    test('completedAt is UTC on the wire and local in the app', () async {
      final repo = build((_) => ok({}));
      final at = await repo.submit(childId: '42', taskId: '90');
      expect(at.toUtc(), DateTime.utc(2026, 11, 10, 14, 15, 30));
    });

    test('refreshes the cached assignments and announces the child', () async {
      final repo = build((_) => ok({}));
      final announced = <String>[];
      repo.submitted.listen(announced.add);
      await repo.submit(childId: '42', taskId: '90');
      await Future<void>.delayed(Duration.zero);
      expect(assignments.calls, [(id: '42', refresh: true)]);
      expect(announced, ['42']);
    });

    test('a failing refresh does not undo a successful submit', () async {
      final repo = build((_) => ok({}));
      assignments.error = const NetworkException();
      final announced = <String>[];
      repo.submitted.listen(announced.add);
      final at = await repo.submit(childId: '42', taskId: '90');
      await Future<void>.delayed(Duration.zero);
      expect(at, isA<DateTime>());
      expect(announced, ['42']);
    });

    test('a failed submit announces nothing', () async {
      final repo = build(
        (_) => jsonResponse({
          'message': 'Selected child is not linked to this account.',
        }, 400),
      );
      final announced = <String>[];
      repo.submitted.listen(announced.add);
      await expectLater(
        repo.submit(childId: '42', taskId: '90'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Selected child is not linked to this account.',
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(announced, isEmpty);
      expect(assignments.calls, isEmpty);
    });

    test('404 and 403 become typed errors', () async {
      await expectLater(
        build(
          (_) => jsonResponse({'message': 'Assignment not found.'}, 404),
        ).submit(childId: '42', taskId: '1'),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        build((_) => http.Response('', 403)).submit(childId: '42', taskId: '1'),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('a child id that is not a number is refused locally', () async {
      final repo = build((_) => ok({}));
      await expectLater(
        repo.submit(childId: 'abc', taskId: '90'),
        throwsA(isA<ValidationException>()),
      );
      expect(requests, isEmpty);
    });
  });
}
