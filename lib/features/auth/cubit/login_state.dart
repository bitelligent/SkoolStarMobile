import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial() = LoginInitial;
  const factory LoginState.loading() = LoginLoading;

  /// Signed in. The router decides where to go next (role list, teacher or
  /// parent module) from the new auth session.
  const factory LoginState.success() = LoginSuccess;
  const factory LoginState.failure(String message) = LoginFailure;
}
