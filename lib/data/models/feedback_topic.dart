import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_topic.freezed.dart';
part 'feedback_topic.g.dart';

/// Tone of a feedback — drives the colored chip + icon on the tile head.
enum FeedbackTone {
  @JsonValue('positive')
  positive,
  @JsonValue('needsAttention')
  needsAttention,
  @JsonValue('neutral')
  neutral,
}

/// One message inside a [FeedbackTopic]'s reply chain. The first message
/// of every topic is from the teacher (initial feedback); subsequent
/// messages alternate between parent and teacher.
@freezed
abstract class FeedbackMessage with _$FeedbackMessage {
  const factory FeedbackMessage({
    required String id,
    required bool fromTeacher,
    required String content,
    required DateTime sentAt,
    @Default(true) bool isRead,
  }) = _FeedbackMessage;

  factory FeedbackMessage.fromJson(Map<String, dynamic> json) =>
      _$FeedbackMessageFromJson(json);
}

/// One feedback topic sent by a teacher to a parent, plus the whole
/// reply chain it generated. Each top-level entry on the chat screen
/// is one of these.
@freezed
abstract class FeedbackTopic with _$FeedbackTopic {
  const FeedbackTopic._();

  const factory FeedbackTopic({
    required String id,
    required String threadId,
    required String subject,
    required FeedbackTone tone,
    required DateTime createdAt,
    required List<FeedbackMessage> messages,
    @Default(false) bool isResolved,
  }) = _FeedbackTopic;

  factory FeedbackTopic.fromJson(Map<String, dynamic> json) =>
      _$FeedbackTopicFromJson(json);

  /// Teacher's original feedback body — always the first message.
  String get initialBody =>
      messages.isEmpty ? '' : messages.first.content;

  /// Timestamp of the most recent message in the thread.
  DateTime get lastActivityAt =>
      messages.isEmpty ? createdAt : messages.last.sentAt;

  /// Count of unread messages addressed to the teacher
  /// (i.e. parent replies that haven't been read yet).
  int get unreadFromParent => messages
      .where((m) => !m.fromTeacher && !m.isRead)
      .length;
}
