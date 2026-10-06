import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_entry.freezed.dart';
part 'attendance_entry.g.dart';

/// One row of attendance for a particular (session, student). Stored
/// server-side; the mobile cubit builds and emits a draft of these before
/// hitting Submit.
@freezed
abstract class AttendanceEntry with _$AttendanceEntry {
  const factory AttendanceEntry({
    required String sessionId,
    required String studentId,
    @Default('unmarked') String status,
  }) = _AttendanceEntry;

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) =>
      _$AttendanceEntryFromJson(json);
}
