// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ClassGroup _$ClassGroupFromJson(Map<String, dynamic> json) => _ClassGroup(
  id: json['id'] as String,
  name: json['name'] as String,
  studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
  colorHex: json['colorHex'] as String? ?? '#2563EB',
);

Map<String, dynamic> _$ClassGroupToJson(_ClassGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'studentCount': instance.studentCount,
      'colorHex': instance.colorHex,
    };
