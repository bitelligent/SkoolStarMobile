import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';

void main() {
  // Noon UTC, so the UTC and most local dates agree.
  final now = DateTime.utc(2026, 11, 4, 12);

  test('days are counted inclusively', () {
    expect(
      LeaveRules.daysBetween(DateTime(2026, 11, 4), DateTime(2026, 11, 6)),
      3,
    );
    expect(
      LeaveRules.daysBetween(DateTime(2026, 11, 4), DateTime(2026, 11, 4)),
      1,
    );
    expect(
      LeaveRules.daysBetween(DateTime(2026, 2, 27), DateTime(2026, 3, 2)),
      4,
    );
  });

  test("server today is the UTC date, not the phone's", () {
    // 23:30 UTC on 4 Nov is already 5 Nov in Pakistan; the server says 4th.
    final late = DateTime.utc(2026, 11, 4, 23, 30);
    expect(LeaveRules.serverToday(late), DateTime(2026, 11, 4));
    expect(LeaveRules.firstStart(late), DateTime(2026, 10, 28));
    expect(LeaveRules.lastEnd(late), DateTime(2027, 11, 4));
  });

  group('validateDates', () {
    String? v(DateTime s, DateTime e) =>
        LeaveRules.validateDates(s, e, now: now);

    test('a normal range is fine', () {
      expect(v(DateTime(2026, 11, 4), DateTime(2026, 11, 6)), isNull);
      expect(v(DateTime(2026, 11, 4), DateTime(2026, 11, 4)), isNull);
    });

    test('end before start', () {
      expect(
        v(DateTime(2026, 11, 6), DateTime(2026, 11, 4)),
        contains('End date'),
      );
    });

    test('31 days is the limit', () {
      expect(v(DateTime(2026, 11, 4), DateTime(2026, 12, 4)), isNull); // 31
      expect(
        v(DateTime(2026, 11, 4), DateTime(2026, 12, 5)),
        contains('31 days'),
      ); // 32
    });

    test('start may be at most 7 days back', () {
      expect(v(DateTime(2026, 10, 28), DateTime(2026, 10, 28)), isNull);
      expect(
        v(DateTime(2026, 10, 27), DateTime(2026, 10, 27)),
        contains('7 days'),
      );
    });

    test('end may be at most a year ahead', () {
      expect(v(DateTime(2027, 11, 4), DateTime(2027, 11, 4)), isNull);
      expect(
        v(DateTime(2027, 11, 4), DateTime(2027, 11, 5)),
        contains('a year'),
      );
    });
  });
}
