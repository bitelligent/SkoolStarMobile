// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationItem _$NotificationItemFromJson(Map<String, dynamic> json) =>
    _NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timeAgo: json['timeAgo'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$NotificationItemToJson(_NotificationItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'timeAgo': instance.timeAgo,
      'type': instance.type,
      'isRead': instance.isRead,
    };

_NotificationsData _$NotificationsDataFromJson(Map<String, dynamic> json) =>
    _NotificationsData(
      items: (json['items'] as List<dynamic>)
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NotificationsDataToJson(_NotificationsData instance) =>
    <String, dynamic>{'items': instance.items};
