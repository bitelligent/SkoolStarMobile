import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

/// Base for cubits whose data belongs to the currently selected child.
///
/// When the parent switches child (from the always-visible header) [load]
/// runs again for the new child. Responses that arrive after the selection
/// changed again are discarded via [beginLoad] / [isCurrent].
abstract class ChildScopedCubit<S> extends Cubit<S> {
  ChildScopedCubit(super.initialState, this.children) {
    _lastChildId = children.state.selectedChild?.id;
    _sub = children.stream.listen(_onChildrenChanged);
  }

  final ChildrenCubit children;
  late final StreamSubscription<ChildrenState> _sub;
  String? _lastChildId;
  int _generation = 0;

  /// The selected child, or `null` (not loaded yet / none linked).
  Child? get child => children.state.selectedChild;

  /// Reload everything for the current [child]. Implementations call
  /// [beginLoad] first and check [isCurrent] after every `await`.
  Future<void> load({bool refresh = false});

  void _onChildrenChanged(ChildrenState s) {
    final id = s.selectedChild?.id;
    if (id == _lastChildId) return;
    _lastChildId = id;
    if (isClosed) return;
    unawaited(load());
  }

  /// Starts a load and returns its ticket.
  @protected
  int beginLoad() => ++_generation;

  /// False when a newer load started or the cubit was closed meanwhile.
  @protected
  bool isCurrent(int ticket) => !isClosed && ticket == _generation;

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}
