/// Maps the app's attendance states to backend `statusId` values.
///
/// Mirrors the backend's `AttendanceStatusId` enum (confirmed by the backend
/// team): Present = 1, Absent = 2, Late = 3. The backend enum also defines
/// Excused = 4, but neither web nor mobile uses it yet, so it is intentionally
/// not handled here. Unknown/`null` ids from the server are shown as
/// "unmarked".
class AttendanceStatusConfig {
  AttendanceStatusConfig._();

  static const int presentId = 1;
  static const int absentId = 2;
  static const int lateId = 3;

  static const String unmarked = 'unmarked';
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';

  /// Server id → UI status key.
  static String fromId(int? id) => switch (id) {
    presentId => present,
    absentId => absent,
    lateId => late,
    _ => unmarked,
  };

  /// UI status key → server id (`null` for unmarked: it is never submitted).
  static int? toId(String status) => switch (status) {
    present => presentId,
    absent => absentId,
    late => lateId,
    _ => null,
  };
}
