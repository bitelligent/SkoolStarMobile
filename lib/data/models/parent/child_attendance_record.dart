import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_attendance_record.freezed.dart';

/// One attendance mark for a pupil on a session.
@freezed
abstract class ChildAttendanceRecord with _$ChildAttendanceRecord {
  const factory ChildAttendanceRecord({
    required String childId,

    /// Day of the session (date only).
    required DateTime date,

    /// `present` | `absent` | `late` | `unmarked` (see
    /// `AttendanceStatusConfig`). Unknown server ids become `unmarked`.
    required String status,
    @Default('') String className,
    @Default('') String subjectName,

    /// `HH:mm`.
    @Default('') String startTime,
    @Default('') String endTime,
    String? remarks,
    String? occurrenceId,
  }) = _ChildAttendanceRecord;
}
