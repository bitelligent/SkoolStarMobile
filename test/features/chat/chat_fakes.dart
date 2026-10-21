import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';

/// Scriptable [ChatRepository]: each call can be held open or failed so
/// tests can place server events at precise points of a send.
class FakeChatRepository extends ChatRepository {
  FakeChatRepository({ChatThread? thread, List<DirectMessage>? messages})
    : thread =
          thread ??
          ChatThread(
            id: 'dm_1',
            name: 'Muhammad Amir',
            category: ChatCategory.oneToOne,
            lastMessageAt: DateTime(2026, 10, 1),
            peerUserId: 'peer',
          ),
      messages = messages ?? [];

  ChatThread thread;
  List<DirectMessage> messages;
  List<FeedbackTopic> topics = [];

  final StreamController<ChatEvent> controller = StreamController.broadcast();
  final ValueNotifier<bool> live = ValueNotifier(true);

  // call records
  final List<String> sentContents = [];
  final List<String> reads = [];
  final List<String> watched = [];
  final List<String> unwatched = [];
  final List<String> watchedTopics = [];
  int topicFetches = 0;
  int threadRefreshes = 0;

  // scripting
  Completer<DirectMessage>? holdSend;
  Object? failSendWith;
  int sendCount = 0;
  List<DirectMessage>? olderPage;
  int nextServerId = 1000;

  @override
  Stream<ChatEvent> get events => controller.stream;

  @override
  ValueListenable<bool> get isLive => live;

  @override
  Future<List<ChatThread>> getThreads() async => [thread];

  @override
  Future<List<ChatThread>> getByCategory(ChatCategory category) async =>
      thread.category == category ? [thread] : [];

  @override
  Future<ChatThread?> getThreadById(String id) async => thread;

  @override
  Future<ChatThread?> refreshThread(String id) async {
    threadRefreshes++;
    return thread;
  }

  @override
  Future<List<DirectMessage>> getDirectMessagesFor(String threadId) async =>
      List.of(messages);

  @override
  Future<List<DirectMessage>> getOlderDirectMessages(
    String threadId, {
    required String beforeMessageId,
  }) async => olderPage ?? const [];

  @override
  Future<DirectMessage> sendDirectMessage({
    required String threadId,
    required String content,
    required bool fromTeacher,
  }) async {
    sendCount++;
    sentContents.add(content);
    if (holdSend != null) {
      final hold = holdSend!;
      holdSend = null;
      return hold.future;
    }
    final fail = failSendWith;
    if (fail != null) throw fail;
    return DirectMessage(
      id: '${nextServerId++}',
      threadId: threadId,
      fromTeacher: fromTeacher,
      content: content.trim(),
      sentAt: DateTime.now(),
    );
  }

  @override
  Future<void> markDirectThreadRead(
    String threadId, {
    bool asParent = false,
  }) async => reads.add(threadId);

  @override
  Future<void> watchDirectThread(String threadId) async =>
      watched.add(threadId);

  @override
  Future<void> unwatchDirectThread(String threadId) async =>
      unwatched.add(threadId);

  // ─── feedback ───
  Object? failReplyWith;
  Completer<FeedbackMessage>? holdReply;
  int replyCount = 0;
  final List<String> replyContents = [];
  final List<String> topicReads = [];
  int nextMessageId = 5000;
  Object? failToggleWith;
  Object? failTopicsWith;

  @override
  Future<List<FeedbackTopic>> getFeedbackTopicsFor(String threadId) async {
    topicFetches++;
    final fail = failTopicsWith;
    if (fail != null) throw fail;
    return List.of(topics);
  }

  @override
  Future<FeedbackTopic> createFeedbackTopic({
    required String threadId,
    required String subject,
    required FeedbackTone tone,
    required String message,
  }) async {
    final fail = failReplyWith;
    if (fail != null) throw fail;
    return FeedbackTopic(
      id: '${nextServerId++}',
      threadId: threadId,
      subject: subject,
      tone: tone,
      createdAt: DateTime.now(),
      messages: [
        FeedbackMessage(
          id: '${nextMessageId++}',
          fromTeacher: true,
          content: message,
          sentAt: DateTime.now(),
        ),
      ],
    );
  }

  @override
  Future<FeedbackMessage> replyToTopic({
    required String topicId,
    required String content,
    required bool fromTeacher,
  }) async {
    replyCount++;
    replyContents.add(content);
    if (holdReply != null) {
      final hold = holdReply!;
      holdReply = null;
      return hold.future;
    }
    final fail = failReplyWith;
    if (fail != null) throw fail;
    return FeedbackMessage(
      id: '${nextMessageId++}',
      fromTeacher: fromTeacher,
      content: content.trim(),
      sentAt: DateTime.now(),
    );
  }

  @override
  Future<FeedbackTopic> toggleResolved(String topicId) async {
    final fail = failToggleWith;
    if (fail != null) throw fail;
    final t = topics.firstWhere((t) => t.id == topicId);
    return t.copyWith(isResolved: !t.isResolved);
  }

  @override
  Future<void> deleteTopic(String topicId) async {}

  @override
  Future<void> markTopicRead(String topicId, {bool asParent = false}) async =>
      topicReads.add(topicId);

  @override
  Future<void> watchFeedbackTopics(Iterable<String> topicIds) async =>
      watchedTopics.addAll(topicIds);

  @override
  Future<void> unwatchFeedbackTopics(Iterable<String> topicIds) async {}

  Future<void> dispose() => controller.close();
}

DirectMessage dm(
  String id,
  String content, {
  bool fromTeacher = false,
  DateTime? at,
}) => DirectMessage(
  id: id,
  threadId: 'dm_1',
  fromTeacher: fromTeacher,
  content: content,
  sentAt: at ?? DateTime(2026, 10, 1, 9, int.tryParse(id) ?? 0),
);

const networkError = NetworkException();

Future<void> pump([int ms = 20]) =>
    Future<void>.delayed(Duration(milliseconds: ms));
