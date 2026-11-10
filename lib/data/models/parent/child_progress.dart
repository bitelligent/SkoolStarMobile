import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_progress.freezed.dart';

/// The school's all-time totals for one child (`children/progress`).
@freezed
abstract class ChildProgress with _$ChildProgress {
  const ChildProgress._();

  const factory ChildProgress({
    required String childId,

    /// Homework handed in / given, completed or not (deleted ones excluded).
    @Default(0) int completedAssignments,
    @Default(0) int totalAssignments,
    @Default(0) int totalResults,

    /// Mean of the exam scores; 0 when there are none.
    @Default(0) double averageScore,
  }) = _ChildProgress;

  bool get hasResults => totalResults > 0;

  /// Anything worth showing.
  bool get hasData => totalAssignments > 0 || totalResults > 0;
}

/// One exam result of a child (`children/results`).
@freezed
abstract class ExamResult with _$ExamResult {
  const factory ExamResult({
    required String examId,
    required String examName,
    required double score,
    String? remarks,
    DateTime? createdAt,
  }) = _ExamResult;
}
