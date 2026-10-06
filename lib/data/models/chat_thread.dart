import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_thread.freezed.dart';
part 'chat_thread.g.dart';

/// Which bucket a chat thread belongs to. Drives the two tabs on the
/// Chat screen (Feedback / 1-to-1).
enum ChatCategory {
  @JsonValue('feedback')
  feedback,
  @JsonValue('oneToOne')
  oneToOne,
}

/// A single chat thread in the inbox. Represents a conversation with
/// one counterpart (a parent in Feedback, a colleague/admin in 1-to-1).
@freezed
abstract class ChatThread with _$ChatThread {
  const factory ChatThread({
    required String id,
    required String name,
    required ChatCategory category,
    required DateTime lastMessageAt,
    @Default('') String avatarUrl,
    @Default('') String role,
    @Default('') String lastMessage,
    @Default(0) int unreadCount,
    @Default(false) bool isOnline,
    @Default(false) bool isPinned,
    @Default(false) bool isTyping,
    @Default(false) bool outgoingLast,
  }) = _ChatThread;

  factory ChatThread.fromJson(Map<String, dynamic> json) =>
      _$ChatThreadFromJson(json);
}
