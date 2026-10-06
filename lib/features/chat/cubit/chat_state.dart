import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';

part 'chat_state.freezed.dart';

@freezed
sealed class ChatState with _$ChatState {
  const factory ChatState.initial() = ChatInitial;
  const factory ChatState.loading() = ChatLoading;
  const factory ChatState.loaded({
    required List<ChatThread> threads,
    @Default('') String query,
    @Default(ChatCategory.feedback) ChatCategory activeTab,
  }) = ChatLoaded;
  const factory ChatState.error(String message) = ChatError;
}
