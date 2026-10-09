import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';

/// Tolerant mapping for `TeacherModule/feedback/conversations` rows (the live
/// server had none when this was written).
FeedbackMessage? feedbackFromConversation(Json j, {required String sessionId}) {
  final id = j.strOrNull('feedbackId') ?? j.strOrNull('id');
  final message = j.strOrNull('content') ?? j.strOrNull('message');
  final studentId = j.strOrNull('studentId');
  if (id == null || message == null || studentId == null) return null;
  return FeedbackMessage(
    id: id,
    sessionId: sessionId,
    studentIds: [studentId],
    message: message,
    isPositive: j.boolean('isPositive', fallback: true),
    sentAt: j.dateOrNull('createdAt') ?? j.dateOrNull('sentAt'),
  );
}

/// `feedback/task/{id}/students` rows that have been graded.
AssignmentReview? reviewFromTaskStudent(
  Json j, {
  required String sessionId,
  required String taskId,
}) {
  final studentId = j.strOrNull('studentId');
  final marks = j.intOrNull('marks');
  if (studentId == null || marks == null) return null;
  return AssignmentReview(
    id: '${taskId}_$studentId',
    sessionId: sessionId,
    homeworkId: taskId,
    studentId: studentId,
    marks: marks,
    reviewText: j.str('review'),
    reviewedAt: j.dateOrNull('completedAt'),
  );
}
