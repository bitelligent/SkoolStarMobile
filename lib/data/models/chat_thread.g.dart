// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatThread _$ChatThreadFromJson(Map<String, dynamic> json) => _ChatThread(
  id: json['id'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$ChatCategoryEnumMap, json['category']),
  lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
  avatarUrl: json['avatarUrl'] as String? ?? '',
  role: json['role'] as String? ?? '',
  lastMessage: json['lastMessage'] as String? ?? '',
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  isOnline: json['isOnline'] as bool? ?? false,
  isPinned: json['isPinned'] as bool? ?? false,
  isTyping: json['isTyping'] as bool? ?? false,
  outgoingLast: json['outgoingLast'] as bool? ?? false,
);

Map<String, dynamic> _$ChatThreadToJson(_ChatThread instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': _$ChatCategoryEnumMap[instance.category]!,
      'lastMessageAt': instance.lastMessageAt.toIso8601String(),
      'avatarUrl': instance.avatarUrl,
      'role': instance.role,
      'lastMessage': instance.lastMessage,
      'unreadCount': instance.unreadCount,
      'isOnline': instance.isOnline,
      'isPinned': instance.isPinned,
      'isTyping': instance.isTyping,
      'outgoingLast': instance.outgoingLast,
    };

const _$ChatCategoryEnumMap = {
  ChatCategory.feedback: 'feedback',
  ChatCategory.oneToOne: 'oneToOne',
};
