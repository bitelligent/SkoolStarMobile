import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_scoped_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

part 'parent_assignments_cubit.freezed.dart';

/// Filter chips on the Assignments screen.
enum AssignmentFilter { all, pending, overdue, completed }

@freezed
sealed class ParentAssignmentsState with _$ParentAssignmentsState {
  const factory ParentAssignmentsState.initial() = ParentAssignmentsInitial;
  const factory ParentAssignmentsState.loading() = ParentAssignmentsLoading;
  const factory ParentAssignmentsState.error(String message) =
      ParentAssignmentsError;
  const factory ParentAssignmentsState.loaded({
    required Child child,
    required List<ChildAssignment> items,
    @Default(AssignmentFilter.all) AssignmentFilter filter,
  }) = ParentAssignmentsLoaded;
}

class ParentAssignmentsCubit extends ChildScopedCubit<ParentAssignmentsState> {
  ParentAssignmentsCubit({
    required ChildrenCubit children,
    required ChildAssignmentsRepository repository,
    DateTime Function()? clock,
  }) : _repository = repository,
       _now = clock ?? DateTime.now,
       super(const ParentAssignmentsState.initial(), children);

  final ChildAssignmentsRepository _repository;
  final DateTime Function() _now;

  @override
  Future<void> load({bool refresh = false}) async {
    final c = child;
    if (c == null) {
      emit(const ParentAssignmentsState.initial());
      return;
    }
    final ticket = beginLoad();
    emit(const ParentAssignmentsState.loading());
    try {
      final items = await _repository.getForChild(c.id, refresh: refresh);
      if (isCurrent(ticket)) {
        emit(ParentAssignmentsState.loaded(child: c, items: items));
      }
    } on Object catch (e, st) {
      if (isCurrent(ticket)) {
        emit(ParentAssignmentsState.error(errorMessage(e, st)));
      }
    }
  }

  Future<String?> refresh() async {
    final current = state;
    final c = child;
    if (current is! ParentAssignmentsLoaded || c == null) {
      await load(refresh: true);
      return null;
    }
    final ticket = beginLoad();
    try {
      final items = await _repository.getForChild(c.id, refresh: true);
      if (isCurrent(ticket)) emit(current.copyWith(items: items));
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  /// Shows [taskId] as handed in at [at] once the server accepted it. The
  /// guardian's note comes back with the next refresh.
  void markHandedIn(String taskId, DateTime at) {
    final s = state;
    if (s is! ParentAssignmentsLoaded) return;
    emit(
      s.copyWith(
        items: [
          for (final a in s.items)
            if (a.id == taskId)
              a.copyWith(isCompleted: true, completedAt: at)
            else
              a,
        ],
      ),
    );
  }

  void setFilter(AssignmentFilter filter) {
    final s = state;
    if (s is ParentAssignmentsLoaded) {
      emit(
        s.copyWith(filter: s.filter == filter ? AssignmentFilter.all : filter),
      );
    }
  }

  /// Totals for the tiles. "Pending" is everything still expected (not handed
  /// in, not graded); overdue is a subset shown as its own chip.
  ({int total, int completed, int pending, int overdue}) counts() {
    final s = state;
    if (s is! ParentAssignmentsLoaded) {
      return (total: 0, completed: 0, pending: 0, overdue: 0);
    }
    final now = _now();
    final completed = s.items.where((a) => a.isCompleted).length;
    final overdue = s.items
        .where((a) => a.statusAt(now) == AssignmentStatus.overdue)
        .length;
    return (
      total: s.items.length,
      completed: completed,
      pending: s.items.where((a) => a.isOpen).length,
      overdue: overdue,
    );
  }

  List<ChildAssignment> visible() {
    final s = state;
    if (s is! ParentAssignmentsLoaded) return const [];
    final now = _now();
    return switch (s.filter) {
      AssignmentFilter.all => s.items,
      AssignmentFilter.pending => s.items.where((a) => a.isOpen).toList(),
      AssignmentFilter.overdue =>
        s.items
            .where((a) => a.statusAt(now) == AssignmentStatus.overdue)
            .toList(),
      AssignmentFilter.completed =>
        s.items.where((a) => a.isCompleted).toList(),
    };
  }

  DateTime get now => _now();
}
