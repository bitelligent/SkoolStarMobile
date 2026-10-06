// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_topic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedbackMessage _$FeedbackMessageFromJson(Map<String, dynamic> json) =>
    _FeedbackMessage(
      id: json['id'] as String,
      fromTeacher: json['fromTeacher'] as bool,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool? ?? true,
    );

Map<String, dynamic> _$FeedbackMessageToJson(_FeedbackMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fromTeacher': instance.fromTeacher,
      'content': instance.content,
      'sentAt': instance.sentAt.toIso8601String(),
      'isRead': instance.isRead,
    };

_FeedbackTopic _$FeedbackTopicFromJson(Map<String, dynamic> json) =>
    _FeedbackTopic(
      id: json['id'] as String,
      threadId: json['threadId'] as String,
      subject: json['subject'] as String,
      tone: $enumDecode(_$FeedbackToneEnumMap, json['tone']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((e) => FeedbackMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      isResolved: json['isResolved'] as bool? ?? false,
    );

Map<String, dynamic> _$FeedbackTopicToJson(_FeedbackTopic instance) =>
    <String, dynamic>{
      'id': instance.id,
      'threadId': instance.threadId,
      'subject': instance.subject,
      'tone': _$FeedbackToneEnumMap[instance.tone]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'messages': instance.messages,
      'isResolved': instance.isResolved,
    };

const _$FeedbackToneEnumMap = {
  FeedbackTone.positive: 'positive',
  FeedbackTone.needsAttention: 'needsAttention',
  FeedbackTone.neutral: 'neutral',
};
