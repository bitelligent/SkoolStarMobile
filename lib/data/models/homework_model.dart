import 'package:freezed_annotation/freezed_annotation.dart';

part 'homework_model.freezed.dart';

@freezed
abstract class HomeworkAttachment with _$HomeworkAttachment {
  const HomeworkAttachment._();

  const factory HomeworkAttachment({
    required String fileName,
    required int sizeKb,
    required String type,

    /// Server reference returned by the upload endpoint (empty until uploaded).
    @Default('') String reference,
  }) = _HomeworkAttachment;

  static const _imageTypes = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'heic',
  };

  /// Lower-case file extension, taken from [type] or the file name.
  String get extension {
    final t = type.toLowerCase();
    if (t.isNotEmpty) return t;
    final i = fileName.lastIndexOf('.');
    return i < 0 ? '' : fileName.substring(i + 1).toLowerCase();
  }

  /// True when [reference] points somewhere the file can be fetched from (a
  /// URL or a server path). A bare file name (older mobile uploads saved the
  /// original name instead of the stored path) has no location.
  bool get hasLocation {
    final ref = reference.trim();
    return ref.contains('/') || ref.contains(r'\');
  }

  bool get isImage => _imageTypes.contains(extension);
  bool get isPdf => extension == 'pdf';
}

/// Mirrors the web Create Homework form: tied to a session, one class and
/// one subject, required student multi-select, deadline + time, max marks
/// (0–100), and up to 5 attachments.
@freezed
abstract class Homework with _$Homework {
  const Homework._();

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

    /// Number of students the task is assigned to, when the server only sends
    /// a count (`totalAssigned`) and not their ids.
    @Default(0) int assignedCount,
    @Default([]) List<HomeworkAttachment> attachments,
  }) = _Homework;

  /// Students assigned, whichever of ids or count the server provided.
  int get studentTotal =>
      assignedStudentIds.isNotEmpty ? assignedStudentIds.length : assignedCount;
}
