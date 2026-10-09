import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';

/// Where a session is in time. `cancelled` covers any non-scheduled status.
enum SessionPhase { upcoming, laterToday, live, ended, cancelled }

/// One scheduled occurrence of a class slot (a single teaching session).
@freezed
abstract class Session with _$Session {
  const Session._();

  const factory Session({
    /// The occurrence's public GUID. Used for routing and API lookups.
    required String id,
    required DateTime date,

    /// `HH:mm`, local time.
    required String startTime,
    required String endTime,
    required List<String> classIds,
    required List<String> subjectIds,
    required String teacherId,

    /// Cancelled / otherwise not open for editing.
    @Default(false) bool isLocked,

    /// Numeric occurrence id and parent schedule id, required by the
    /// attendance / homework / feedback endpoints.
    @Default(0) int occurrenceId,
    @Default(0) int scheduleId,
    int? sectionId,
  }) = _Session;

  DateTime get startsAt => _at(startTime);
  DateTime get endsAt => _at(endTime);

  /// End of the session, pushed to the next day when it crosses midnight.
  DateTime get _effectiveEnd {
    final end = endsAt;
    return end.isAfter(startsAt) ? end : end.add(const Duration(days: 1));
  }

  /// True while the current time is inside the session window. Evaluated on
  /// read so it never goes stale.
  bool get isLive => phaseAt(DateTime.now()) == SessionPhase.live;

  /// Where the session is in time relative to [now].
  SessionPhase phaseAt(DateTime now) {
    if (isLocked) return SessionPhase.cancelled;
    if (!now.isBefore(_effectiveEnd)) return SessionPhase.ended;
    if (!now.isBefore(startsAt)) return SessionPhase.live;
    final sameDay =
        now.year == date.year && now.month == date.month && now.day == date.day;
    return sameDay ? SessionPhase.laterToday : SessionPhase.upcoming;
  }

  DateTime _at(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    final m = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, h, m);
  }
}
