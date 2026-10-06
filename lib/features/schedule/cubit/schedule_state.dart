import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

part 'schedule_state.freezed.dart';

@freezed
sealed class ScheduleState with _$ScheduleState {
  const factory ScheduleState.initial() = ScheduleInitial;
  const factory ScheduleState.loading() = ScheduleLoading;
  const factory ScheduleState.loaded({
    required List<Session> sessions,
    required List<ClassGroup> classes,
    required List<Subject> subjects,
    DateTime? dateFilter,
    @Default(<String>{}) Set<String> classFilterIds,
    @Default(<String>{}) Set<String> subjectFilterIds,
  }) = ScheduleLoaded;
  const factory ScheduleState.error(String message) = ScheduleError;
}
