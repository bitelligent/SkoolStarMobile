// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'direct_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DirectMessage _$DirectMessageFromJson(Map<String, dynamic> json) =>
    _DirectMessage(
      id: json['id'] as String,
      threadId: json['threadId'] as String,
      fromTeacher: json['fromTeacher'] as bool,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool? ?? true,
    );

Map<String, dynamic> _$DirectMessageToJson(_DirectMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'fromTeacher': instance.fromTeacher,
      'content': instance.content,
      'sentAt': instance.sentAt.toIso8601String(),
      'isRead': instance.isRead,
    };
