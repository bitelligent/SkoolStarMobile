import 'package:freezed_annotation/freezed_annotation.dart';

part 'subject_model.freezed.dart';
part 'subject_model.g.dart';

/// A teaching topic (eg. "Computer", "English", "Math"). A single [Session]
/// may bundle several of these together, matching the web product.
@freezed
abstract class Subject with _$Subject {
  const factory Subject({
    required String id,
    required String name,
    @Default('#2563EB') String colorHex,
  }) = _Subject;

  factory Subject.fromJson(Map<String, dynamic> json) =>
      _$SubjectFromJson(json);
}
