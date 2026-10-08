// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      tokenType: json['tokenType'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: (json['expiresIn'] as num?)?.toInt(),
      activeContextKey: json['activeContextKey'] as String?,
      requiresContextSelection:
          json['requiresContextSelection'] as bool? ?? false,
      availableContexts:
          (json['availableContexts'] as List<dynamic>?)
              ?.map((e) => AuthContext.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <AuthContext>[],
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'tokenType': instance.tokenType,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'activeContextKey': instance.activeContextKey,
      'requiresContextSelection': instance.requiresContextSelection,
      'availableContexts': instance.availableContexts,
    };
