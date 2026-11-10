import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_report.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

final _now = DateTime(2026, 10, 20, 12);

ChildAttendanceRecord _att(
  String status,
  int daysAgo, {
  String subject = 'Math',
  String? remarks,
}) => ChildAttendanceRecord(
  childId: '1',
  date: _now.subtract(Duration(days: daysAgo)),
  status: status,
  subjectName: subject,
  remarks: remarks,
);

ChildAssignment _hw(
  String title,
  int deadlineDaysAgo, {
  bool done = false,
  int? marks,
  int max = 10,
  String subject = 'Math',
  String? feedback,
}) => ChildAssignment(
  id: title,
  childId: '1',
  title: title,
  deadline: _now.subtract(Duration(days: deadlineDaysAgo)),
  isCompleted: done,
  completedAt: done ? _now.subtract(Duration(days: deadlineDaysAgo)) : null,
  marks: marks,
  maxMarks: max,
  subjectName: subject,
  feedback: feedback,
);

FeedbackEntry _fb({
  String id = '1',
  bool teacherLast = true,
  int unread = 0,
  FeedbackTone tone = FeedbackTone.positive,
  int daysAgo = 1,
}) => FeedbackEntry(
  'fb_1_T',
  FeedbackTopic(
    id: id,
    threadId: 'fb_1_T',
    subject: 'Math progress',
    tone: tone,
    createdAt: _now.subtract(Duration(days: daysAgo + 1)),
    messages: [
      FeedbackMessage(
        id: 'm$id',
        fromTeacher: teacherLast,
        content: teacherLast ? 'Great work' : 'Thank you',
        sentAt: _now.subtract(Duration(days: daysAgo)),
        isRead: unread == 0,
        senderName: 'Tahir Mughal',
      ),
    ],
  ),
);

ProgressReport _build({
  ProgressPeriod period = ProgressPeriod.month,
  List<ChildAttendanceRecord> att = const [],
  List<ChildAssignment> hw = const [],
  List<FeedbackEntry> fb = const [],
}) => ProgressReport.build(
  period: period,
  now: _now,
  attendance: att,
  assignments: hw,
  feedback: fb,
);

void main() {
  group('trend vs previous period', () {
    test('improvement shows a positive delta', () {
      final r = _build(
        att: [
          // previous 30 days: 1 of 2 attended
          _att('present', 40),
          _att('absent', 41),
          // current 30 days: 3 of 3
          _att('present', 3),
          _att('present', 4),
          _att('present', 5),
        ],
      );
      expect(r.attendance.current, const RatioStat(3, 3));
      expect(r.attendance.previous, const RatioStat(1, 2));
      expect(r.attendance.delta, 50);
    });

    test('a decline is negative', () {
      final r = _build(
        att: [
          _att('present', 40),
          _att('present', 41),
          _att('present', 3),
          _att('absent', 4),
        ],
      );
      expect(r.attendance.delta, -50);
    });

    test('no data in either period means no delta', () {
      final r = _build(att: [_att('present', 3)]);
      expect(r.attendance.delta, isNull);
      expect(r.homework.delta, isNull);
    });

    test('periods never overlap at the boundary', () {
      // The day exactly 30 days ago starts the current period...
      final edge = _build(att: [_att('absent', 30), _att('present', 2)]);
      expect(edge.attendance.current, const RatioStat(1, 2));
      expect(edge.attendance.previous, RatioStat.empty);
      // ...and the day before it belongs to the previous one.
      final before = _build(att: [_att('absent', 31), _att('present', 2)]);
      expect(before.attendance.current, const RatioStat(1, 1));
      expect(before.attendance.previous, const RatioStat(0, 1));
    });

    test('"All time" has nothing to compare with', () {
      final r = _build(
        period: ProgressPeriod.all,
        att: [_att('present', 200), _att('absent', 3)],
      );
      expect(r.attendance.current, const RatioStat(1, 2));
      expect(r.attendance.previous, isNull);
    });

    test('week period uses 7 days', () {
      final r = _build(
        period: ProgressPeriod.week,
        att: [_att('present', 2), _att('absent', 10)],
      );
      expect(r.attendance.current, const RatioStat(1, 1));
      expect(r.attendance.previous, const RatioStat(0, 1));
    });
  });

  group('weekly buckets', () {
    test('eight weeks, oldest first, newest includes today', () {
      final r = _build(
        att: [_att('present', 1), _att('absent', 9), _att('present', 10)],
      );
      expect(r.weeks.length, 8);
      expect(r.weeks.first.start.isBefore(r.weeks.last.start), isTrue);
      expect(r.weeks.last.attendance, const RatioStat(1, 1));
      expect(r.weeks[6].attendance, const RatioStat(1, 2));
    });

    test('empty weeks have no data rather than 0 %', () {
      final r = _build();
      expect(r.weeks.every((w) => w.attendance.percent == null), isTrue);
    });
  });

  group('subjects', () {
    test('average per subject, best first, ungraded excluded', () {
      final r = _build(
        hw: [
          _hw('a', 3, marks: 9, subject: 'Math'),
          _hw('b', 4, marks: 5, subject: 'Math'),
          _hw('c', 5, marks: 10, subject: 'English'),
          _hw('d', 6, subject: 'Science'),
          _hw('e', 7, marks: 4, subject: ''),
        ],
      );
      expect(r.subjects.map((s) => s.subject), ['English', 'Math', 'Other']);
      expect(r.subjects[1].score, const RatioStat(14, 20));
    });

    test('only the selected period counts', () {
      final r = _build(
        period: ProgressPeriod.week,
        hw: [
          _hw('new', 2, marks: 8),
          _hw('old', 20, marks: 1),
        ],
      );
      expect(r.subjects.single.score, const RatioStat(8, 10));
    });
  });

  group('needs attention', () {
    test('overdue homework, recent absences, low scores, unread feedback', () {
      final r = _build(
        att: [
          _att('absent', 3),
          _att('absent', 40), // too old to flag
          _att('present', 1),
        ],
        hw: [
          _hw('Fractions', 5),
          _hw('Essay', 6, done: true, marks: 3),
          _hw('Algebra', 2, done: true, marks: 9),
        ],
        fb: [_fb(unread: 1)],
      );
      final kinds = r.attention.map((i) => i.kind).toList();
      expect(kinds.first, AttentionKind.newFeedback); // needs a reply first
      expect(kinds, contains(AttentionKind.overdueHomework));
      expect(kinds, contains(AttentionKind.absence));
      expect(kinds, contains(AttentionKind.lowScore));
      expect(
        r.attention.where((i) => i.kind == AttentionKind.absence).length,
        1,
      );
      final overdue = r.attention.firstWhere(
        (i) => i.kind == AttentionKind.overdueHomework,
      );
      expect(overdue.title, 'Overdue: Fractions');
      expect(overdue.link.target, LinkTarget.assignments);
    });

    test('feedback items link to their thread', () {
      final r = _build(fb: [_fb(unread: 1)]);
      final item = r.attention.single;
      expect(item.subtitle, '1 unread message');
      expect(item.link.target, LinkTarget.feedbackThread);
      expect(item.link.threadId, 'fb_1_T');
    });

    test('everything fine means nothing to flag', () {
      final r = _build(
        att: [_att('present', 1)],
        hw: [_hw('ok', 2, done: true, marks: 9)],
        fb: [_fb()],
      );
      expect(r.attention, isEmpty);
    });

    test('each kind is capped so one problem does not drown the list', () {
      final r = _build(hw: [for (var i = 1; i <= 8; i++) _hw('t$i', i)]);
      expect(
        r.attention
            .where((i) => i.kind == AttentionKind.overdueHomework)
            .length,
        3,
      );
      expect(r.overdue, 8);
    });
  });

  group('timeline', () {
    test('merges feedback, grades and attendance newest first', () {
      final r = _build(
        att: [
          _att('absent', 4, remarks: 'Sick'),
          _att('present', 1),
        ],
        hw: [_hw('Algebra', 3, done: true, marks: 9, feedback: 'Well done')],
        fb: [_fb(daysAgo: 2)],
      );
      expect(r.timeline.map((e) => e.kind), [
        EventKind.feedback,
        EventKind.graded,
        EventKind.absent,
      ]);
      expect(r.timeline.first.title, 'Feedback from Tahir Mughal');
      expect(r.timeline[1].subtitle, '9 / 10 (90%) · Well done');
      expect(r.timeline[1].positive, isTrue);
      expect(r.timeline.last.subtitle, 'Math · Sick');
    });

    test('shows when the parent replied last', () {
      final r = _build(fb: [_fb(teacherLast: false)]);
      expect(r.timeline.single.title, 'You replied');
      expect(r.timeline.single.isUnread, isFalse);
    });

    test('unread feedback is flagged and the tone is carried', () {
      final r = _build(
        fb: [_fb(unread: 1, tone: FeedbackTone.needsAttention)],
      );
      expect(r.timeline.single.isUnread, isTrue);
      expect(r.timeline.single.positive, isFalse);
    });

    test('present marks are not noise; future items are hidden', () {
      final r = _build(
        att: [_att('present', 1), _att('absent', -5)],
        hw: [_hw('future', -3, marks: 5)],
      );
      expect(r.timeline, isEmpty);
    });

    test('limited to the most recent 25', () {
      final r = _build(
        att: [for (var i = 1; i <= 40; i++) _att('absent', i)],
      );
      expect(r.timeline.length, 25);
      expect(r.timeline.first.at.isAfter(r.timeline.last.at), isTrue);
    });
  });

  test('hasAnyData', () {
    expect(_build().hasAnyData, isFalse);
    expect(_build(att: [_att('present', 1)]).hasAnyData, isTrue);
    expect(_build(fb: [_fb()]).hasAnyData, isTrue);
  });

  test('pending and overdue counts', () {
    final r = _build(
      hw: [_hw('late', 2), _hw('open', -3), _hw('done', 2, done: true)],
    );
    expect(r.overdue, 1);
    expect(r.pending, 1);
  });
}
