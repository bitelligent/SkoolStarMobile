// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeworkAttachment _$HomeworkAttachmentFromJson(Map<String, dynamic> json) =>
    _HomeworkAttachment(
      fileName: json['fileName'] as String,
      sizeKb: (json['sizeKb'] as num).toInt(),
      type: json['type'] as String,
    );

Map<String, dynamic> _$HomeworkAttachmentToJson(_HomeworkAttachment instance) =>
    <String, dynamic>{
      'fileName': instance.fileName,
      'sizeKb': instance.sizeKb,
      'type': instance.type,
    };

_Homework _$HomeworkFromJson(Map<String, dynamic> json) => _Homework(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  classId: json['classId'] as String,
  subjectId: json['subjectId'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  deadline: DateTime.parse(json['deadline'] as String),
  maxMarks: (json['maxMarks'] as num?)?.toInt() ?? 100,
  assignedStudentIds:
      (json['assignedStudentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => HomeworkAttachment.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$HomeworkToJson(_Homework instance) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'classId': instance.classId,
  'subjectId': instance.subjectId,
  'title': instance.title,
  'description': instance.description,
  'deadline': instance.deadline.toIso8601String(),
  'maxMarks': instance.maxMarks,
  'assignedStudentIds': instance.assignedStudentIds,
  'attachments': instance.attachments,
};
