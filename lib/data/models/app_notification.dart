import 'package:equatable/equatable.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';

enum NotificationType {
  chat,
  feedback,

  /// A kind this app version does not know; shown generically.
  other
  ;

  static NotificationType parse(String? raw) => switch (raw?.toLowerCase()) {
    'chat' => NotificationType.chat,
    'feedback' => NotificationType.feedback,
    _ => NotificationType.other,
  };
}

/// An in-app notification from `GET /api/Notifications`.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.referenceType,
    this.referenceId,
    this.isRead = false,
  });

  /// Tolerant of missing fields; `null` only when there is no usable id.
  static AppNotification? fromJson(Json j) {
    final id = j.strOrNull('id');
    if (id == null) return null;
    return AppNotification(
      id: id,
      title: j.str('title', 'Notification'),
      body: j.str('body'),
      type: NotificationType.parse(j.strOrNull('type')),
      referenceType: j.strOrNull('referenceType'),
      referenceId: j.strOrNull('referenceId'),
      isRead: j.boolean('isRead'),
      createdAt: parseServerTime(j['createdAt'], fallback: DateTime.now()),
    );
  }

  final String id;
  final String title;
  final String body;
  final NotificationType type;

  /// `ChatThread` / `TeacherObservation`.
  final String? referenceType;

  /// Id of the related entity (thread id, feedback id).
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    title: title,
    body: body,
    type: type,
    createdAt: createdAt,
    referenceType: referenceType,
    referenceId: referenceId,
    isRead: isRead ?? this.isRead,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    referenceType,
    referenceId,
    isRead,
    createdAt,
  ];
}
