import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/config/attendance_status_config.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_scoped_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

part 'parent_attendance_cubit.freezed.dart';

@freezed
sealed class ParentAttendanceState with _$ParentAttendanceState {
  const ParentAttendanceState._();

  const factory ParentAttendanceState.initial() = ParentAttendanceInitial;
  const factory ParentAttendanceState.loading() = ParentAttendanceLoading;
  const factory ParentAttendanceState.error(String message) =
      ParentAttendanceError;

  /// [filter] is `''` (all) or an `AttendanceStatusConfig` status key.
  const factory ParentAttendanceState.loaded({
    required Child child,
    required List<ChildAttendanceRecord> records,
    @Default('') String filter,
  }) = ParentAttendanceLoaded;
}

class AttendanceCounts {
  const AttendanceCounts({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
  });

  final int total;
  final int present;
  final int late;
  final int absent;
}

class ParentAttendanceCubit extends ChildScopedCubit<ParentAttendanceState> {
  ParentAttendanceCubit({
    required ChildrenCubit children,
    required ChildAttendanceRepository repository,
  }) : _repository = repository,
       super(const ParentAttendanceState.initial(), children);

  final ChildAttendanceRepository _repository;

  @override
  Future<void> load({bool refresh = false}) async {
    final c = child;
    if (c == null) {
      emit(const ParentAttendanceState.initial());
      return;
    }
    final ticket = beginLoad();
    emit(const ParentAttendanceState.loading());
    try {
      final records = await _repository.getForChild(c.id, refresh: refresh);
      if (isCurrent(ticket)) {
        emit(ParentAttendanceState.loaded(child: c, records: records));
      }
    } on Object catch (e, st) {
      if (isCurrent(ticket)) {
        emit(ParentAttendanceState.error(errorMessage(e, st)));
      }
    }
  }

  /// Pull-to-refresh: keeps the filter; returns an error message or `null`.
  Future<String?> refresh() async {
    final current = state;
    final c = child;
    if (current is! ParentAttendanceLoaded || c == null) {
      await load(refresh: true);
      return null;
    }
    final ticket = beginLoad();
    try {
      final records = await _repository.getForChild(c.id, refresh: true);
      if (isCurrent(ticket)) emit(current.copyWith(records: records));
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  void setFilter(String filter) {
    final s = state;
    if (s is ParentAttendanceLoaded) {
      emit(s.copyWith(filter: s.filter == filter ? '' : filter));
    }
  }

  AttendanceCounts counts() {
    final s = state;
    if (s is! ParentAttendanceLoaded) {
      return const AttendanceCounts(total: 0, present: 0, late: 0, absent: 0);
    }
    int n(String status) => s.records.where((r) => r.status == status).length;
    return AttendanceCounts(
      total: s.records.length,
      present: n(AttendanceStatusConfig.present),
      late: n(AttendanceStatusConfig.late),
      absent: n(AttendanceStatusConfig.absent),
    );
  }

  List<ChildAttendanceRecord> visible() {
    final s = state;
    if (s is! ParentAttendanceLoaded) return const [];
    return s.filter.isEmpty
        ? s.records
        : s.records.where((r) => r.status == s.filter).toList();
  }
}
