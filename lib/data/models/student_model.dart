import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_model.freezed.dart';

/// Possible attendance states for a student in a given session.
enum AttendanceStatus { unmarked, present, absent, late }

@freezed
abstract class Student with _$Student {
  const factory Student({
    required String id,
    required String firstName,
    required String lastName,
    required String classGroupId,
    @Default('') String rollNo,
    @Default('') String avatarUrl,
  }) = _Student;
}
