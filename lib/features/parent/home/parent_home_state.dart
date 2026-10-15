import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/utils/day_filter.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

part 'parent_home_state.freezed.dart';

enum ParentHomeView { month, agenda }

@freezed
sealed class ParentHomeState with _$ParentHomeState {
  const factory ParentHomeState.initial() = ParentHomeInitial;
  const factory ParentHomeState.loading() = ParentHomeLoading;
  const factory ParentHomeState.error(String message) = ParentHomeError;

  const factory ParentHomeState.loaded({
    required Child child,
    required List<Session> sessions,
    required List<Subject> subjects,
    required List<ClassGroup> classes,
    required DateTime focusDate,

    /// Assignments not completed / attendance counts for the stat tiles.
    /// `null` when that part failed to load (the tile is hidden).
    int? pendingAssignments,
    int? presentCount,
    int? attendanceTotal,
    DateTime? selectedDate,
    @Default('') String query,
    @Default(defaultDayFilter) String dayFilter,
    @Default(<String>{}) Set<String> subjectFilterIds,
    @Default(<String>{}) Set<String> teacherFilterIds,
    @Default(ParentHomeView.agenda) ParentHomeView view,
  }) = ParentHomeLoaded;
}
