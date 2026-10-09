import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';

/// Splits "Irha Shahzadi" into first / last name. The API only has a full
/// name; everything after the first word is treated as the surname.
({String first, String last}) splitName(String fullName) {
  final name = fullName.trim();
  final i = name.indexOf(' ');
  return i < 0
      ? (first: name, last: '')
      : (first: name.substring(0, i), last: name.substring(i + 1).trim());
}

Student? studentFromAttendanceRow(
  Json row, {
  required String fallbackClassId,
  required Map<String, String> classIdByName,
}) {
  final id = row.intOrNull('studentId');
  if (id == null) return null;
  final name = splitName(row.str('studentName'));
  return Student(
    id: '$id',
    firstName: name.first,
    lastName: name.last,
    classGroupId: classIdByName[row.str('className')] ?? fallbackClassId,
  );
}
