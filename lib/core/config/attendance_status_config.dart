/// Maps the app's attendance states to backend `statusId` values.
///
/// Mirrors the backend's `AttendanceStatusId` enum (confirmed by the backend
/// team): Present = 1, Absent = 2, Late = 3. The backend enum also defines
/// Excused = 4, a mark only the school makes. The teacher marking flow never
/// sets or shows it; parents see it (see [fromId]'s `withExcused`).
/// Unknown/`null` ids from the server are shown as "unmarked".
class AttendanceStatusConfig {
  AttendanceStatusConfig._();

  static const int presentId = 1;
  static const int absentId = 2;
  static const int lateId = 3;
  static const int excusedId = 4;

  static const String unmarked = 'unmarked';
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';
  static const String excused = 'excused';

  /// Server id → UI status key. [withExcused] keeps the school's Excused
  /// mark instead of folding it into "unmarked".
  static String fromId(int? id, {bool withExcused = false}) => switch (id) {
    presentId => present,
    absentId => absent,
    lateId => late,
    excusedId when withExcused => excused,
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
