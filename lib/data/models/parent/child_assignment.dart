import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_assignment.freezed.dart';

/// Where an assignment stands from the parent's point of view.
///
/// `graded` is work the teacher marked that was never handed in through the
/// app: it has a grade, so it is neither pending nor overdue.
enum AssignmentStatus { pending, overdue, completed, graded }

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

  /// Still expected from the pupil: not handed in and not graded.
  bool get isOpen => !isCompleted && !isGraded;

  AssignmentStatus statusAt(DateTime now) {
    if (isCompleted) return AssignmentStatus.completed;
    if (isGraded) return AssignmentStatus.graded;
    return deadline.isBefore(now)
        ? AssignmentStatus.overdue
        : AssignmentStatus.pending;
  }
}
