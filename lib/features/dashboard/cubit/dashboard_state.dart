import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/institute_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';

part 'dashboard_state.freezed.dart';

enum DashboardView { month, agenda }

@freezed
sealed class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = DashboardInitial;
  const factory DashboardState.loading() = DashboardLoading;
  const factory DashboardState.loaded({
    required InstituteInfo institute,
    required UserModel user,
    required Session? liveSession,
    required List<Session> sessions,
    required List<ClassGroup> classes,
    required List<Subject> subjects,
    required DateTime focusDate,
    DateTime? selectedDate,
    @Default('') String query,
    @Default('') String dayFilter,
    @Default(<String>{}) Set<String> classFilterIds,
    @Default(<String>{}) Set<String> subjectFilterIds,
    @Default(DashboardView.month) DashboardView view,
  }) = DashboardLoaded;
  const factory DashboardState.error(String message) = DashboardError;
}
