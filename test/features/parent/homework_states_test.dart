import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

void main() {
  final now = DateTime(2026, 11, 5, 12);
  ChildAssignment hw({bool done = false, int? marks, int daysAgo = 3}) =>
      ChildAssignment(
        id: '1',
        childId: '2',
        title: 't',
        deadline: now.subtract(Duration(days: daysAgo)),
        isCompleted: done,
        marks: marks,
      );

  group('homework states (as defined by the backend)', () {
    test('handed in / graded without hand-in / overdue', () {
      expect(hw(done: true).statusAt(now), AssignmentStatus.completed);
      expect(hw(marks: 90).statusAt(now), AssignmentStatus.graded);
      expect(hw().statusAt(now), AssignmentStatus.overdue);
      // Handed in and graded is still handed in.
      expect(
        hw(done: true, marks: 80).statusAt(now),
        AssignmentStatus.completed,
      );
    });

    test('graded work is not overdue and not a missed homework', () {
      final list = [hw(done: true), hw(marks: 90), hw(), hw(marks: 5)];
      expect(ProgressStats.overdue(list, now), 1);
      expect(ProgressStats.pending(list, now), 0);
      // 1 handed in of 2 that were expected (the graded ones are no miss).
      expect(
        ProgressStats.homework(list, now: now),
        const RatioStat(1, 2),
      );
      // Their marks still count toward the score.
      expect(ProgressStats.score(list, now: now), const RatioStat(95, 200));
    });
  });

  group('feedback tone', () {
    FeedbackTopic? topic(Map<String, dynamic> extra) => feedbackTopicFromJson(
      {
        'feedbackId': 1,
        'teacherSentAt': '2026-11-03T13:21:19',
        'teacherMessage': 'x',
        ...extra,
      },
      threadId: 'fb_2',
      asParent: true,
    );

    test('tone wins over isPositive', () {
      expect(
        topic({'tone': 'Note', 'isPositive': true})!.tone,
        FeedbackTone.needsAttention,
      );
      expect(
        topic({'tone': 'Positive', 'isPositive': false})!.tone,
        FeedbackTone.positive,
      );
    });

    test('isPositive is used when there is no tone', () {
      expect(topic({'isPositive': false})!.tone, FeedbackTone.needsAttention);
      expect(topic({})!.tone, FeedbackTone.positive);
    });
  });
}
