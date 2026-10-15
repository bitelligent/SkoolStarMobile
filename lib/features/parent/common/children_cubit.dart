import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/app_role.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/children_repository.dart';

part 'children_cubit.freezed.dart';

@freezed
sealed class ChildrenState with _$ChildrenState {
  const ChildrenState._();

  const factory ChildrenState.initial() = ChildrenInitial;
  const factory ChildrenState.loading() = ChildrenLoading;

  /// [selected] is `null` only when [children] is empty.
  const factory ChildrenState.loaded({
    required List<Child> children,
    required Child? selected,
  }) = ChildrenLoaded;
  const factory ChildrenState.error(String message) = ChildrenError;

  Child? get selectedChild => switch (this) {
    ChildrenLoaded(:final selected) => selected,
    _ => null,
  };
}

/// Holds the parent's children and which one is selected. The selection is
/// remembered per role/account, and screens reload when it changes.
///
/// Lives above the router so shell tabs and pushed screens share it. It
/// resets itself when the role changes or the user signs out.
class ChildrenCubit extends Cubit<ChildrenState> {
  ChildrenCubit({
    required ChildrenRepository repository,
    required KeyValueStore store,
    required AuthRepository auth,
  }) : _repository = repository,
       _store = store,
       _auth = auth,
       super(const ChildrenState.initial()) {
    _lastKey = _parentKey();
    auth.session.addListener(_onSessionChanged);
    if (_lastKey != null) unawaited(load());
  }

  final ChildrenRepository _repository;
  final KeyValueStore _store;
  final AuthRepository _auth;
  String? _lastKey;
  int _generation = 0;

  /// Non-null only while acting as a parent.
  String? _parentKey() {
    final s = _auth.session.value;
    return s.role == AppRole.parent ? s.contextKey : null;
  }

  String _prefKey(String contextKey) => 'parent.selected_child.$contextKey';

  void _onSessionChanged() {
    final key = _parentKey();
    if (key == _lastKey) return;
    _lastKey = key;
    _generation++;
    if (key == null) {
      emit(const ChildrenState.initial());
    } else {
      unawaited(load());
    }
  }

  /// Loads (or reloads) the children. [refresh] bypasses the repository cache.
  Future<void> load({bool refresh = false}) async {
    final contextKey = _lastKey;
    if (contextKey == null) return;
    final gen = ++_generation;

    final previous = state;
    if (previous is! ChildrenLoaded || refresh == false) {
      emit(const ChildrenState.loading());
    }
    try {
      final children = await _repository.getChildren(refresh: refresh);
      if (isClosed || gen != _generation) return;

      final savedId = await _store.read(_prefKey(contextKey));
      final keepId = previous is ChildrenLoaded ? previous.selected?.id : null;
      Child? selected;
      for (final wanted in [keepId, savedId]) {
        selected = children.where((c) => c.id == wanted).firstOrNull;
        if (selected != null) break;
      }
      selected ??= children.firstOrNull;
      if (isClosed || gen != _generation) return;
      emit(ChildrenState.loaded(children: children, selected: selected));
    } on Object catch (e, st) {
      if (isClosed || gen != _generation) return;
      // A failed background refresh keeps what the user already sees.
      if (previous is ChildrenLoaded && refresh) {
        emit(previous);
      } else {
        emit(ChildrenState.error(errorMessage(e, st)));
      }
    }
  }

  /// Makes [child] the selected one; everything that depends on it reloads.
  Future<void> select(Child child) async {
    final s = state;
    if (s is! ChildrenLoaded || s.selected?.id == child.id) return;
    if (!s.children.any((c) => c.id == child.id)) return;
    emit(ChildrenState.loaded(children: s.children, selected: child));
    final key = _lastKey;
    if (key != null) await _store.write(_prefKey(key), child.id);
  }

  @override
  Future<void> close() {
    _auth.session.removeListener(_onSessionChanged);
    return super.close();
  }
}
