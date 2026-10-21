import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';

/// A part-of-whole figure such as "11 of 12 classes attended".
@immutable
class RatioStat {
  const RatioStat(this.part, this.whole);

  /// Nothing to measure yet.
  static const RatioStat empty = RatioStat(0, 0);

  final int part;
  final int whole;

  bool get hasData => whole > 0;

  /// Whole-number percentage, or `null` when there is no data. A child with
  /// no marked classes has no attendance, not 0 % attendance.
  int? get percent => whole == 0 ? null : (part * 100 / whole).round();

  @override
  bool operator ==(Object other) =>
      other is RatioStat && other.part == part && other.whole == whole;

  @override
  int get hashCode => Object.hash(part, whole);

  @override
  String toString() => 'RatioStat($part/$whole)';
}

/// Traffic-light band for a percentage.
enum StatBand {
  good,
  fair,
  poor,
  none
  ;

  static StatBand of(int? percent) {
    if (percent == null) return StatBand.none;
    if (percent >= 85) return StatBand.good;
    if (percent >= 70) return StatBand.fair;
    return StatBand.poor;
  }
}

/// The figures parents care about, computed from data the app already loads.
///
/// All three look at the same trailing [window] so the numbers are
/// comparable. Definitions (kept deliberately simple and explainable):
///
/// * **Attendance**: classes attended (present or late) out of classes that
///   were marked. Unmarked sessions are ignored.
/// * **Homework**: tasks handed in out of tasks whose deadline has passed.
///   Work not yet due is a to-do, not a miss.
/// * **Average score**: marks earned out of marks available on graded work.
class ProgressStats {
  const ProgressStats._();

  static const defaultWindow = Duration(days: 30);

  static RatioStat attendance(
    Iterable<ChildAttendanceRecord> records, {
    required DateTime now,
    Duration window = defaultWindow,
    bool includeToday = true,
  }) {
    var attended = 0;
    var marked = 0;
    for (final r in records) {
      if (!_inWindow(r.date, now, window, includeToday)) continue;
      switch (r.status) {
        case 'present' || 'late':
          attended++;
          marked++;
        case 'absent':
          marked++;
      }
    }
    return RatioStat(attended, marked);
  }

  static RatioStat homework(
    Iterable<ChildAssignment> assignments, {
    required DateTime now,
    Duration window = defaultWindow,
    bool includeToday = true,
  }) {
    var done = 0;
    var due = 0;
    for (final a in assignments) {
      if (!_inWindow(a.deadline, now, window, includeToday)) continue;
      if (a.isCompleted) {
        done++;
        due++;
      } else if (a.deadline.isBefore(now)) {
        due++;
      }
    }
    return RatioStat(done, due);
  }

  /// Marks earned / available over graded work.
  static RatioStat score(
    Iterable<ChildAssignment> assignments, {
    required DateTime now,
    Duration window = defaultWindow,
    bool includeToday = true,
  }) {
    var earned = 0;
    var available = 0;
    for (final a in assignments) {
      final marks = a.marks;
      if (marks == null || a.maxMarks <= 0) continue;
      if (!_inWindow(a.deadline, now, window, includeToday)) continue;
      earned += marks.clamp(0, a.maxMarks);
      available += a.maxMarks;
    }
    return RatioStat(earned, available);
  }

  /// Not handed in and past the deadline.
  static int overdue(Iterable<ChildAssignment> assignments, DateTime now) =>
      assignments
          .where((a) => !a.isCompleted && a.deadline.isBefore(now))
          .length;

  /// Not handed in and still open.
  static int pending(Iterable<ChildAssignment> assignments, DateTime now) =>
      assignments
          .where((a) => !a.isCompleted && !a.deadline.isBefore(now))
          .length;

  /// [includeToday] extends the window to the end of today so entries made
  /// later today count; earlier windows (previous period) stop exactly at
  /// their end so periods never overlap.
  static bool _inWindow(
    DateTime d,
    DateTime now,
    Duration window,
    bool includeToday,
  ) {
    final start = now.subtract(window);
    final end = includeToday ? now.add(const Duration(days: 1)) : now;
    return !d.isBefore(start) && d.isBefore(end);
  }
}
