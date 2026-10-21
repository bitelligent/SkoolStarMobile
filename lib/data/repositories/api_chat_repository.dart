import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/realtime/chat_realtime.dart'
    as rt;
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';

/// Chat backed by the live API + SignalR hubs.
///
/// One instance per perspective: teachers list feedback from
/// `feedback/history`, parents from `feedback/conversations` (the history
/// route is teacher-only).
class ApiChatRepository extends ChatRepository {
  ApiChatRepository({
    required ApiClient apiClient,
    required rt.ChatRealtime realtime,
    required this.asParent,
  }) : _api = apiClient,
       _realtime = realtime {
    _sub = _realtime.events.listen(_onRealtime);
  }

  final ApiClient _api;
  final rt.ChatRealtime _realtime;
  final bool asParent;

  late final StreamSubscription<rt.RealtimeEvent> _sub;
  final StreamController<ChatEvent> _events = StreamController.broadcast();

  final Map<String, ChatThread> _threads = {};
  final Map<String, List<FeedbackTopic>> _topics = {};

  @override
  Stream<ChatEvent> get events => _events.stream;

  @override
  ValueListenable<bool> get isLive => _realtime.isLive;

  void dispose() {
    unawaited(_sub.cancel());
    unawaited(_events.close());
  }

  // ─── Threads ────────────────────────────────────────────────────────

  @override
  Future<List<ChatThread>> getThreads() async {
    final results = await Future.wait([
      _settle(_loadDirectThreads()),
      _settle(_loadFeedbackThreads()),
    ]);
    final direct = results[0];
    final feedback = results[1];

    // One list failing must not blank the other tab; only fail when both do.
    if (direct.error != null && feedback.error != null) {
      throw direct.error!;
    }
    final threads = [
      ...(direct.value ??
          _threads.values.where((t) => t.category == ChatCategory.oneToOne)),
      ...(feedback.value ??
          _threads.values.where((t) => t.category == ChatCategory.feedback)),
    ];
    return List.unmodifiable(threads);
  }

  Future<List<ChatThread>> _loadDirectThreads() async {
    final json = await _api.get(ApiEndpoints.chatThreads);
    final fresh = [
      for (final row in asObjects(json)) ?directThreadFromJson(row),
    ]..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    _threads.removeWhere((_, t) => t.category == ChatCategory.oneToOne);
    for (final t in fresh) {
      _threads[t.id] = t;
    }
    return fresh;
  }

  Future<List<ChatThread>> _loadFeedbackThreads({int? studentId}) async {
    final rows = await _fetchFeedbackRows(studentId: studentId);
    final fresh = feedbackThreadsFromRows(rows, asParent: asParent);
    _indexTopics(rows, replaceAll: studentId == null);
    if (studentId == null) {
      _threads.removeWhere((_, t) => t.category == ChatCategory.feedback);
    }
    for (final t in fresh) {
      _threads[t.id] = t;
    }
    return fresh;
  }

  Future<List<Json>> _fetchFeedbackRows({int? studentId}) async {
    final json = await _api.get(
      asParent
          ? ApiEndpoints.feedbackConversations
          : ApiEndpoints.feedbackHistory,
      query: {'studentId': studentId},
    );
    return asObjects(json);
  }

  void _indexTopics(List<Json> rows, {required bool replaceAll}) {
    final byThread = <String, List<FeedbackTopic>>{};
    for (final row in rows) {
      final studentId = row.intOrNull('studentId');
      if (studentId == null) continue;
      final key = feedbackThreadId(
        studentId,
        teacherKey: asParent ? teacherNameOf(row) : null,
      );
      final topic = feedbackTopicFromJson(
        row,
        threadId: key,
        asParent: asParent,
      );
      if (topic != null) byThread.putIfAbsent(key, () => []).add(topic);
    }
    for (final list in byThread.values) {
      list.sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));
    }
    if (replaceAll) _topics.clear();
    _topics.addAll(byThread);
  }

  @override
  Future<List<ChatThread>> getByCategory(ChatCategory category) async {
    final all = await getThreads();
    return all.where((t) => t.category == category).toList();
  }

  @override
  Future<ChatThread?> getThreadById(String id) async {
    final known = _threads[id];
    if (known != null) return known;
    await getThreads();
    return _threads[id];
  }

  @override
  Future<ChatThread?> refreshThread(String id) async {
    if (serverDirectThreadId(id) != null) {
      try {
        await _loadDirectThreads();
      } on UnauthorizedException {
        rethrow;
      } on ApiException {
        // Offline: the cached copy is still the best we have.
      }
      return _threads[id];
    }
    return getThreadById(id);
  }

  // ─── Feedback ───────────────────────────────────────────────────────

  @override
  Future<List<FeedbackTopic>> getFeedbackTopicsFor(String threadId) async {
    final parsed = parseFeedbackThreadId(threadId);
    if (parsed == null) return const [];
    try {
      final rows = await _fetchFeedbackRows(studentId: parsed.studentId);
      // Replace only this student's threads; others are untouched.
      _topics.removeWhere(
        (key, _) => parseFeedbackThreadId(key)?.studentId == parsed.studentId,
      );
      _indexTopics(rows, replaceAll: false);
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      // Offline: show what we already have rather than an error page.
      if (!_topics.containsKey(threadId)) rethrow;
    }
    return List.unmodifiable(_topics[threadId] ?? const <FeedbackTopic>[]);
  }

  @override
  Future<FeedbackTopic> createFeedbackTopic({
    required String threadId,
    required String subject,
    required FeedbackTone tone,
    required String message,
  }) async {
    final parsed = parseFeedbackThreadId(threadId);
    if (parsed == null) {
      throw const ValidationException('Select a student to send feedback to.');
    }
    final body = message.trim();
    final json = await _api.post(
      ApiEndpoints.sendFeedback,
      body: {
        'studentId': parsed.studentId,
        'content': body,
        'isPositive': tone == FeedbackTone.positive,
        'subject': subject.trim().isEmpty ? 'Feedback' : subject.trim(),
        'tone': toneToServer(tone),
      },
    );
    final map = json is Json ? json : const <String, dynamic>{};
    final id = map.strOrNull('id') ?? map.strOrNull('feedbackId');
    if (id == null) throw const ParseException();
    final first = map['messageDto'] is Json
        ? feedbackMessageFromJson(map['messageDto'] as Json)
        : null;
    final topic = FeedbackTopic(
      id: id,
      threadId: threadId,
      subject: subject.trim().isEmpty ? 'Feedback' : subject.trim(),
      tone: tone == FeedbackTone.positive
          ? FeedbackTone.positive
          : FeedbackTone.needsAttention,
      createdAt: first?.sentAt ?? DateTime.now(),
      messages: [
        first ??
            FeedbackMessage(
              id: 'seed_$id',
              fromTeacher: true,
              content: body,
              sentAt: DateTime.now(),
            ),
      ],
    );
    _topics.putIfAbsent(threadId, () => []).insert(0, topic);
    return topic;
  }

  @override
  Future<FeedbackMessage> replyToTopic({
    required String topicId,
    required String content,
    required bool fromTeacher,
  }) async {
    final json = await _api.post(
      asParent
          ? ApiEndpoints.feedbackReply(topicId)
          : ApiEndpoints.feedbackMessages(topicId),
      body: {'message': content.trim()},
    );
    final dto = json is Json ? json['messageDto'] : null;
    final message = dto is Json ? feedbackMessageFromJson(dto) : null;
    if (message == null) throw const ParseException();
    return message;
  }

  @override
  Future<FeedbackTopic> toggleResolved(String topicId) async {
    final current = _findTopic(topicId);
    final resolve = !(current?.isResolved ?? false);
    await _api.post(
      resolve
          ? ApiEndpoints.feedbackResolve(topicId)
          : ApiEndpoints.feedbackUnresolve(topicId),
    );
    if (current == null) throw const ParseException();
    final updated = current.copyWith(isResolved: resolve);
    _replaceTopic(updated);
    return updated;
  }

  @override
  Future<void> deleteTopic(String topicId) async {
    await _api.delete(ApiEndpoints.feedbackById(topicId));
    for (final list in _topics.values) {
      list.removeWhere((t) => t.id == topicId);
    }
  }

  @override
  Future<void> markTopicRead(String topicId, {bool asParent = false}) async {
    try {
      await _api.post(ApiEndpoints.feedbackRead(topicId));
    } on ApiException catch (e) {
      if (e is UnauthorizedException) rethrow;
      // Read receipts are best effort; the next refresh reconciles.
      debugPrint('markTopicRead($topicId) failed: $e');
    }
  }

  FeedbackTopic? _findTopic(String id) {
    for (final list in _topics.values) {
      for (final t in list) {
        if (t.id == id) return t;
      }
    }
    return null;
  }

  void _replaceTopic(FeedbackTopic topic) {
    final list = _topics[topic.threadId];
    if (list == null) return;
    final i = list.indexWhere((t) => t.id == topic.id);
    if (i != -1) list[i] = topic;
  }

  // ─── 1-to-1 ─────────────────────────────────────────────────────────

  Future<String> _peerOf(String threadId) async {
    final thread = await getThreadById(threadId);
    if (thread == null) throw const NotFoundException('Chat not found.');
    return thread.peerUserId;
  }

  Future<List<DirectMessage>> _fetchMessages(
    String threadId, {
    String? beforeMessageId,
  }) async {
    final serverId = serverDirectThreadId(threadId);
    if (serverId == null) throw const NotFoundException('Chat not found.');
    final peer = await _peerOf(threadId);
    final json = await _api.get(
      ApiEndpoints.chatMessages(serverId),
      query: {
        // The server honours `take` / `beforeId`; the PDF documents
        // `pageSize` / `beforeMessageId`. Send both so either works.
        'take': ChatRepository.pageSize,
        'pageSize': ChatRepository.pageSize,
        'beforeId': beforeMessageId,
        'beforeMessageId': beforeMessageId,
      },
    );
    final all = [
      for (final row in asObjects(json))
        ?directMessageFromJson(
          row,
          threadId: threadId,
          peerUserId: peer,
          asParent: asParent,
        ),
    ]..sort(_byTimeThenId);
    return all;
  }

  static int _byTimeThenId(DirectMessage a, DirectMessage b) {
    final c = a.sentAt.compareTo(b.sentAt);
    if (c != 0) return c;
    return (int.tryParse(a.id) ?? 0).compareTo(int.tryParse(b.id) ?? 0);
  }

  @override
  Future<List<DirectMessage>> getDirectMessagesFor(String threadId) async {
    final page = await _fetchMessages(threadId);
    // The server may ignore the page size (it did when probed): keep the
    // newest page only so older history loads on demand.
    return page.length > ChatRepository.pageSize
        ? page.sublist(page.length - ChatRepository.pageSize)
        : page;
  }

  @override
  Future<List<DirectMessage>> getOlderDirectMessages(
    String threadId, {
    required String beforeMessageId,
  }) async {
    final before = int.tryParse(beforeMessageId);
    final page = await _fetchMessages(
      threadId,
      beforeMessageId: beforeMessageId,
    );
    // Guard against a server that ignores the cursor.
    final older = before == null
        ? page
        : page.where((m) => (int.tryParse(m.id) ?? 0) < before).toList();
    return older.length > ChatRepository.pageSize
        ? older.sublist(older.length - ChatRepository.pageSize)
        : older;
  }

  @override
  Future<DirectMessage> sendDirectMessage({
    required String threadId,
    required String content,
    required bool fromTeacher,
  }) async {
    final serverId = serverDirectThreadId(threadId);
    if (serverId == null) throw const NotFoundException('Chat not found.');
    final peer = await _peerOf(threadId);
    final json = await _api.post(
      ApiEndpoints.chatMessages(serverId),
      body: {'body': content.trim(), 'replyToMessageId': null},
    );
    final dto = json is Json ? json['messageDto'] : null;
    final message = dto is Json
        ? directMessageFromJson(
            dto,
            threadId: threadId,
            peerUserId: peer,
            asParent: asParent,
          )
        : null;
    if (message == null) throw const ParseException();
    return message;
  }

  @override
  Future<void> markDirectThreadRead(
    String threadId, {
    bool asParent = false,
  }) async {
    final serverId = serverDirectThreadId(threadId);
    if (serverId == null) return;
    try {
      await _api.post(ApiEndpoints.chatRead(serverId));
    } on ApiException catch (e) {
      if (e is UnauthorizedException) rethrow;
      debugPrint('markDirectThreadRead($threadId) failed: $e');
    }
  }

  // ─── Realtime ───────────────────────────────────────────────────────

  @override
  Future<void> watchDirectThread(String threadId) async {
    final id = serverDirectThreadId(threadId);
    if (id != null) await _realtime.joinThread(id);
  }

  @override
  Future<void> unwatchDirectThread(String threadId) async {
    final id = serverDirectThreadId(threadId);
    if (id != null) await _realtime.leaveThread(id);
  }

  @override
  Future<void> watchFeedbackTopics(Iterable<String> topicIds) async {
    for (final raw in topicIds) {
      final id = int.tryParse(raw);
      if (id != null) await _realtime.joinFeedback(id);
    }
  }

  @override
  Future<void> unwatchFeedbackTopics(Iterable<String> topicIds) async {
    for (final raw in topicIds) {
      final id = int.tryParse(raw);
      if (id != null) await _realtime.leaveFeedback(id);
    }
  }

  void _onRealtime(rt.RealtimeEvent e) {
    if (_events.isClosed) return;
    switch (e) {
      case rt.DirectMessageCreated():
        final threadId = directThreadId(e.threadId);
        final thread = _threads[threadId];
        if (thread == null) {
          _events.add(DirectThreadChanged(threadId));
          return;
        }
        final message = directMessageFromJson(
          e.message,
          threadId: threadId,
          peerUserId: thread.peerUserId,
          asParent: asParent,
        );
        if (message == null) return;
        _events.add(DirectMessageReceived(threadId, message));
      case rt.DirectThreadUpdated():
        _events.add(DirectThreadChanged(directThreadId(e.threadId)));
      case rt.PresenceChanged():
        for (final t in _threads.values.toList()) {
          if (t.peerUserId == e.userId) {
            _threads[t.id] = t.copyWith(isOnline: e.online);
          }
        }
        _events.add(PeerPresenceChanged(e.userId, online: e.online));
      case rt.FeedbackMessageCreated():
        final message = feedbackMessageFromJson(e.message, isRead: false);
        if (message == null) return;
        _events.add(FeedbackMessageReceived('${e.feedbackId}', message));
      case rt.FeedbackListChanged():
        _events.add(const FeedbackListChanged());
      case rt.RealtimeResync():
        _events.add(const ChatResync());
    }
  }
}

class _Settled<T> {
  const _Settled(this.value, this.error);
  final T? value;
  final ApiException? error;
}

Future<_Settled<T>> _settle<T>(Future<T> f) async {
  try {
    return _Settled(await f, null);
  } on UnauthorizedException {
    rethrow;
  } on ApiException catch (e) {
    return _Settled(null, e);
  }
}
