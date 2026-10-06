// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceEntry _$AttendanceEntryFromJson(Map<String, dynamic> json) =>
    _AttendanceEntry(
      sessionId: json['sessionId'] as String,
      studentId: json['studentId'] as String,
      status: json['status'] as String? ?? 'unmarked',
    );

Map<String, dynamic> _$AttendanceEntryToJson(_AttendanceEntry instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'studentId': instance.studentId,
      'status': instance.status,
    };
