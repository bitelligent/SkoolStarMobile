import 'package:freezed_annotation/freezed_annotation.dart';

part 'session_model.freezed.dart';
part 'session_model.g.dart';

/// A scheduled teaching slot. Mirrors the web product: a Session can bundle
/// multiple Classes (groups of students) AND multiple Subjects taught at
/// once by one teacher during one time window.
@freezed
abstract class Session with _$Session {
  const factory Session({
    required String id,
    required DateTime date,
    required String startTime,
    required String endTime,
    required List<String> classIds,
    required List<String> subjectIds,
    required String teacherId,
    @Default(false) bool isLive,
    @Default(false) bool isLocked,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
