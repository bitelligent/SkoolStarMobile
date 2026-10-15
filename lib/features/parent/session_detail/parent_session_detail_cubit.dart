import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';

part 'parent_session_detail_cubit.freezed.dart';

@freezed
sealed class ParentSessionDetailState with _$ParentSessionDetailState {
  const factory ParentSessionDetailState.loading() = ParentSessionLoading;
  const factory ParentSessionDetailState.notFound() = ParentSessionNotFound;
  const factory ParentSessionDetailState.error(String message) =
      ParentSessionError;
  const factory ParentSessionDetailState.loaded({
    required Child child,
    required Session session,
    required List<Subject> subjects,
    required List<ClassGroup> classes,

    /// Attendance mark for this session, `null` when not marked yet.
    ChildAttendanceRecord? attendance,
    @Default(<ChildAssignment>[]) List<ChildAssignment> assignments,
  }) = ParentSessionLoaded;
}

/// Read-only detail of one session of one child. The child is fixed for the
/// lifetime of the screen (the switcher lives on the tab screens).
class ParentSessionDetailCubit extends Cubit<ParentSessionDetailState> {
  ParentSessionDetailCubit({
    required this.child,
    required this.sessionId,
    required ChildScheduleRepository schedule,
    required ChildAttendanceRepository attendance,
    required ChildAssignmentsRepository assignments,
  }) : _schedule = schedule,
       _attendance = attendance,
       _assignments = assignments,
       super(const ParentSessionDetailState.loading());

  final Child child;
  final String sessionId;
  final ChildScheduleRepository _schedule;
  final ChildAttendanceRepository _attendance;
  final ChildAssignmentsRepository _assignments;

  Future<void> load() async {
    emit(const ParentSessionDetailState.loading());
    try {
      final session = await _schedule.getById(child.id, sessionId);
      if (isClosed) return;
      if (session == null) {
        emit(const ParentSessionDetailState.notFound());
        return;
      }

      // Names for subjects/classes come with that day's schedule.
      final names = (await _schedule.getBetween(
        child.id,
        session.date,
        session.date,
      )).withClass(child.className);
      final records = await _safe(() => _attendance.getForChild(child.id));
      final tasks = await _safe(() => _assignments.getForChild(child.id));
      if (isClosed) return;

      emit(
        ParentSessionDetailState.loaded(
          child: child,
          session: session.copyWith(
            classIds: names.classes.isEmpty
                ? const []
                : [names.classes.first.id],
          ),
          subjects: names.subjects,
          classes: names.classes,
          attendance: records
              ?.where((r) => r.occurrenceId == session.id)
              .firstOrNull,
          assignments:
              tasks?.where((a) => a.occurrenceId == session.id).toList() ??
              const [],
        ),
      );
    } on Object catch (e, st) {
      if (!isClosed) emit(ParentSessionDetailState.error(errorMessage(e, st)));
    }
  }

  /// Attendance and homework are extras: the session still shows without them.
  Future<T?> _safe<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on Object {
      return null;
    }
  }
}
