import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_context.freezed.dart';
part 'auth_context.g.dart';

/// One role-at-an-institute the signed-in account can act as
/// (e.g. `Teacher:3` at "ISL AC").
@freezed
abstract class AuthContext with _$AuthContext {
  const factory AuthContext({
    required String contextKey,
    required String role,
    int? clientId,
    String? clientName,
    int? instituteId,
    String? instituteName,
    int? instituteTypeId,
    String? instituteTypeCode,
    String? instituteTypeName,
    int? staffId,
    int? studentId,
    int? guardianId,
    String? displayName,
  }) = _AuthContext;

  factory AuthContext.fromJson(Map<String, dynamic> json) =>
      _$AuthContextFromJson(json);
}
