import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';

part 'feedback_chat_state.freezed.dart';

@freezed
sealed class FeedbackChatState with _$FeedbackChatState {
  const factory FeedbackChatState.initial() = FeedbackChatInitial;
  const factory FeedbackChatState.loading() = FeedbackChatLoading;
  const factory FeedbackChatState.loaded({
    required ChatThread thread,
    required List<FeedbackTopic> topics,

    /// Which topic cards are currently expanded. Kept here (not inside
    /// each tile's own state) so expansion survives list rebuilds when
    /// a reply/new-topic edit lands.
    @Default(<String>{}) Set<String> expandedTopicIds,

    /// Topic currently waiting on a server reply — disables its composer
    /// so the user can't double-submit.
    String? sendingReplyTopicId,

    /// True while a new feedback topic is being created from the sheet.
    @Default(false) bool creatingTopic,
  }) = FeedbackChatLoaded;
  const factory FeedbackChatState.error(String message) = FeedbackChatError;
}
