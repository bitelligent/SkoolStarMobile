import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

part 'role_selection_cubit.freezed.dart';

@freezed
sealed class RoleSelectionState with _$RoleSelectionState {
  const factory RoleSelectionState.idle() = RoleSelectionIdle;

  /// A role is being activated (tokens are being exchanged).
  const factory RoleSelectionState.selecting(String contextKey) =
      RoleSelectionSelecting;

  /// The role is active; the screen navigates to its module.
  const factory RoleSelectionState.selected(AuthContext active) =
      RoleSelectionSelected;
  const factory RoleSelectionState.failure(String message) =
      RoleSelectionFailure;
}

class RoleSelectionCubit extends SafeCubit<RoleSelectionState> {
  RoleSelectionCubit(this._auth) : super(const RoleSelectionState.idle());

  final AuthRepository _auth;

  Future<void> select(AuthContext context) async {
    if (state is RoleSelectionSelecting) return;

    // Already acting as this role: nothing to exchange.
    if (_auth.currentContext?.contextKey == context.contextKey) {
      emit(RoleSelectionState.selected(context));
      return;
    }

    emit(RoleSelectionState.selecting(context.contextKey));
    try {
      final active = await _auth.selectContext(context.contextKey);
      if (!isClosed) emit(RoleSelectionState.selected(active));
    } on Object catch (e, st) {
      if (!isClosed) emit(RoleSelectionState.failure(errorMessage(e, st)));
    }
  }
}
