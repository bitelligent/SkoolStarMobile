// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  id: json['id'] as String,
  date: DateTime.parse(json['date'] as String),
  startTime: json['startTime'] as String,
  endTime: json['endTime'] as String,
  classIds: (json['classIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  subjectIds: (json['subjectIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  teacherId: json['teacherId'] as String,
  isLive: json['isLive'] as bool? ?? false,
  isLocked: json['isLocked'] as bool? ?? false,
);

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'startTime': instance.startTime,
  'endTime': instance.endTime,
  'classIds': instance.classIds,
  'subjectIds': instance.subjectIds,
  'teacherId': instance.teacherId,
  'isLive': instance.isLive,
  'isLocked': instance.isLocked,
};
