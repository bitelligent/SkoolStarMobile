// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_context.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthContext _$AuthContextFromJson(Map<String, dynamic> json) => _AuthContext(
  contextKey: json['contextKey'] as String,
  role: json['role'] as String,
  clientId: (json['clientId'] as num?)?.toInt(),
  clientName: json['clientName'] as String?,
  instituteId: (json['instituteId'] as num?)?.toInt(),
  instituteName: json['instituteName'] as String?,
  instituteTypeId: (json['instituteTypeId'] as num?)?.toInt(),
  instituteTypeCode: json['instituteTypeCode'] as String?,
  instituteTypeName: json['instituteTypeName'] as String?,
  staffId: (json['staffId'] as num?)?.toInt(),
  studentId: (json['studentId'] as num?)?.toInt(),
  guardianId: (json['guardianId'] as num?)?.toInt(),
  displayName: json['displayName'] as String?,
);

Map<String, dynamic> _$AuthContextToJson(_AuthContext instance) =>
    <String, dynamic>{
      'contextKey': instance.contextKey,
      'role': instance.role,
      'clientId': instance.clientId,
      'clientName': instance.clientName,
      'instituteId': instance.instituteId,
      'instituteName': instance.instituteName,
      'instituteTypeId': instance.instituteTypeId,
      'instituteTypeCode': instance.instituteTypeCode,
      'instituteTypeName': instance.instituteTypeName,
      'staffId': instance.staffId,
      'studentId': instance.studentId,
      'guardianId': instance.guardianId,
      'displayName': instance.displayName,
    };
