// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Student _$StudentFromJson(Map<String, dynamic> json) => _Student(
  id: json['id'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  classGroupId: json['classGroupId'] as String,
  rollNo: json['rollNo'] as String? ?? '',
  avatarUrl: json['avatarUrl'] as String? ?? '',
);

Map<String, dynamic> _$StudentToJson(_Student instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'classGroupId': instance.classGroupId,
  'rollNo': instance.rollNo,
  'avatarUrl': instance.avatarUrl,
};
