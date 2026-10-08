import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.freezed.dart';
part 'login_request.g.dart';

@freezed
abstract class LoginRequest with _$LoginRequest {
  @JsonSerializable(includeIfNull: false)
  const factory LoginRequest({
    required String email,
    required String password,

    /// Set only when re-submitting after the user picked a context.
    String? contextKey,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}
