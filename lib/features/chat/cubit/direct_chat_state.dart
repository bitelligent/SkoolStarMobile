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
    @Default(false) bool isSending,
  }) = DirectChatLoaded;
  const factory DirectChatState.error(String message) = DirectChatError;
}
