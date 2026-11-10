import 'package:flutter/foundation.dart' show protected;
import 'package:flutter_bloc/flutter_bloc.dart';

/// A [Cubit] that ignores state emitted after it was closed.
///
/// Screens start async loads and can be left before they finish (back
/// navigation, sign-out redirect, role switch). Plain cubits throw
/// `StateError: Cannot emit new states after calling close` when the late
/// response arrives: an uncaught async error that, under a debugger, pauses
/// the isolate and freezes the app. Dropping the result is always correct
/// here: nobody is listening any more.
abstract class SafeCubit<S> extends Cubit<S> {
  SafeCubit(super.initialState);

  @protected
  @override
  void emit(S state) {
    if (isClosed) return;
    super.emit(state);
  }
}
