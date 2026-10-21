import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';

part 'direct_message.freezed.dart';
part 'direct_message.g.dart';

/// Single message in a 1-to-1 parent chat (the free-form conversation
/// between a teacher and a parent, separate from structured feedback).
@freezed
abstract class DirectMessage with _$DirectMessage {
  const factory DirectMessage({
    required String id,
    required String threadId,
    required bool fromTeacher,
    required String content,
    required DateTime sentAt,
    @Default(true) bool isRead,

    /// Local-only: delivery state of an optimistic message.
    @JsonKey(unknownEnumValue: MessageStatus.sent)
    @Default(MessageStatus.sent)
    MessageStatus status,

    /// Local id of an optimistic message; lets the server copy replace it.
    String? clientId,
  }) = _DirectMessage;

  factory DirectMessage.fromJson(Map<String, dynamic> json) =>
      _$DirectMessageFromJson(json);
}
