import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_state.dart';

/// Cubit scoped to one parent chat: owns the list of feedback topics, the
/// per-topic expansion state, and the submission flags. Thin — the real
/// work (sorting, persistence) lives in the repository.
class FeedbackChatCubit extends Cubit<FeedbackChatState> {
  FeedbackChatCubit({
    required this.threadId,
    required ChatRepository repository,
  })  : _repo = repository,
        super(const FeedbackChatState.initial());

  final String threadId;
  final ChatRepository _repo;

  Future<void> load() async {
    emit(const FeedbackChatState.loading());
    try {
      final thread = await _repo.getThreadById(threadId);
      if (thread == null) {
        emit(const FeedbackChatState.error('Chat not found'));
        return;
      }
      final topics = await _repo.getFeedbackTopicsFor(threadId);
      emit(
        FeedbackChatState.loaded(
          thread: thread,
          topics: topics,
          // Auto-expand the newest topic so the user lands inside the
          // most recent conversation instead of a wall of collapsed cards.
          expandedTopicIds: topics.isEmpty ? const {} : {topics.first.id},
        ),
      );
      // Mark the most recent as read in the background; the UI already
      // knows it's "open", we just need to persist the state.
      if (topics.isNotEmpty) {
        unawaited(_repo.markTopicRead(topics.first.id));
      }
    } on Exception catch (e) {
      emit(FeedbackChatState.error(e.toString()));
    }
  }

  void toggleExpanded(String topicId) {
    final s = state;
    if (s is! FeedbackChatLoaded) return;
    final updated = Set<String>.from(s.expandedTopicIds);
    if (updated.contains(topicId)) {
      updated.remove(topicId);
    } else {
      updated.add(topicId);
      // Side-effect: once we open the card, treat it as read.
      unawaited(_repo.markTopicRead(topicId));
    }
    emit(s.copyWith(expandedTopicIds: updated));
  }

  Future<bool> createTopic({
    required String subject,
    required FeedbackTone tone,
    required String message,
  }) async {
    final s = state;
    if (s is! FeedbackChatLoaded) return false;
    if (message.trim().isEmpty) return false;

    emit(s.copyWith(creatingTopic: true));
    try {
      final topic = await _repo.createFeedbackTopic(
        threadId: threadId,
        subject: subject,
        tone: tone,
        message: message,
      );
      emit(
        s.copyWith(
          topics: [topic, ...s.topics],
          expandedTopicIds: {topic.id, ...s.expandedTopicIds},
          creatingTopic: false,
        ),
      );
      return true;
    } on Exception {
      emit(s.copyWith(creatingTopic: false));
      return false;
    }
  }

  Future<bool> replyToTopic(String topicId, String content) async {
    final s = state;
    if (s is! FeedbackChatLoaded) return false;
    if (content.trim().isEmpty) return false;
    if (s.sendingReplyTopicId != null) return false;

    emit(s.copyWith(sendingReplyTopicId: topicId));
    try {
      final reply = await _repo.replyToTopic(
        topicId: topicId,
        content: content,
        fromTeacher: true,
      );
      final updated = [
        for (final t in s.topics)
          if (t.id == topicId)
            t.copyWith(messages: [...t.messages, reply])
          else
            t,
      ];
      emit(s.copyWith(topics: updated, sendingReplyTopicId: null));
      return true;
    } on Exception {
      emit(s.copyWith(sendingReplyTopicId: null));
      return false;
    }
  }

  Future<void> toggleResolved(String topicId) async {
    final s = state;
    if (s is! FeedbackChatLoaded) return;
    try {
      final updated = await _repo.toggleResolved(topicId);
      emit(
        s.copyWith(
          topics: [
            for (final t in s.topics)
              if (t.id == topicId) updated else t,
          ],
        ),
      );
    } on Exception {
      // Keep state unchanged on failure; UI shows the previous value.
    }
  }

  Future<void> deleteTopic(String topicId) async {
    final s = state;
    if (s is! FeedbackChatLoaded) return;
    final previous = s.topics;
    emit(
      s.copyWith(
        topics: previous.where((t) => t.id != topicId).toList(),
        expandedTopicIds: s.expandedTopicIds.difference({topicId}),
      ),
    );
    try {
      await _repo.deleteTopic(topicId);
    } on Exception {
      // Roll back on failure.
      emit(s.copyWith(topics: previous));
    }
  }
}

/// `unawaited` without needing to import `dart:async` — keeps intent
/// explicit for background calls that don't block UI state.
void unawaited(Future<void> _) {}
