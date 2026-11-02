import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';

/// Something that changed on the server, already mapped to UI models.
sealed class ChatEvent {
  const ChatEvent();
}

class DirectMessageReceived extends ChatEvent {
  const DirectMessageReceived(this.threadId, this.message);
  final String threadId;
  final DirectMessage message;
}

/// Read state / last message of a 1-to-1 thread changed (or the thread is
/// not known locally yet).
class DirectThreadChanged extends ChatEvent {
  const DirectThreadChanged(this.threadId);
  final String threadId;
}

class PeerPresenceChanged extends ChatEvent {
  const PeerPresenceChanged(this.peerUserId, {required this.online});
  final String peerUserId;
  final bool online;
}

class FeedbackMessageReceived extends ChatEvent {
  const FeedbackMessageReceived(this.topicId, this.message);
  final String topicId;
  final FeedbackMessage message;
}

/// A feedback thread was created / changed somewhere; re-fetch lists.
class FeedbackListChanged extends ChatEvent {
  const FeedbackListChanged();
}

/// The realtime link was re-established: anything sent while it was down
/// was missed, so re-fetch what is on screen.
class ChatResync extends ChatEvent {
  const ChatResync();
}

abstract class ChatRepository {
  /// Messages loaded per page in a 1-to-1 chat.
  static const int pageSize = 30;

  Future<List<ChatThread>> getThreads();
  Future<List<ChatThread>> getByCategory(ChatCategory category);
  Future<ChatThread?> getThreadById(String id);

  /// The feedback thread a feedback record (topic) belongs to, or `null`
  /// when it no longer exists. Used to open a thread from a notification.
  Future<String?> feedbackThreadIdFor(String topicId) async => null;

  /// Re-reads one thread from the server (read state, last message,
  /// presence). Falls back to the cached copy when offline.
  Future<ChatThread?> refreshThread(String id) => getThreadById(id);

  Future<List<FeedbackTopic>> getFeedbackTopicsFor(String threadId);
  Future<FeedbackTopic> createFeedbackTopic({
    required String threadId,
    required String subject,
    required FeedbackTone tone,
    required String message,
  });
  Future<FeedbackMessage> replyToTopic({
    required String topicId,
    required String content,
    required bool fromTeacher,
  });
  Future<FeedbackTopic> toggleResolved(String topicId);
  Future<void> deleteTopic(String topicId);
  Future<void> markTopicRead(String topicId, {bool asParent = false});

  /// Latest [pageSize] messages, oldest first.
  Future<List<DirectMessage>> getDirectMessagesFor(String threadId);

  /// The page of messages older than [beforeMessageId], oldest first.
  Future<List<DirectMessage>> getOlderDirectMessages(
    String threadId, {
    required String beforeMessageId,
  }) async => const [];

  Future<DirectMessage> sendDirectMessage({
    required String threadId,
    required String content,
    required bool fromTeacher,
  });
  Future<void> markDirectThreadRead(String threadId, {bool asParent = false});

  // ─── Realtime (no-ops for offline / mock repositories) ──────────────

  /// Server-pushed changes. Never errors; a dropped link shows up in
  /// [isLive] and ends with a [ChatResync].
  Stream<ChatEvent> get events => const Stream.empty();

  /// `true` while the realtime link is up.
  ValueListenable<bool> get isLive => _alwaysLive;

  /// Start receiving messages for one 1-to-1 thread / these feedback topics.
  Future<void> watchDirectThread(String threadId) async {}
  Future<void> unwatchDirectThread(String threadId) async {}
  Future<void> watchFeedbackTopics(Iterable<String> topicIds) async {}
  Future<void> unwatchFeedbackTopics(Iterable<String> topicIds) async {}
}

final ValueNotifier<bool> _alwaysLive = ValueNotifier(true);
