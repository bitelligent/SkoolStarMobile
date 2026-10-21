import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/app_lifecycle.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_state.dart';

/// Cubit scoped to one feedback thread (one student, or one student + teacher
/// for parents): its topics, expansion state and send state.
///
/// Replies are optimistic with retry. New messages arrive live for the
/// topics this screen watches; list-level changes (new topic, resolved) are
/// not pushed by the backend, so the screen also refreshes quietly on a
/// timer and after a reconnect.
class FeedbackChatCubit extends SafeCubit<FeedbackChatState> {
  FeedbackChatCubit({
    required this.threadId,
    required ChatRepository repository,
    this.asParent = false,
    this.maxLength = 1000,
    this.minLength = 2,
    this.pollInterval = const Duration(seconds: 15),
    this.markReadDelay = const Duration(milliseconds: 500),
  }) : _repo = repository,
       super(const FeedbackChatState.initial());

  final String threadId;
  final ChatRepository _repo;

  /// True in the parent module: replies are sent as the parent and read
  /// receipts apply to the teacher's messages.
  final bool asParent;

  /// Server limits for a message.
  final int maxLength;
  final int minLength;

  final Duration pollInterval;
  final Duration markReadDelay;

  StreamSubscription<ChatEvent>? _events;
  VoidCallback? _liveListener;
  Timer? _poll;
  final Map<String, Timer> _readTimers = {};
  Set<String> _watched = {};
  Future<void> _sendQueue = Future.value();
  bool _refreshing = false;
  int _localSeq = 0;

  bool _isMine(FeedbackMessage m) => m.fromTeacher == !asParent;

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
          // Land inside the most recent conversation.
          expandedTopicIds: topics.isEmpty ? const {} : {topics.first.id},
          isLive: _repo.isLive.value,
        ),
      );
      await _startRealtime(topics);
      if (topics.isNotEmpty) _scheduleRead(topics.first.id);
    } on UnauthorizedException {
      rethrow;
    } on Exception catch (e) {
      emit(FeedbackChatState.error(_describe(e)));
    }
  }

  Future<void> _startRealtime(List<FeedbackTopic> topics) async {
    if (isClosed) return;
    _events ??= _repo.events.listen(_onEvent);
    if (_liveListener == null) {
      _liveListener = () {
        final s = state;
        if (s is FeedbackChatLoaded && s.isLive != _repo.isLive.value) {
          emit(s.copyWith(isLive: _repo.isLive.value));
        }
      };
      _repo.isLive.addListener(_liveListener!);
    }
    _poll ??= Timer.periodic(pollInterval, (_) {
      // No point hitting the server while the app is in the background.
      // No point hitting the server while the app is in the background.
      if (isAppInForeground) unawaited(refresh());
    });
    await _syncWatched(topics);
  }

  /// Keeps the realtime groups equal to the topics currently listed.
  Future<void> _syncWatched(List<FeedbackTopic> topics) async {
    final next = {for (final t in topics) t.id};
    final add = next.difference(_watched);
    final drop = _watched.difference(next);
    _watched = next;
    if (add.isNotEmpty) await _repo.watchFeedbackTopics(add);
    if (drop.isNotEmpty) await _repo.unwatchFeedbackTopics(drop);
  }

  // ─── Realtime / refresh ─────────────────────────────────────────────

  void _onEvent(ChatEvent e) {
    switch (e) {
      case FeedbackMessageReceived():
        final s = state;
        if (s is! FeedbackChatLoaded) return;
        if (!s.topics.any((t) => t.id == e.topicId)) return; // not ours
        _mergeMessage(e.topicId, e.message);
        if (!_isMine(e.message) && s.expandedTopicIds.contains(e.topicId)) {
          _scheduleRead(e.topicId);
        }
      case FeedbackListChanged() || ChatResync():
        unawaited(refresh());
      default:
        break;
    }
  }

  /// Quietly re-fetches the topics, keeping local (unsent) messages and the
  /// current expansion.
  Future<void> refresh() async {
    final s = state;
    if (_refreshing || s is! FeedbackChatLoaded) return;
    _refreshing = true;
    try {
      final fresh = await _repo.getFeedbackTopicsFor(threadId);
      final cur = state;
      if (isClosed || cur is! FeedbackChatLoaded) return;

      final merged = [
        for (final t in fresh)
          _withLocalMessages(
            t,
            cur.topics.where((o) => o.id == t.id).firstOrNull,
          ),
      ];
      emit(cur.copyWith(topics: merged));
      await _syncWatched(merged);
    } on UnauthorizedException {
      rethrow;
    } on Exception {
      // Transient; the next tick / event retries.
    } finally {
      _refreshing = false;
    }
  }

  /// Server topic + the user's not-yet-confirmed messages from [local].
  FeedbackTopic _withLocalMessages(FeedbackTopic server, FeedbackTopic? local) {
    if (local == null) return server;
    final serverIds = {for (final m in server.messages) m.id};
    final pending = [
      for (final m in local.messages)
        if (m.status != MessageStatus.sent && !serverIds.contains(m.id)) m,
    ];
    if (pending.isEmpty) return server;
    // A pending message the server already has (matched by text) is done.
    final unmatched = [
      for (final p in pending)
        if (!(p.status == MessageStatus.sending &&
            server.messages.any(
              (m) => _isMine(m) && m.content.trim() == p.content.trim(),
            )))
          p,
    ];
    return server.copyWith(messages: [...server.messages, ...unmatched]);
  }

  void _mergeMessage(String topicId, FeedbackMessage incoming) {
    final s = state;
    if (isClosed || s is! FeedbackChatLoaded) return;
    emit(
      s.copyWith(
        topics: [
          for (final t in s.topics)
            if (t.id != topicId)
              t
            else
              t.copyWith(messages: _mergedMessages(t.messages, incoming)),
        ],
      ),
    );
  }

  List<FeedbackMessage> _mergedMessages(
    List<FeedbackMessage> list,
    FeedbackMessage incoming,
  ) {
    final out = [...list];
    final byId = out.indexWhere((m) => m.id == incoming.id);
    if (byId != -1) {
      out[byId] = incoming.copyWith(isRead: out[byId].isRead);
      return out;
    }
    // My own message echoed by the push before the HTTP answer: adopt it.
    final pending = _isMine(incoming)
        ? out.indexWhere(
            (m) =>
                m.status == MessageStatus.sending &&
                m.content.trim() == incoming.content.trim(),
          )
        : -1;
    if (pending != -1) {
      out[pending] = incoming.copyWith(isRead: true);
    } else {
      out.add(incoming);
    }
    return _ordered(out);
  }

  /// Confirmed messages by time, then my unconfirmed ones in write order.
  List<FeedbackMessage> _ordered(List<FeedbackMessage> list) {
    final confirmed =
        [
          for (final m in list)
            if (m.status == MessageStatus.sent) m,
        ]..sort((a, b) {
          final c = a.sentAt.compareTo(b.sentAt);
          if (c != 0) return c;
          return (int.tryParse(a.id) ?? 0).compareTo(int.tryParse(b.id) ?? 0);
        });
    return [
      ...confirmed,
      for (final m in list)
        if (m.status != MessageStatus.sent) m,
    ];
  }

  // ─── UI actions ─────────────────────────────────────────────────────

  void toggleExpanded(String topicId) {
    final s = state;
    if (s is! FeedbackChatLoaded) return;
    final updated = Set<String>.from(s.expandedTopicIds);
    if (updated.contains(topicId)) {
      updated.remove(topicId);
    } else {
      updated.add(topicId);
      _scheduleRead(topicId);
    }
    emit(s.copyWith(expandedTopicIds: updated));
  }

  void _scheduleRead(String topicId) {
    _readTimers[topicId]?.cancel();
    _readTimers[topicId] = Timer(markReadDelay, () {
      _readTimers.remove(topicId);
      if (isClosed) return;
      unawaited(_markRead(topicId));
    });
  }

  Future<void> _markRead(String topicId) async {
    await _repo.markTopicRead(topicId, asParent: asParent);
    final s = state;
    if (isClosed || s is! FeedbackChatLoaded) return;
    emit(
      s.copyWith(
        topics: [
          for (final t in s.topics)
            if (t.id != topicId)
              t
            else
              t.copyWith(
                messages: [
                  for (final m in t.messages)
                    if (!_isMine(m) && !m.isRead)
                      m.copyWith(isRead: true)
                    else
                      m,
                ],
              ),
        ],
      ),
    );
  }

  Future<bool> createTopic({
    required String subject,
    required FeedbackTone tone,
    required String message,
  }) async {
    final s = state;
    if (s is! FeedbackChatLoaded || s.creatingTopic) return false;
    final text = message.trim();
    if (text.length < minLength || text.length > maxLength) return false;

    emit(s.copyWith(creatingTopic: true));
    try {
      final topic = await _repo.createFeedbackTopic(
        threadId: threadId,
        subject: subject,
        tone: tone,
        message: text,
      );
      final cur = state;
      if (isClosed || cur is! FeedbackChatLoaded) return true;
      final topics = [topic, ...cur.topics.where((t) => t.id != topic.id)];
      emit(
        cur.copyWith(
          topics: topics,
          expandedTopicIds: {topic.id, ...cur.expandedTopicIds},
          creatingTopic: false,
        ),
      );
      await _syncWatched(topics);
      return true;
    } on UnauthorizedException {
      rethrow;
    } on Exception {
      final cur = state;
      if (!isClosed && cur is FeedbackChatLoaded) {
        emit(cur.copyWith(creatingTopic: false));
      }
      return false;
    }
  }

  /// Queues a reply. Returns `false` only when the text is rejected locally;
  /// delivery failures show on the message with retry / discard.
  Future<bool> replyToTopic(String topicId, String content) async {
    final s = state;
    if (s is! FeedbackChatLoaded) return false;
    final text = content.trim();
    if (text.length < minLength || text.length > maxLength) return false;
    if (!s.topics.any((t) => t.id == topicId)) return false;

    final clientId =
        'local_${DateTime.now().microsecondsSinceEpoch}'
        '_${_localSeq++}';
    final pending = FeedbackMessage(
      id: clientId,
      clientId: clientId,
      fromTeacher: !asParent,
      content: text,
      sentAt: DateTime.now(),
      status: MessageStatus.sending,
    );
    _appendLocal(topicId, pending);
    _enqueue(() => _deliver(topicId, clientId));
    return true;
  }

  void _appendLocal(String topicId, FeedbackMessage m) {
    final s = state;
    if (s is! FeedbackChatLoaded) return;
    emit(
      s.copyWith(
        topics: [
          for (final t in s.topics)
            if (t.id == topicId)
              t.copyWith(messages: [...t.messages, m])
            else
              t,
        ],
      ),
    );
  }

  void _enqueue(Future<void> Function() job) {
    _sendQueue = _sendQueue.then((_) => job()).catchError((Object _) {});
  }

  FeedbackMessage? _find(String topicId, String clientId) {
    final s = state;
    if (s is! FeedbackChatLoaded) return null;
    final topic = s.topics.where((t) => t.id == topicId).firstOrNull;
    return topic?.messages.where((m) => m.clientId == clientId).firstOrNull;
  }

  Future<void> _deliver(String topicId, String clientId) async {
    final pending = _find(topicId, clientId);
    if (pending == null || pending.status == MessageStatus.sent) return;
    try {
      final sent = await _repo.replyToTopic(
        topicId: topicId,
        content: pending.content,
        fromTeacher: !asParent,
      );
      _confirm(topicId, clientId, sent);
    } on Exception {
      _setStatus(topicId, clientId, MessageStatus.failed);
    }
  }

  void _confirm(String topicId, String clientId, FeedbackMessage sent) {
    final s = state;
    if (isClosed || s is! FeedbackChatLoaded) return;
    emit(
      s.copyWith(
        topics: [
          for (final t in s.topics)
            if (t.id != topicId)
              t
            else
              t.copyWith(messages: _confirmIn(t.messages, clientId, sent)),
        ],
      ),
    );
  }

  List<FeedbackMessage> _confirmIn(
    List<FeedbackMessage> list,
    String clientId,
    FeedbackMessage sent,
  ) {
    final out = [...list];
    final i = out.indexWhere((m) => m.clientId == clientId);
    final already = out.indexWhere(
      (m) => m.id == sent.id && m.clientId == null,
    );
    if (i == -1) {
      if (already == -1) out.add(sent);
    } else if (already != -1) {
      out.removeAt(i); // the push got there first
    } else {
      out[i] = sent;
    }
    return _ordered(out);
  }

  void _setStatus(String topicId, String clientId, MessageStatus status) {
    final s = state;
    if (isClosed || s is! FeedbackChatLoaded) return;
    emit(
      s.copyWith(
        topics: [
          for (final t in s.topics)
            if (t.id != topicId)
              t
            else
              t.copyWith(
                messages: [
                  for (final m in t.messages)
                    if (m.clientId == clientId)
                      m.copyWith(status: status)
                    else
                      m,
                ],
              ),
        ],
      ),
    );
  }

  /// Re-sends a failed reply, first checking the server did not already get
  /// it (a timeout can hide a successful send).
  void retryReply(String topicId, String clientId) {
    final m = _find(topicId, clientId);
    if (m == null || m.status != MessageStatus.failed) return;
    _setStatus(topicId, clientId, MessageStatus.sending);
    _enqueue(() async {
      final delivered = await _findDelivered(topicId, m);
      if (delivered != null) {
        _confirm(topicId, clientId, delivered);
      } else {
        await _deliver(topicId, clientId);
      }
    });
  }

  Future<FeedbackMessage?> _findDelivered(
    String topicId,
    FeedbackMessage pending,
  ) async {
    try {
      final fresh = await _repo.getFeedbackTopicsFor(threadId);
      final topic = fresh.where((t) => t.id == topicId).firstOrNull;
      final s = state;
      if (topic == null || s is! FeedbackChatLoaded) return null;
      final known = {
        for (final t in s.topics.where((t) => t.id == topicId))
          for (final m in t.messages) m.id,
      };
      final since = pending.sentAt.subtract(const Duration(minutes: 2));
      for (final m in topic.messages.reversed) {
        if (!known.contains(m.id) &&
            _isMine(m) &&
            m.content.trim() == pending.content.trim() &&
            !m.sentAt.isBefore(since)) {
          return m;
        }
      }
    } on Exception {
      // Cannot tell: fall through to a normal send.
    }
    return null;
  }

  void discardReply(String topicId, String clientId) {
    final s = state;
    if (s is! FeedbackChatLoaded) return;
    emit(
      s.copyWith(
        topics: [
          for (final t in s.topics)
            if (t.id != topicId)
              t
            else
              t.copyWith(
                messages: [
                  for (final m in t.messages)
                    if (m.clientId != clientId) m,
                ],
              ),
        ],
      ),
    );
  }

  Future<void> toggleResolved(String topicId) async {
    final s = state;
    if (s is! FeedbackChatLoaded) return;
    final current = s.topics.where((t) => t.id == topicId).firstOrNull;
    if (current == null) return;
    // Optimistic; roll back if the server refuses.
    _replaceTopic(current.copyWith(isResolved: !current.isResolved));
    try {
      final updated = await _repo.toggleResolved(topicId);
      _replaceTopic(
        _keepMessages(updated, topicId),
      );
    } on UnauthorizedException {
      rethrow;
    } on Exception {
      _replaceTopic(current);
    }
  }

  FeedbackTopic _keepMessages(FeedbackTopic updated, String topicId) {
    final s = state;
    if (s is! FeedbackChatLoaded) return updated;
    final local = s.topics.where((t) => t.id == topicId).firstOrNull;
    return local == null
        ? updated
        : local.copyWith(isResolved: updated.isResolved);
  }

  void _replaceTopic(FeedbackTopic topic) {
    final s = state;
    if (isClosed || s is! FeedbackChatLoaded) return;
    emit(
      s.copyWith(
        topics: [
          for (final t in s.topics)
            if (t.id == topic.id) topic else t,
        ],
      ),
    );
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
      await _syncWatched(
        previous.where((t) => t.id != topicId).toList(),
      );
    } on UnauthorizedException {
      rethrow;
    } on Exception {
      final cur = state;
      if (!isClosed && cur is FeedbackChatLoaded) {
        emit(cur.copyWith(topics: previous));
      }
    }
  }

  static String _describe(Object e) =>
      e is ApiException ? e.message : 'Something went wrong. Please retry.';

  @override
  Future<void> close() async {
    _poll?.cancel();
    for (final t in _readTimers.values) {
      t.cancel();
    }
    await _events?.cancel();
    final listener = _liveListener;
    if (listener != null) _repo.isLive.removeListener(listener);
    if (_watched.isNotEmpty) {
      unawaited(_repo.unwatchFeedbackTopics(_watched));
    }
    return super.close();
  }
}
