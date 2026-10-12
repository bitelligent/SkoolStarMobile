import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_model.freezed.dart';

/// Message sent to one or more parents (the web screen is the "General
/// Feedback" block). [isPositive] drives the toggle shown in the UI.
@freezed
abstract class FeedbackMessage with _$FeedbackMessage {
  const factory FeedbackMessage({
    required String id,
    required String sessionId,
    required List<String> studentIds,
    required String message,
    @Default(true) bool isPositive,
    DateTime? sentAt,
  }) = _FeedbackMessage;
}

/// A graded review for one homework-student pair (the "Assignment Review
/// and Marks" block on the web).
@freezed
abstract class AssignmentReview with _$AssignmentReview {
  const factory AssignmentReview({
    required String id,
    required String sessionId,
    required String homeworkId,
    required String studentId,
    required int marks,
    required String reviewText,
    DateTime? reviewedAt,
  }) = _AssignmentReview;
}
