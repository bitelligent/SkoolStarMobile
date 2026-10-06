import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';

abstract class ChatRepository {
  Future<List<ChatThread>> getThreads();
  Future<List<ChatThread>> getByCategory(ChatCategory category);
  Future<ChatThread?> getThreadById(String id);

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
  Future<void> markTopicRead(String topicId);

  Future<List<DirectMessage>> getDirectMessagesFor(String threadId);
  Future<DirectMessage> sendDirectMessage({
    required String threadId,
    required String content,
    required bool fromTeacher,
  });
  Future<void> markDirectThreadRead(String threadId);
}

class ChatRepositoryImpl implements ChatRepository {
  ChatRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;

  // ─── In-memory cache ────────────────────────────────────────────────
  // Seeded on first access and then mutated locally — simulates a real
  // backend so the UI gets instant feedback without re-reading the asset.

  List<ChatThread>? _threadsCache;
  final Map<String, List<FeedbackTopic>> _topicsCache = {};
  final Map<String, List<DirectMessage>> _directCache = {};
  bool _seeded = false;

  Future<void> _seed() async {
    if (_seeded) return;
    final data = await _dataSource.readJsonObject('assets/json/chats.json');

    final rawThreads = (data['threads'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    _threadsCache = rawThreads.map(ChatThread.fromJson).toList()
      ..sort((a, b) {
        if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
        return b.lastMessageAt.compareTo(a.lastMessageAt);
      });

    final rawTopics = (data['feedbackTopics'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    for (final json in rawTopics) {
      final topic = FeedbackTopic.fromJson(json);
      _topicsCache.putIfAbsent(topic.threadId, () => []).add(topic);
    }
    for (final list in _topicsCache.values) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final rawDirect = (data['directMessages'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    for (final json in rawDirect) {
      final m = DirectMessage.fromJson(json);
      _directCache.putIfAbsent(m.threadId, () => []).add(m);
    }
    for (final list in _directCache.values) {
      list.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    }

    _seeded = true;
  }

  // ─── Threads ────────────────────────────────────────────────────────

  @override
  Future<List<ChatThread>> getThreads() async {
    await _seed();
    return List.unmodifiable(_threadsCache ?? const []);
  }

  @override
  Future<List<ChatThread>> getByCategory(ChatCategory category) async {
    final all = await getThreads();
    return all.where((t) => t.category == category).toList();
  }

  @override
  Future<ChatThread?> getThreadById(String id) async {
    final all = await getThreads();
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  // ─── Feedback topics ────────────────────────────────────────────────

  @override
  Future<List<FeedbackTopic>> getFeedbackTopicsFor(String threadId) async {
    await _seed();
    final list = _topicsCache[threadId] ?? const <FeedbackTopic>[];
    return List.unmodifiable(list);
  }

  @override
  Future<FeedbackTopic> createFeedbackTopic({
    required String threadId,
    required String subject,
    required FeedbackTone tone,
    required String message,
  }) async {
    await _seed();
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final now = DateTime.now();
    final topic = FeedbackTopic(
      id: 'ft_${now.microsecondsSinceEpoch}',
      threadId: threadId,
      subject: subject.trim().isEmpty ? 'Feedback' : subject.trim(),
      tone: tone,
      createdAt: now,
      messages: [
        FeedbackMessage(
          id: 'fm_${now.microsecondsSinceEpoch}',
          fromTeacher: true,
          content: message.trim(),
          sentAt: now,
          isRead: true,
        ),
      ],
    );

    final list = _topicsCache.putIfAbsent(threadId, () => <FeedbackTopic>[]);
    list.insert(0, topic); // newest on top
    return topic;
  }

  @override
  Future<FeedbackMessage> replyToTopic({
    required String topicId,
    required String content,
    required bool fromTeacher,
  }) async {
    await _seed();
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final (list, idx) = _findTopic(topicId);
    if (list == null || idx == null) {
      throw StateError('Topic $topicId not found');
    }
    final topic = list[idx];
    final now = DateTime.now();
    final reply = FeedbackMessage(
      id: 'fm_${now.microsecondsSinceEpoch}',
      fromTeacher: fromTeacher,
      content: content.trim(),
      sentAt: now,
      isRead: true,
    );
    list[idx] = topic.copyWith(messages: [...topic.messages, reply]);
    return reply;
  }

  @override
  Future<FeedbackTopic> toggleResolved(String topicId) async {
    await _seed();
    final (list, idx) = _findTopic(topicId);
    if (list == null || idx == null) {
      throw StateError('Topic $topicId not found');
    }
    final updated = list[idx].copyWith(isResolved: !list[idx].isResolved);
    list[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await _seed();
    final (list, idx) = _findTopic(topicId);
    if (list == null || idx == null) return;
    list.removeAt(idx);
  }

  @override
  Future<void> markTopicRead(String topicId) async {
    await _seed();
    final (list, idx) = _findTopic(topicId);
    if (list == null || idx == null) return;
    final topic = list[idx];
    final updatedMessages = [
      for (final m in topic.messages)
        if (m.fromTeacher || m.isRead) m else m.copyWith(isRead: true),
    ];
    list[idx] = topic.copyWith(messages: updatedMessages);
  }

  // ─── Direct (1-to-1) messages ───────────────────────────────────────

  @override
  Future<List<DirectMessage>> getDirectMessagesFor(String threadId) async {
    await _seed();
    final list = _directCache[threadId] ?? const <DirectMessage>[];
    return List.unmodifiable(list);
  }

  @override
  Future<DirectMessage> sendDirectMessage({
    required String threadId,
    required String content,
    required bool fromTeacher,
  }) async {
    await _seed();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final msg = DirectMessage(
      id: 'dm_${now.microsecondsSinceEpoch}',
      threadId: threadId,
      fromTeacher: fromTeacher,
      content: content.trim(),
      sentAt: now,
      isRead: true,
    );
    _directCache.putIfAbsent(threadId, () => <DirectMessage>[]).add(msg);
    return msg;
  }

  @override
  Future<void> markDirectThreadRead(String threadId) async {
    await _seed();
    final list = _directCache[threadId];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      if (!m.fromTeacher && !m.isRead) {
        list[i] = m.copyWith(isRead: true);
      }
    }
  }

  // ─── Helpers ────────────────────────────────────────────────────────

  (List<FeedbackTopic>?, int?) _findTopic(String id) {
    for (final entry in _topicsCache.entries) {
      final i = entry.value.indexWhere((t) => t.id == id);
      if (i != -1) return (entry.value, i);
    }
    return (null, null);
  }
}
