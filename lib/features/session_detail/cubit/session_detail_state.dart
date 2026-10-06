import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

part 'session_detail_state.freezed.dart';

@freezed
sealed class SessionDetailState with _$SessionDetailState {
  const factory SessionDetailState.initial() = SessionDetailInitial;
  const factory SessionDetailState.loading() = SessionDetailLoading;
  const factory SessionDetailState.loaded({
    required Session session,
    required List<ClassGroup> classes,
    required List<Subject> subjects,
    required List<Student> students,
    required Map<String, String> attendance,
    required List<Homework> homeworks,
    required List<FeedbackMessage> feedbackMessages,
    required List<AssignmentReview> assignmentReviews,
    @Default('') String studentSearch,
    @Default('') String activeClassFilter,
    @Default(false) bool attendanceSubmitting,
  }) = SessionDetailLoaded;
  const factory SessionDetailState.error(String message) = SessionDetailError;
}
