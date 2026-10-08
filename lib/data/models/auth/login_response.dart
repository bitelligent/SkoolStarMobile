import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';

part 'login_response.freezed.dart';
part 'login_response.g.dart';

@freezed
abstract class LoginResponse with _$LoginResponse {
  const factory LoginResponse({
    String? tokenType,
    String? accessToken,
    String? refreshToken,

    /// Access-token lifetime in seconds.
    int? expiresIn,
    String? activeContextKey,

    /// True when the account has several contexts and the client must pick
    /// one (re-submit login with `contextKey`) before a token is issued.
    @Default(false) bool requiresContextSelection,
    @Default(<AuthContext>[]) List<AuthContext> availableContexts,
  }) = _LoginResponse;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
}
