import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_scoped_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_report.dart';

part 'parent_progress_cubit.freezed.dart';

@freezed
sealed class ParentProgressState with _$ParentProgressState {
  const factory ParentProgressState.initial() = ParentProgressInitial;
  const factory ParentProgressState.loading() = ParentProgressLoading;
  const factory ParentProgressState.error(String message) = ParentProgressError;

  const factory ParentProgressState.loaded({
    required Child child,
    required List<ChildAttendanceRecord> attendance,
    required List<ChildAssignment> assignments,
    required List<FeedbackEntry> feedback,
    @Default(ProgressPeriod.month) ProgressPeriod period,

    /// Some sources could not be loaded; what is shown may be incomplete.
    @Default(false) bool partial,
  }) = ParentProgressLoaded;
}

/// Progress report for the selected child: attendance, homework, grades and
/// teacher feedback, with the figures recomputed when the period changes.
class ParentProgressCubit extends ChildScopedCubit<ParentProgressState> {
  ParentProgressCubit({
    required ChildrenCubit children,
    required ChildAttendanceRepository attendance,
    required ChildAssignmentsRepository assignments,
    required ChatRepository chat,
    DateTime Function()? clock,
  }) : _attendance = attendance,
       _assignments = assignments,
       _chat = chat,
       _now = clock ?? DateTime.now,
       super(const ParentProgressState.initial(), children);

  final ChildAttendanceRepository _attendance;
  final ChildAssignmentsRepository _assignments;
  final ChatRepository _chat;
  final DateTime Function() _now;

  DateTime get now => _now();

  @override
  Future<void> load({bool refresh = false}) async {
    final c = child;
    if (c == null) {
      emit(const ParentProgressState.initial());
      return;
    }
    final ticket = beginLoad();
    final period = switch (state) {
      ParentProgressLoaded(:final period) => period,
      _ => ProgressPeriod.month,
    };
    emit(const ParentProgressState.loading());
    try {
      final loaded = await _fetch(c, period, refresh: refresh);
      if (isCurrent(ticket)) emit(loaded);
    } on Object catch (e, st) {
      if (isCurrent(ticket))
        emit(ParentProgressState.error(errorMessage(e, st)));
    }
  }

  /// Pull-to-refresh: keeps the period. Returns an error message or `null`.
  Future<String?> refresh() async {
    final c = child;
    final s = state;
    if (c == null || s is! ParentProgressLoaded) {
      await load(refresh: true);
      return null;
    }
    final ticket = beginLoad();
    try {
      final fresh = await _fetch(c, s.period, refresh: true);
      if (isCurrent(ticket)) emit(fresh);
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  void setPeriod(ProgressPeriod period) {
    final s = state;
    if (s is ParentProgressLoaded && s.period != period) {
      emit(s.copyWith(period: period));
    }
  }

  /// The figures for the current state.
  ProgressReport? get report {
    final s = state;
    if (s is! ParentProgressLoaded) return null;
    return ProgressReport.build(
      period: s.period,
      now: _now(),
      attendance: s.attendance,
      assignments: s.assignments,
      feedback: s.feedback,
    );
  }

  Future<ParentProgressLoaded> _fetch(
    Child c,
    ProgressPeriod period, {
    required bool refresh,
  }) async {
    // Each source may fail on its own; only losing both essentials is an
    // error.
    final (att, attError) = await _settle(
      _attendance.getForChild(c.id, refresh: refresh),
    );
    final (hw, hwError) = await _settle(
      _assignments.getForChild(c.id, refresh: refresh),
    );
    final (fb, _) = await _settle(_loadFeedback(c));

    if (att == null && hw == null) {
      Error.throwWithStackTrace(
        attError ?? hwError ?? StateError('No data'),
        StackTrace.current,
      );
    }
    return ParentProgressLoaded(
      child: c,
      attendance: att ?? const [],
      assignments: hw ?? const [],
      feedback: fb ?? const [],
      period: period,
      partial: att == null || hw == null || fb == null,
    );
  }

  static Future<(T?, Object?)> _settle<T>(Future<T> f) async {
    try {
      return (await f, null);
    } on Object catch (e) {
      return (null, e);
    }
  }

  /// Feedback conversations about this child (all teachers).
  Future<List<FeedbackEntry>> _loadFeedback(Child c) async {
    final threads = await _chat.getByCategory(ChatCategory.feedback);
    final mine = [
      for (final t in threads)
        if (parseFeedbackThreadId(t.id)?.studentId.toString() == c.id) t,
    ];
    final entries = <FeedbackEntry>[];
    for (final t in mine) {
      final topics = await _chat.getFeedbackTopicsFor(t.id);
      for (final topic in topics) {
        entries.add(FeedbackEntry(t.id, topic));
      }
    }
    return entries;
  }
}
