import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/mappers/feedback_mapper.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';

Map<String, Object?> _leave({
  Object? id = 18,
  Object? statusId = 1,
  String start = '2026-11-04T00:00:00',
  String end = '2026-11-06T00:00:00',
}) => {
  'id': id,
  'studentId': 42,
  'studentName': 'Jannat Shahzadi',
  'className': 'Class 1',
  'startDate': start,
  'endDate': end,
  'durationDays': 3,
  'reason': 'Family travel',
  'statusId': statusId,
  'decisionReason': null,
  'submittedAt': '2026-11-04T09:15:00+00:00',
  'decidedAt': null,
};

void main() {
  group('leave', () {
    test('maps the documented object', () {
      final r = leaveFromJson(_leave())!;
      expect(r.id, '18');
      expect(r.childId, '42');
      expect(r.childName, 'Jannat Shahzadi');
      expect(r.startDate, DateTime(2026, 11, 4));
      expect(r.endDate, DateTime(2026, 11, 6));
      expect(r.durationDays, 3);
      expect(r.status, LeaveStatus.pending);
      expect(r.canCancel, isTrue);
      expect(r.decisionReason, isNull);
      expect(r.submittedAt, isNotNull);
    });

    test('status ids map to their meaning; unknown is not pending', () {
      expect(LeaveStatus.fromId(2), LeaveStatus.approved);
      expect(LeaveStatus.fromId(3), LeaveStatus.rejected);
      expect(LeaveStatus.fromId(4), LeaveStatus.cancelled);
      final odd = leaveFromJson(_leave(statusId: 9))!;
      expect(odd.status, LeaveStatus.unknown);
      expect(odd.canCancel, isFalse, reason: 'never offer cancel by guess');
    });

    test('only a pending request can be cancelled', () {
      for (final id in [2, 3, 4]) {
        expect(leaveFromJson(_leave(statusId: id))!.canCancel, isFalse);
      }
    });

    test('rows missing id or dates are skipped, duration is derived', () {
      expect(leaveFromJson(_leave(id: null)), isNull);
      expect(leaveFromJson({'id': 1, 'startDate': 'x'}), isNull);
      expect(leaveFromJson('nope'), isNull);
      final noDuration = _leave()..remove('durationDays');
      expect(leaveFromJson(noDuration)!.durationDays, 3);
    });

    test('page envelope', () {
      final page = leavePageFromJson({
        'items': [
          _leave(),
          {'bad': true},
        ],
        'pageNumber': 2,
        'totalCount': 30,
        'hasNextPage': true,
      });
      expect(page.items, hasLength(1));
      expect(page.pageNumber, 2);
      expect(page.totalCount, 30);
      expect(page.hasNextPage, isTrue);
    });

    test('an empty page is not an error', () {
      final page = leavePageFromJson({'items': <Object>[], 'totalCount': 0});
      expect(page.items, isEmpty);
      expect(page.hasNextPage, isFalse);
      expect(leavePageFromJson(null).items, isEmpty);
    });
  });

  group('progress', () {
    test('picks the row of the child', () {
      final p = progressFromJson([
        {'studentId': 7, 'completedAssignments': 1},
        {
          'studentId': 42,
          'completedAssignments': 6,
          'totalAssignments': 8,
          'totalResults': 3,
          'averageScore': 78.5,
        },
      ], childId: '42')!;
      expect(p.completedAssignments, 6);
      expect(p.totalAssignments, 8);
      expect(p.totalResults, 3);
      expect(p.averageScore, 78.5);
      expect(p.hasData, isTrue);
    });

    test('an integer average and a missing child both work', () {
      final p = progressFromJson([
        {'studentId': 1, 'averageScore': 80, 'totalResults': 1},
      ], childId: '1')!;
      expect(p.averageScore, 80.0);
      expect(progressFromJson([], childId: '1'), isNull);
      expect(progressFromJson(null, childId: '1'), isNull);
    });

    test('no assignments and no results has nothing to show', () {
      final p = progressFromJson([
        {'studentId': 1},
      ], childId: '1')!;
      expect(p.hasData, isFalse);
      expect(p.hasResults, isFalse);
    });

    test('exam results: this child only, newest first, bad rows skipped', () {
      final r = resultsFromJson([
        {
          'studentId': 42,
          'examId': 5,
          'examName': 'Mid term',
          'score': 82,
          'createdAt': '2026-10-20T08:00:00',
        },
        {
          'studentId': 42,
          'examName': 'Quiz',
          'score': 7.5,
          'remarks': 'Good',
          'createdAt': '2026-11-01T08:00:00',
        },
        {'studentId': 9, 'examName': 'Other', 'score': 1},
        {'studentId': 42, 'examName': 'No score'},
        {'studentId': 42, 'score': 3},
      ], childId: '42');
      expect(r.map((e) => e.examName), ['Quiz', 'Mid term']);
      expect(r.first.score, 7.5);
      expect(r.first.remarks, 'Good');
      expect(r.last.score, 82);
    });
  });

  group('feedback subjects', () {
    test('maps names and ids, skips rows without a name', () {
      final s = feedbackSubjectsFromJson([
        {'subjectId': 12, 'subjectName': 'Mathematics'},
        {'subjectId': 13},
        {'subjectId': 18, 'subjectName': 'English'},
      ]);
      expect(s.map((e) => e.name), ['Mathematics', 'English']);
      expect(s.first.id, '12');
    });

    test('several students: only subjects every one has, sorted', () {
      final a = feedbackSubjectsFromJson([
        {'subjectId': 1, 'subjectName': 'Science'},
        {'subjectId': 2, 'subjectName': 'Maths'},
        {'subjectId': 3, 'subjectName': 'Art'},
      ]);
      final b = feedbackSubjectsFromJson([
        {'subjectId': 9, 'subjectName': 'Maths'},
        {'subjectId': 8, 'subjectName': 'Art'},
      ]);
      expect(commonSubjects([a, b]).map((e) => e.name), ['Art', 'Maths']);
      expect(commonSubjects([a]).map((e) => e.name), [
        'Art',
        'Maths',
        'Science',
      ]);
      expect(commonSubjects([a, const []]), isEmpty);
      expect(commonSubjects(const []), isEmpty);
    });
  });
}
