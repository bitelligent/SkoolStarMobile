import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

/// Time range the Progress screen summarises.
enum ProgressPeriod {
  week('7 days', Duration(days: 7)),
  month('30 days', Duration(days: 30)),
  quarter('90 days', Duration(days: 90)),
  all('All time', Duration(days: 3650))
  ;

  const ProgressPeriod(this.label, this.window);

  final String label;
  final Duration window;

  /// "All time" has nothing earlier to compare with.
  bool get hasPrevious => this != ProgressPeriod.all;
}

/// A figure with how it moved against the previous equal period.
@immutable
class TrendStat {
  const TrendStat(this.current, this.previous);

  final RatioStat current;
  final RatioStat? previous;

  /// Change in percentage points, or `null` when either period has no data.
  int? get delta {
    final now = current.percent;
    final before = previous?.percent;
    if (now == null || before == null) return null;
    return now - before;
  }
}

/// One week's attendance and homework completion for the trend chart.
@immutable
class WeekPoint {
  const WeekPoint({
    required this.start,
    required this.attendance,
    required this.homework,
  });

  /// First day of the 7-day bucket.
  final DateTime start;
  final RatioStat attendance;
  final RatioStat homework;
}

@immutable
class SubjectScore {
  const SubjectScore(this.subject, this.score);

  final String subject;
  final RatioStat score;
}

enum AttentionKind { overdueHomework, absence, lowScore, newFeedback }

/// Where tapping a report row should lead.
enum LinkTarget { assignments, attendance, feedbackThread }

@immutable
class ReportLink {
  const ReportLink(this.target, {this.threadId});

  final LinkTarget target;

  /// For [LinkTarget.feedbackThread].
  final String? threadId;
}

@immutable
class AttentionItem {
  const AttentionItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.link,
  });

  final AttentionKind kind;
  final String title;
  final String subtitle;
  final ReportLink link;
}

enum EventKind { feedback, graded, absent, late }

/// One line of the activity timeline.
@immutable
class TimelineEvent {
  const TimelineEvent({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.at,
    required this.link,
    this.positive,
    this.isUnread = false,
  });

  final EventKind kind;
  final String title;
  final String subtitle;
  final DateTime at;
  final ReportLink link;

  /// `true` good news, `false` needs attention, `null` neutral.
  final bool? positive;
  final bool isUnread;
}

/// A feedback conversation with the thread it lives in.
@immutable
class FeedbackEntry {
  const FeedbackEntry(this.threadId, this.topic);

  final String threadId;
  final FeedbackTopic topic;
}

/// Everything the Progress screen shows, derived from raw data (pure, so it
/// is unit-testable and recomputed cheaply when the period changes).
@immutable
class ProgressReport {
  const ProgressReport({
    required this.period,
    required this.attendance,
    required this.homework,
    required this.score,
    required this.weeks,
    required this.subjects,
    required this.attention,
    required this.timeline,
    required this.overdue,
    required this.pending,
  });

  factory ProgressReport.build({
    required ProgressPeriod period,
    required DateTime now,
    required List<ChildAttendanceRecord> attendance,
    required List<ChildAssignment> assignments,
    required List<FeedbackEntry> feedback,
    int weekCount = 8,
  }) {
    final window = period.window;
    TrendStat trend(
      RatioStat Function(DateTime now, bool includeToday) compute,
    ) => TrendStat(
      compute(now, true),
      period.hasPrevious ? compute(now.subtract(window), false) : null,
    );

    final att = trend(
      (n, today) => ProgressStats.attendance(
        attendance,
        now: n,
        window: window,
        includeToday: today,
      ),
    );
    final hw = trend(
      (n, today) => ProgressStats.homework(
        assignments,
        now: n,
        window: window,
        includeToday: today,
      ),
    );
    final score = trend(
      (n, today) => ProgressStats.score(
        assignments,
        now: n,
        window: window,
        includeToday: today,
      ),
    );

    return ProgressReport(
      period: period,
      attendance: att,
      homework: hw,
      score: score,
      weeks: _weeks(now, attendance, assignments, weekCount),
      subjects: _subjects(now, window, assignments),
      attention: _attention(now, attendance, assignments, feedback),
      timeline: _timeline(now, attendance, assignments, feedback),
      overdue: ProgressStats.overdue(assignments, now),
      pending: ProgressStats.pending(assignments, now),
    );
  }

  final ProgressPeriod period;
  final TrendStat attendance;
  final TrendStat homework;
  final TrendStat score;

  /// Oldest first.
  final List<WeekPoint> weeks;

  /// Best first.
  final List<SubjectScore> subjects;
  final List<AttentionItem> attention;

  /// Newest first.
  final List<TimelineEvent> timeline;
  final int overdue;
  final int pending;

  bool get hasAnyData =>
      attendance.current.hasData ||
      homework.current.hasData ||
      score.current.hasData ||
      timeline.isNotEmpty;

  // ─── builders ───────────────────────────────────────────────────────

  static List<WeekPoint> _weeks(
    DateTime now,
    List<ChildAttendanceRecord> attendance,
    List<ChildAssignment> assignments,
    int count,
  ) {
    const week = Duration(days: 7);
    return [
      for (var i = count - 1; i >= 0; i--)
        () {
          final end = now.subtract(week * i);
          return WeekPoint(
            start: end.subtract(week),
            attendance: ProgressStats.attendance(
              attendance,
              now: end,
              window: week,
              includeToday: i == 0,
            ),
            homework: ProgressStats.homework(
              assignments,
              now: end,
              window: week,
              includeToday: i == 0,
            ),
          );
        }(),
    ];
  }

  static List<SubjectScore> _subjects(
    DateTime now,
    Duration window,
    List<ChildAssignment> assignments,
  ) {
    final earned = <String, int>{};
    final available = <String, int>{};
    for (final a in assignments) {
      final marks = a.marks;
      if (marks == null || a.maxMarks <= 0) continue;
      if (a.deadline.isBefore(now.subtract(window)) ||
          !a.deadline.isBefore(now.add(const Duration(days: 1)))) {
        continue;
      }
      final subject = a.subjectName.trim().isEmpty ? 'Other' : a.subjectName;
      earned[subject] = (earned[subject] ?? 0) + marks.clamp(0, a.maxMarks);
      available[subject] = (available[subject] ?? 0) + a.maxMarks;
    }
    return [
      for (final s in available.keys)
        SubjectScore(s, RatioStat(earned[s] ?? 0, available[s]!)),
    ]..sort((a, b) => (b.score.percent ?? 0).compareTo(a.score.percent ?? 0));
  }

  static String _day(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  static List<AttentionItem> _attention(
    DateTime now,
    List<ChildAttendanceRecord> attendance,
    List<ChildAssignment> assignments,
    List<FeedbackEntry> feedback,
  ) {
    const maxPerKind = 3;
    final items = <AttentionItem>[];

    final overdue =
        assignments.where((a) => a.isOpen && a.deadline.isBefore(now)).toList()
          ..sort((a, b) => b.deadline.compareTo(a.deadline));
    for (final a in overdue.take(maxPerKind)) {
      items.add(
        AttentionItem(
          kind: AttentionKind.overdueHomework,
          title: 'Overdue: ${a.title}',
          subtitle: [
            'Was due ${_day(a.deadline)}',
            if (a.subjectName.isNotEmpty) a.subjectName,
          ].join(' · '),
          link: const ReportLink(LinkTarget.assignments),
        ),
      );
    }

    final recent = now.subtract(const Duration(days: 14));
    final absences =
        attendance
            .where((r) => r.status == 'absent' && !r.date.isBefore(recent))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    for (final r in absences.take(maxPerKind)) {
      items.add(
        AttentionItem(
          kind: AttentionKind.absence,
          title: 'Absent on ${_day(r.date)}',
          subtitle: r.subjectName.isEmpty ? 'Class missed' : r.subjectName,
          link: const ReportLink(LinkTarget.attendance),
        ),
      );
    }

    final low = assignments.where((a) {
      final m = a.marks;
      return m != null &&
          a.maxMarks > 0 &&
          m * 100 / a.maxMarks < 60 &&
          !a.deadline.isBefore(now.subtract(const Duration(days: 30)));
    }).toList()..sort((a, b) => b.deadline.compareTo(a.deadline));
    for (final a in low.take(maxPerKind)) {
      items.add(
        AttentionItem(
          kind: AttentionKind.lowScore,
          title: 'Low score: ${a.title}',
          subtitle:
              '${a.marks} / ${a.maxMarks}'
              '${a.subjectName.isEmpty ? '' : ' · ${a.subjectName}'}',
          link: const ReportLink(LinkTarget.assignments),
        ),
      );
    }

    for (final f in feedback) {
      final unread = f.topic.unreadFromTeacher;
      if (unread == 0) continue;
      items.add(
        AttentionItem(
          kind: AttentionKind.newFeedback,
          title: 'New feedback: ${f.topic.subject}',
          subtitle: unread == 1
              ? '1 unread message'
              : '$unread unread messages',
          link: ReportLink(LinkTarget.feedbackThread, threadId: f.threadId),
        ),
      );
    }

    // Unread feedback first (needs a reply), then the rest as built.
    items.sort((a, b) {
      int rank(AttentionItem i) => i.kind == AttentionKind.newFeedback ? 0 : 1;
      return rank(a).compareTo(rank(b));
    });
    return items;
  }

  static List<TimelineEvent> _timeline(
    DateTime now,
    List<ChildAttendanceRecord> attendance,
    List<ChildAssignment> assignments,
    List<FeedbackEntry> feedback,
  ) {
    final events = <TimelineEvent>[];

    for (final f in feedback) {
      final t = f.topic;
      if (t.messages.isEmpty) continue;
      final last = t.messages.last;
      final byTeacher = last.fromTeacher;
      events.add(
        TimelineEvent(
          kind: EventKind.feedback,
          title: byTeacher
              ? (last.senderName.isEmpty
                    ? 'Feedback from the teacher'
                    : 'Feedback from ${last.senderName}')
              : 'You replied',
          subtitle: last.content,
          at: t.lastActivityAt,
          link: ReportLink(LinkTarget.feedbackThread, threadId: f.threadId),
          positive: t.tone == FeedbackTone.positive
              ? true
              : t.tone == FeedbackTone.needsAttention
              ? false
              : null,
          isUnread: t.unreadFromTeacher > 0,
        ),
      );
    }

    for (final a in assignments) {
      final marks = a.marks;
      if (marks == null) continue;
      final pct = a.maxMarks > 0 ? (marks * 100 / a.maxMarks).round() : null;
      events.add(
        TimelineEvent(
          kind: EventKind.graded,
          title: 'Homework graded: ${a.title}',
          subtitle: [
            '$marks / ${a.maxMarks}${pct == null ? '' : ' ($pct%)'}',
            if ((a.feedback ?? '').trim().isNotEmpty) a.feedback!.trim(),
          ].join(' · '),
          at: a.completedAt ?? a.deadline,
          link: const ReportLink(LinkTarget.assignments),
          positive: pct == null
              ? null
              : (pct >= 70
                    ? true
                    : pct < 50
                    ? false
                    : null),
        ),
      );
    }

    for (final r in attendance) {
      if (r.status != 'absent' && r.status != 'late') continue;
      final absent = r.status == 'absent';
      events.add(
        TimelineEvent(
          kind: absent ? EventKind.absent : EventKind.late,
          title: absent ? 'Marked absent' : 'Arrived late',
          subtitle: [
            if (r.subjectName.isNotEmpty) r.subjectName,
            if ((r.remarks ?? '').trim().isNotEmpty) r.remarks!.trim(),
          ].join(' · '),
          at: r.date,
          link: const ReportLink(LinkTarget.attendance),
          positive: false,
        ),
      );
    }

    events
      ..removeWhere((e) => e.at.isAfter(now.add(const Duration(days: 1))))
      ..sort((a, b) => b.at.compareTo(a.at));
    return events.take(25).toList();
  }
}
