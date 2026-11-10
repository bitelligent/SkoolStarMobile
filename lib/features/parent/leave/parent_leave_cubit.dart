import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/leave_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_scoped_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

part 'parent_leave_cubit.freezed.dart';

@freezed
sealed class ParentLeaveState with _$ParentLeaveState {
  const factory ParentLeaveState.initial() = ParentLeaveInitial;
  const factory ParentLeaveState.loading() = ParentLeaveLoading;
  const factory ParentLeaveState.error(String message) = ParentLeaveError;

  const factory ParentLeaveState.loaded({
    required Child child,
    required List<LeaveRequest> items,

    /// `null` shows every status.
    LeaveStatus? filter,
    @Default(false) bool hasMore,
    @Default(false) bool loadingMore,

    /// Requests whose cancel call is in flight.
    @Default(<String>{}) Set<String> cancelling,
  }) = ParentLeaveLoaded;
}

/// The selected child's leave requests, plus asking for and cancelling one.
class ParentLeaveCubit extends ChildScopedCubit<ParentLeaveState> {
  ParentLeaveCubit({
    required ChildrenCubit children,
    required LeaveRepository repository,
  }) : _repository = repository,
       super(const ParentLeaveState.initial(), children);

  final LeaveRepository _repository;
  int _page = 1;

  @override
  Future<void> load({bool refresh = false}) async {
    final c = child;
    if (c == null) {
      emit(const ParentLeaveState.initial());
      return;
    }
    final filter = _filter;
    final ticket = beginLoad();
    emit(const ParentLeaveState.loading());
    try {
      final page = await _repository.list(childId: c.id, status: filter);
      if (!isCurrent(ticket)) return;
      _page = page.pageNumber;
      emit(
        ParentLeaveState.loaded(
          child: c,
          items: page.items,
          filter: filter,
          hasMore: page.hasNextPage,
        ),
      );
    } on Object catch (e, st) {
      if (isCurrent(ticket)) emit(ParentLeaveState.error(errorMessage(e, st)));
    }
  }

  LeaveStatus? get _filter => switch (state) {
    ParentLeaveLoaded(:final filter) => filter,
    _ => null,
  };

  /// Pull-to-refresh: keeps the filter. Returns an error message or `null`.
  Future<String?> refresh() async {
    final s = state;
    final c = child;
    if (s is! ParentLeaveLoaded || c == null) {
      await load(refresh: true);
      return null;
    }
    final ticket = beginLoad();
    try {
      final page = await _repository.list(childId: c.id, status: s.filter);
      if (!isCurrent(ticket)) return null;
      _page = page.pageNumber;
      emit(
        s.copyWith(
          items: page.items,
          hasMore: page.hasNextPage,
          loadingMore: false,
        ),
      );
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  /// Tapping the active chip goes back to "All".
  Future<void> setFilter(LeaveStatus? filter) async {
    final s = state;
    if (s is! ParentLeaveLoaded) return;
    final next = s.filter == filter ? null : filter;
    if (next == s.filter) return;
    emit(s.copyWith(filter: next));
    await load();
  }

  Future<void> loadMore() async {
    final s = state;
    final c = child;
    if (s is! ParentLeaveLoaded || c == null || !s.hasMore || s.loadingMore) {
      return;
    }
    final ticket = beginLoad();
    emit(s.copyWith(loadingMore: true));
    try {
      final page = await _repository.list(
        childId: c.id,
        status: s.filter,
        page: _page + 1,
      );
      if (!isCurrent(ticket)) return;
      _page = page.pageNumber;
      final known = {for (final r in s.items) r.id};
      emit(
        s.copyWith(
          items: [
            ...s.items,
            ...page.items.where((r) => !known.contains(r.id)),
          ],
          hasMore: page.hasNextPage,
          loadingMore: false,
        ),
      );
    } on Object {
      // Keep what is shown; the next scroll to the end tries again.
      if (isCurrent(ticket)) emit(s.copyWith(loadingMore: false));
    }
  }

  /// Sends a request for the selected child. Returns the server's reason when
  /// it was refused (overlap, too long, …) so the form can show it, or
  /// `null` once it is Pending and on the list.
  Future<String?> submit({
    required DateTime start,
    required DateTime end,
    required String reason,
  }) async {
    final c = child;
    if (c == null) return 'Select a child first.';
    try {
      final created = await _repository.create(
        childId: c.id,
        start: start,
        end: end,
        reason: reason,
      );
      final s = state;
      if (s is ParentLeaveLoaded &&
          (s.filter == null || s.filter == created.status)) {
        emit(s.copyWith(items: [created, ...s.items]));
      }
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  /// Cancels a Pending request. Returns an error message or `null`.
  Future<String?> cancel(String id) async {
    final s = state;
    if (s is! ParentLeaveLoaded || s.cancelling.contains(id)) return null;
    emit(s.copyWith(cancelling: {...s.cancelling, id}));
    try {
      final updated = await _repository.cancel(id);
      _replace(id, updated);
      return null;
    } on Object catch (e, st) {
      _settleCancel(id);
      return errorMessage(e, st);
    }
  }

  void _replace(String id, LeaveRequest updated) {
    final s = state;
    if (s is! ParentLeaveLoaded) return;
    final keep = s.filter == null || s.filter == updated.status;
    emit(
      s.copyWith(
        items: [
          for (final r in s.items)
            if (r.id != id) r else if (keep) updated,
        ],
        cancelling: {...s.cancelling}..remove(id),
      ),
    );
  }

  void _settleCancel(String id) {
    final s = state;
    if (s is ParentLeaveLoaded) {
      emit(s.copyWith(cancelling: {...s.cancelling}..remove(id)));
    }
  }
}
