import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

final _now = DateTime(2026, 10, 20, 12);

ChildAttendanceRecord _att(String status, {int daysAgo = 1}) =>
    ChildAttendanceRecord(
      childId: '1',
      date: _now.subtract(Duration(days: daysAgo)),
      status: status,
    );

ChildAssignment _hw({
  int deadlineInDays = -1,
  bool done = false,
  int? marks,
  int max = 100,
}) => ChildAssignment(
  id: '${deadlineInDays}_$done$marks',
  childId: '1',
  title: 't',
  deadline: _now.add(Duration(days: deadlineInDays)),
  isCompleted: done,
  marks: marks,
  maxMarks: max,
);

void main() {
  group('RatioStat', () {
    test('rounds to a whole percent', () {
      expect(const RatioStat(11, 12).percent, 92);
      expect(const RatioStat(1, 3).percent, 33);
      expect(const RatioStat(2, 3).percent, 67);
    });

    test('no data is null, not zero', () {
      expect(RatioStat.empty.percent, isNull);
      expect(RatioStat.empty.hasData, isFalse);
      expect(const RatioStat(0, 5).percent, 0);
    });
  });

  group('StatBand', () {
    test('thresholds', () {
      expect(StatBand.of(null), StatBand.none);
      expect(StatBand.of(100), StatBand.good);
      expect(StatBand.of(85), StatBand.good);
      expect(StatBand.of(84), StatBand.fair);
      expect(StatBand.of(70), StatBand.fair);
      expect(StatBand.of(69), StatBand.poor);
      expect(StatBand.of(0), StatBand.poor);
    });
  });

  group('attendance', () {
    test('present and late count as attended; absent as missed', () {
      final r = ProgressStats.attendance([
        _att('present'),
        _att('late'),
        _att('absent'),
        _att('present'),
      ], now: _now);
      expect(r, const RatioStat(3, 4));
    });

    test('unmarked sessions are ignored', () {
      final r = ProgressStats.attendance([
        _att('present'),
        _att('unmarked'),
        _att('unmarked'),
      ], now: _now);
      expect(r, const RatioStat(1, 1));
    });

    test('only the trailing window counts', () {
      final r = ProgressStats.attendance([
        _att('absent', daysAgo: 45),
        _att('present', daysAgo: 29),
        _att('present', daysAgo: 0),
      ], now: _now);
      expect(r, const RatioStat(2, 2));
    });

    test('a wider window includes older records', () {
      final r = ProgressStats.attendance(
        [_att('absent', daysAgo: 45), _att('present')],
        now: _now,
        window: const Duration(days: 90),
      );
      expect(r, const RatioStat(1, 2));
    });

    test('nothing marked gives no data', () {
      expect(
        ProgressStats.attendance([_att('unmarked')], now: _now),
        RatioStat.empty,
      );
      expect(ProgressStats.attendance([], now: _now), RatioStat.empty);
    });
  });

  group('homework', () {
    test('handed in out of those already due', () {
      final r = ProgressStats.homework([
        _hw(deadlineInDays: -2, done: true),
        _hw(deadlineInDays: -3),
        _hw(deadlineInDays: -4, done: true),
      ], now: _now);
      expect(r, const RatioStat(2, 3));
    });

    test('work not yet due is not a miss', () {
      final r = ProgressStats.homework([
        _hw(deadlineInDays: -2, done: true),
        _hw(deadlineInDays: 3),
      ], now: _now);
      expect(r, const RatioStat(1, 1));
    });

    test('handed in early counts even before the deadline', () {
      final r = ProgressStats.homework([
        _hw(deadlineInDays: 0, done: true),
      ], now: _now);
      expect(r, const RatioStat(1, 1));
    });

    test('old tasks fall outside the window', () {
      final r = ProgressStats.homework([
        _hw(deadlineInDays: -60),
        _hw(deadlineInDays: -2, done: true),
      ], now: _now);
      expect(r, const RatioStat(1, 1));
    });
  });

  group('score', () {
    test('marks earned over marks available, weighted by size', () {
      final r = ProgressStats.score([
        _hw(marks: 8, max: 10),
        _hw(deadlineInDays: -2, marks: 40, max: 50),
      ], now: _now);
      expect(r, const RatioStat(48, 60));
      expect(r.percent, 80);
    });

    test('ungraded work is excluded', () {
      final r = ProgressStats.score([
        _hw(),
        _hw(deadlineInDays: -2, marks: 5, max: 10),
      ], now: _now);
      expect(r, const RatioStat(5, 10));
    });

    test('out-of-range marks are clamped; zero-max is skipped', () {
      final r = ProgressStats.score([
        _hw(marks: 120, max: 100),
        _hw(deadlineInDays: -2, marks: 5, max: 0),
      ], now: _now);
      expect(r, const RatioStat(100, 100));
    });

    test('no graded work gives no data', () {
      expect(ProgressStats.score([_hw()], now: _now), RatioStat.empty);
    });
  });

  test('overdue and pending counts', () {
    final list = [
      _hw(deadlineInDays: -1),
      _hw(deadlineInDays: -9),
      _hw(deadlineInDays: -2, done: true),
      _hw(deadlineInDays: 2),
      _hw(deadlineInDays: 5),
    ];
    expect(ProgressStats.overdue(list, _now), 2);
    expect(ProgressStats.pending(list, _now), 2);
  });

  group('upcomingWhenLabel', () {
    final base = DateTime(2026, 10, 20, 12);

    test('today counts down, later days name only the day', () {
      expect(
        upcomingWhenLabel(base.add(const Duration(seconds: 20)), base),
        'Starting now',
      );
      expect(
        upcomingWhenLabel(base.add(const Duration(minutes: 25)), base),
        'In 25 min',
      );
      expect(
        upcomingWhenLabel(base.add(const Duration(hours: 3)), base),
        'In 3 h',
      );
      expect(
        upcomingWhenLabel(
          base.add(const Duration(hours: 3, minutes: 15)),
          base,
        ),
        'In 3 h 15 min',
      );
      expect(
        upcomingWhenLabel(DateTime(2026, 10, 21, 14, 30), base),
        'Tomorrow',
      );
      expect(upcomingWhenLabel(DateTime(2026, 10, 23, 9), base), 'Friday');
      expect(upcomingWhenLabel(DateTime(2026, 11, 5, 9), base), 'Nov 5');
      expect(
        upcomingWhenLabel(base.subtract(const Duration(minutes: 5)), base),
        'Starting now',
      );
    });

    test('never repeats the clock time (the row shows it once)', () {
      for (final d in [
        DateTime(2026, 10, 20, 15, 30),
        DateTime(2026, 10, 21, 14, 30),
        DateTime(2026, 10, 24, 14, 30),
        DateTime(2026, 12, 1, 14, 30),
      ]) {
        final label = upcomingWhenLabel(d, base);
        expect(label, isNot(contains(':')), reason: label);
        expect(label, isNot(contains('PM')), reason: label);
        expect(label, isNot(contains('AM')), reason: label);
      }
    });
  });
}
