import 'package:freezed_annotation/freezed_annotation.dart';

part 'homework_model.freezed.dart';
part 'homework_model.g.dart';

@freezed
abstract class HomeworkAttachment with _$HomeworkAttachment {
  const factory HomeworkAttachment({
    required String fileName,
    required int sizeKb,
    required String type,
  }) = _HomeworkAttachment;

  factory HomeworkAttachment.fromJson(Map<String, dynamic> json) =>
      _$HomeworkAttachmentFromJson(json);
}

/// Mirrors the web Create Homework form: tied to a session, one class and
/// one subject, required student multi-select, deadline + time, max marks
/// (0–100), and up to 5 attachments.
@freezed
abstract class Homework with _$Homework {
  const factory Homework({
    required String id,
    required String sessionId,
    required String classId,
    required String subjectId,
    required String title,
    required String description,
    required DateTime deadline,
    @Default(100) int maxMarks,
    @Default([]) List<String> assignedStudentIds,
    @Default([]) List<HomeworkAttachment> attachments,
  }) = _Homework;

  factory Homework.fromJson(Map<String, dynamic> json) =>
      _$HomeworkFromJson(json);
}
