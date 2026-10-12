import 'package:freezed_annotation/freezed_annotation.dart';

part 'class_group.freezed.dart';

/// A group of students (eg. "Class 1", "Class 2"). In the web product a
/// Class is a cohort — NOT a subject.
@freezed
abstract class ClassGroup with _$ClassGroup {
  const factory ClassGroup({
    required String id,
    required String name,
    @Default(0) int studentCount,
    @Default('#2563EB') String colorHex,
  }) = _ClassGroup;
}
