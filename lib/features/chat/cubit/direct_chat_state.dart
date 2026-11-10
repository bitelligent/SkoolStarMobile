import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';

part 'direct_chat_state.freezed.dart';

@freezed
sealed class DirectChatState with _$DirectChatState {
  const factory DirectChatState.initial() = DirectChatInitial;
  const factory DirectChatState.loading() = DirectChatLoading;
  const factory DirectChatState.loaded({
    required ChatThread thread,
    required List<DirectMessage> messages,

    /// Kept for the composer; sending is optimistic so it stays `false`.
    @Default(false) bool isSending,

    /// More (older) messages can be fetched.
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingOlder,

    /// Realtime link is up (otherwise new messages arrive on refresh only).
    @Default(true) bool isLive,
  }) = DirectChatLoaded;
  const factory DirectChatState.error(String message) = DirectChatError;
}
