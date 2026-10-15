import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_assignment.freezed.dart';

/// Where an assignment stands from the parent's point of view.
enum AssignmentStatus { pending, overdue, completed }

/// A homework task assigned to a pupil, with the teacher's review if any.
@freezed
abstract class ChildAssignment with _$ChildAssignment {
  const ChildAssignment._();

  const factory ChildAssignment({
    required String id,
    required String childId,
    required String title,
    required DateTime deadline,
    @Default('') String description,
    @Default(100) int maxMarks,
    @Default(false) bool isCompleted,
    DateTime? completedAt,

    /// Teacher's review comment and marks, once graded.
    String? feedback,
    int? marks,
    DateTime? sessionDate,
    @Default('') String className,
    @Default('') String subjectName,
    String? occurrenceId,
  }) = _ChildAssignment;

  bool get isGraded => marks != null;

  AssignmentStatus statusAt(DateTime now) {
    if (isCompleted) return AssignmentStatus.completed;
    return deadline.isBefore(now)
        ? AssignmentStatus.overdue
        : AssignmentStatus.pending;
  }
}
