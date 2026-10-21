import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/realtime/signalr_connection.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';

/// Raw (unmapped) events from the two chat hubs.
sealed class RealtimeEvent {
  const RealtimeEvent();
}

/// `MessageCreated` on `/hubs/chat`.
class DirectMessageCreated extends RealtimeEvent {
  const DirectMessageCreated(this.threadId, this.message);
  final int threadId;
  final Json message;
}

/// `ThreadUpdated` on `/hubs/chat` (read state / last message changed).
class DirectThreadUpdated extends RealtimeEvent {
  const DirectThreadUpdated(this.threadId);
  final int threadId;
}

/// `PresenceChanged` on `/hubs/chat`.
class PresenceChanged extends RealtimeEvent {
  const PresenceChanged(this.userId, {required this.online});
  final String userId;
  final bool online;
}

/// `MessageCreated` on `/hubs/feedback-chat`.
class FeedbackMessageCreated extends RealtimeEvent {
  const FeedbackMessageCreated(this.feedbackId, this.message);
  final int feedbackId;
  final Json message;
}

/// Any other feedback-hub event (e.g. `FeedbackThreadCreated`): the list
/// should be refreshed.
class FeedbackListChanged extends RealtimeEvent {
  const FeedbackListChanged();
}

/// A connection came back after a drop. Group memberships have been
/// restored; anything sent while offline was missed, so callers must
/// re-fetch what they show.
class RealtimeResync extends RealtimeEvent {
  const RealtimeResync();
}

/// Both chat hubs behind one object: connection lifecycle, group
/// membership that survives reconnects, de-duplicated typed events.
class ChatRealtime {
  ChatRealtime({
    required SignalRConnection chatHub,
    required SignalRConnection feedbackHub,
  }) : _chat = chatHub,
       _feedback = feedbackHub {
    _subs
      ..add(_chat.messages.listen(_onChatMessage))
      ..add(_feedback.messages.listen(_onFeedbackMessage))
      ..add(_chat.reconnected.listen((_) => _onReconnected()))
      ..add(_feedback.reconnected.listen((_) => _onReconnected()));
    _chat.status.addListener(_onStatus);
    _feedback.status.addListener(_onStatus);
  }

  /// Builds the production hubs against [baseUrl].
  factory ChatRealtime.forServer({
    required String baseUrl,
    required FutureOr<String?> Function() accessToken,
  }) => ChatRealtime(
    chatHub: SignalRConnection(
      baseUrl: baseUrl,
      path: '/hubs/chat',
      accessToken: accessToken,
    ),
    feedbackHub: SignalRConnection(
      baseUrl: baseUrl,
      path: '/hubs/feedback-chat',
      accessToken: accessToken,
    ),
  );

  final SignalRConnection _chat;
  final SignalRConnection _feedback;
  final List<StreamSubscription<Object?>> _subs = [];
  final StreamController<RealtimeEvent> _events = StreamController.broadcast();
  final ValueNotifier<bool> _live = ValueNotifier(false);

  // Reference counted so two screens can hold the same group.
  final Map<int, int> _threads = {};
  final Map<int, int> _feedbacks = {};

  // The server delivers a message to both the user's group and the thread
  // group, so it arrives twice while a thread is open.
  final LinkedHashSet<String> _seen = LinkedHashSet();

  Stream<RealtimeEvent> get events => _events.stream;

  /// `true` while both hubs are connected (messages arrive instantly).
  ValueListenable<bool> get isLive => _live;

  void start() {
    _chat.start();
    _feedback.start();
  }

  Future<void> stop() async {
    _threads.clear();
    _feedbacks.clear();
    _seen.clear();
    await Future.wait([_chat.stop(), _feedback.stop()]);
    _live.value = false;
  }

  /// Call when the app returns to the foreground.
  void onAppResumed() {
    _chat.verifyAlive();
    _feedback.verifyAlive();
  }

  // ─── Groups ─────────────────────────────────────────────────────────

  Future<void> joinThread(int id) => _join(_threads, id, _chat, 'JoinThread');
  Future<void> leaveThread(int id) =>
      _leave(_threads, id, _chat, 'LeaveThread');
  Future<void> joinFeedback(int id) =>
      _join(_feedbacks, id, _feedback, 'JoinFeedback');
  Future<void> leaveFeedback(int id) =>
      _leave(_feedbacks, id, _feedback, 'LeaveFeedback');

  Future<void> _join(
    Map<int, int> groups,
    int id,
    SignalRConnection hub,
    String method,
  ) async {
    final count = groups[id] ?? 0;
    groups[id] = count + 1;
    if (count == 0 && hub.isConnected) await _safeInvoke(hub, method, id);
    // Not connected: restored by _restoreGroups once the hub is up.
  }

  Future<void> _leave(
    Map<int, int> groups,
    int id,
    SignalRConnection hub,
    String method,
  ) async {
    final count = groups[id];
    if (count == null) return;
    if (count > 1) {
      groups[id] = count - 1;
      return;
    }
    groups.remove(id);
    if (hub.isConnected) await _safeInvoke(hub, method, id);
  }

  Future<void> _safeInvoke(SignalRConnection hub, String m, int id) async {
    try {
      await hub.invoke(m, [id]);
    } on Object catch (e) {
      // Re-attempted on the next reconnect; the REST resync covers the gap.
      debugPrint('$m($id) failed: $e');
    }
  }

  Future<void> _restoreGroups(SignalRConnection hub) async {
    final groups = identical(hub, _chat) ? _threads : _feedbacks;
    final method = identical(hub, _chat) ? 'JoinThread' : 'JoinFeedback';
    for (final id in groups.keys.toList()) {
      if (!hub.isConnected) return;
      await _safeInvoke(hub, method, id);
    }
  }

  // ─── Events ─────────────────────────────────────────────────────────

  void _onStatus() {
    final live = _chat.isConnected && _feedback.isConnected;
    if (_live.value != live) _live.value = live;
    for (final hub in [_chat, _feedback]) {
      if (hub.isConnected) unawaited(_restoreGroups(hub));
    }
  }

  void _onReconnected() {
    // Groups are restored via _onStatus; tell listeners to re-fetch.
    _emit(const RealtimeResync());
  }

  void _onChatMessage(HubMessage m) {
    final arg = m.arguments.isEmpty ? null : m.arguments.first;
    if (arg is! Json) return;
    switch (m.target) {
      case 'MessageCreated':
        final message = arg['message'];
        final threadId = arg.intOrNull('threadId');
        if (message is! Json || threadId == null) return;
        if (_isDuplicate('dm:${message['id']}')) return;
        _emit(DirectMessageCreated(threadId, message));
      case 'ThreadUpdated':
        final threadId = arg.intOrNull('threadId');
        if (threadId != null) _emit(DirectThreadUpdated(threadId));
      case 'PresenceChanged':
        final userId = arg.strOrNull('userId');
        if (userId != null) {
          _emit(PresenceChanged(userId, online: arg.boolean('online')));
        }
      default:
        debugPrint('Unhandled chat event ${m.target}');
    }
  }

  void _onFeedbackMessage(HubMessage m) {
    final arg = m.arguments.isEmpty ? null : m.arguments.first;
    if (m.target == 'MessageCreated' && arg is Json) {
      final message = arg['message'];
      final feedbackId = arg.intOrNull('feedbackId');
      if (message is Json && feedbackId != null) {
        if (_isDuplicate('fb:${message['id']}')) return;
        _emit(FeedbackMessageCreated(feedbackId, message));
        return;
      }
    }
    _emit(const FeedbackListChanged());
  }

  bool _isDuplicate(String key) {
    if (!_seen.add(key)) return true;
    if (_seen.length > 300) _seen.remove(_seen.first);
    return false;
  }

  void _emit(RealtimeEvent e) {
    if (!_events.isClosed) _events.add(e);
  }

  Future<void> dispose() async {
    _chat.status.removeListener(_onStatus);
    _feedback.status.removeListener(_onStatus);
    for (final s in _subs) {
      await s.cancel();
    }
    await _chat.dispose();
    await _feedback.dispose();
    await _events.close();
    _live.dispose();
  }
}
