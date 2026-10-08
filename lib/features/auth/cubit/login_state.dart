import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';

part 'login_state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial() = LoginInitial;
  const factory LoginState.loading() = LoginLoading;
  const factory LoginState.success() = LoginSuccess;

  /// Account has several contexts; the UI must let the user pick one.
  const factory LoginState.contextSelection(List<AuthContext> contexts) =
      LoginContextSelection;
  const factory LoginState.failure(String message) = LoginFailure;
}
