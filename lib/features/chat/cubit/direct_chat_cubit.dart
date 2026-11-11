import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_state.dart';

/// One 1-to-1 conversation.
///
/// * Sending is optimistic: the bubble appears at once as `sending`, becomes
///   `sent` when the server answers, or `failed` with retry / discard.
/// * Live messages arrive over the realtime link; the same message can come
///   both from the send response and the push, so everything is merged by
///   server id.
/// * After a reconnect the latest page is re-fetched so nothing is missed.
class DirectChatCubit extends SafeCubit<DirectChatState> {
  DirectChatCubit({
    required this.threadId,
    required ChatRepository repository,
    this.asParent = false,
    this.maxLength = 1000,
    this.markReadDelay = const Duration(milliseconds: 500),
    this.onSeen,
  }) : _repo = repository,
       super(const DirectChatState.initial());

  final String threadId;
  final ChatRepository _repo;

  /// True in the parent module (messages are sent as the parent).
  final bool asParent;

  /// Server limit per message.
  final int maxLength;
  final Duration markReadDelay;

  /// Called after the thread was marked read (the screen uses it to clear
  /// the matching notifications, which the server leaves unread).
  final VoidCallback? onSeen;

  StreamSubscription<ChatEvent>? _events;
  VoidCallback? _liveListener;
  Timer? _markReadTimer;
  Future<void> _sendQueue = Future.value();
  bool _watching = false;
  int _localSeq = 0;

  /// Highest of my own message ids the peer has read.
  int _peerReadUpTo = 0;

  bool _isMine(DirectMessage m) => m.fromTeacher == !asParent;

  Future<void> load() async {
    emit(const DirectChatState.loading());
    try {
      final thread = await _repo.getThreadById(threadId);
      if (thread == null) {
        emit(const DirectChatState.error('Chat not found'));
        return;
      }
      final messages = await _repo.getDirectMessagesFor(threadId);
      _peerReadUpTo = _readMark(thread, messages, 0);
      emit(
        DirectChatState.loaded(
          thread: thread,
          messages: _withReadFlags(messages),
          hasMore: messages.length >= ChatRepository.pageSize,
          isLive: _repo.isLive.value,
        ),
      );
      await _startRealtime();
      _scheduleMarkRead();
    } on UnauthorizedException {
      rethrow;
    } on Exception catch (e) {
      emit(DirectChatState.error(_describe(e)));
    }
  }

  Future<void> _startRealtime() async {
    if (isClosed) return;
    _events ??= _repo.events.listen(_onEvent);
    if (_liveListener == null) {
      _liveListener = () {
        final s = state;
        if (s is DirectChatLoaded && s.isLive != _repo.isLive.value) {
          emit(s.copyWith(isLive: _repo.isLive.value));
        }
      };
      _repo.isLive.addListener(_liveListener!);
    }
    if (!_watching) {
      _watching = true;
      await _repo.watchDirectThread(threadId);
    }
  }

  // ─── Realtime ───────────────────────────────────────────────────────

  void _onEvent(ChatEvent e) {
    switch (e) {
      case DirectMessageReceived() when e.threadId == threadId:
        _mergeIncoming(e.message);
        if (!_isMine(e.message)) _scheduleMarkRead();
      case DirectThreadChanged() when e.threadId == threadId:
        unawaited(_refreshThread());
      case PeerPresenceChanged():
        final s = state;
        if (s is DirectChatLoaded &&
            s.thread.peerUserId.isNotEmpty &&
            s.thread.peerUserId == e.peerUserId) {
          emit(s.copyWith(thread: s.thread.copyWith(isOnline: e.online)));
        }
      case ChatResync():
        unawaited(_resync());
      default:
        break;
    }
  }

  Future<void> _refreshThread() async {
    try {
      final thread = await _repo.refreshThread(threadId);
      final s = state;
      if (isClosed || thread == null || s is! DirectChatLoaded) return;
      _peerReadUpTo = _readMark(thread, s.messages, _peerReadUpTo);
      emit(
        s.copyWith(
          thread: thread,
          messages: _withReadFlags(s.messages),
        ),
      );
    } on Exception {
      // Cosmetic (ticks / presence); the next event or refresh retries.
    }
  }

  /// After the link came back: fetch what was missed while offline.
  Future<void> _resync() async {
    try {
      await _repo.watchDirectThread(threadId); // idempotent on the server
      final latest = await _repo.getDirectMessagesFor(threadId);
      if (isClosed) return;
      for (final m in latest) {
        _mergeIncoming(m);
      }
      await _refreshThread();
      _scheduleMarkRead();
    } on Exception {
      // Still offline / failing: the next resync tries again.
    }
  }

  // ─── Merging ────────────────────────────────────────────────────────

  void _mergeIncoming(DirectMessage incoming) {
    final s = state;
    if (isClosed || s is! DirectChatLoaded) return;
    final list = [...s.messages];

    final byId = list.indexWhere((m) => m.id == incoming.id);
    if (byId != -1) {
      list[byId] = incoming.copyWith(isRead: list[byId].isRead);
    } else {
      // My own send echoed back by the push before the HTTP response did:
      // adopt it instead of showing the message twice.
      final pending = _isMine(incoming)
          ? list.indexWhere(
              (m) =>
                  m.status == MessageStatus.sending &&
                  m.content.trim() == incoming.content.trim(),
            )
          : -1;
      if (pending != -1) {
        list[pending] = incoming;
      } else {
        list.add(incoming);
      }
    }
    emit(s.copyWith(messages: _withReadFlags(_normalize(list))));
  }

  /// Confirmed messages by time, then my unconfirmed ones in the order the
  /// user wrote them (device clocks can disagree with the server's).
  List<DirectMessage> _normalize(List<DirectMessage> list) {
    final confirmed = [
      for (final m in list)
        if (m.status == MessageStatus.sent) m,
    ]..sort(_byTimeThenId);
    final local = [
      for (final m in list)
        if (m.status != MessageStatus.sent) m,
    ];
    return [...confirmed, ...local];
  }

  static int _byTimeThenId(DirectMessage a, DirectMessage b) {
    final c = a.sentAt.compareTo(b.sentAt);
    if (c != 0) return c;
    return (int.tryParse(a.id) ?? 0).compareTo(int.tryParse(b.id) ?? 0);
  }

  /// Highest message id of mine the peer is known to have read.
  ///
  /// The server only reports `lastOutboundRead` while *my* message is the
  /// last one in the thread, so two more signals are needed: a message from
  /// the peer newer than mine proves they saw mine (they replied).
  int _readMark(ChatThread thread, List<DirectMessage> messages, int current) {
    var mark = current;
    for (final m in messages) {
      final id = int.tryParse(m.id);
      if (id == null || m.status != MessageStatus.sent) continue;
      final mine = _isMine(m);
      if (!mine && id > mark) mark = id;
      if (mine && thread.outgoingLast && id > mark) mark = id;
    }
    return mark;
  }

  List<DirectMessage> _withReadFlags(List<DirectMessage> messages) {
    // Peer messages seen so far imply the peer has read what came before.
    for (final m in messages) {
      final id = int.tryParse(m.id);
      if (id != null &&
          !_isMine(m) &&
          m.status == MessageStatus.sent &&
          id > _peerReadUpTo) {
        _peerReadUpTo = id;
      }
    }
    return [
      for (final m in messages)
        if (_isMine(m) && m.status == MessageStatus.sent)
          m.copyWith(isRead: (int.tryParse(m.id) ?? 0) <= _peerReadUpTo)
        else
          m,
    ];
  }

  // ─── Sending ────────────────────────────────────────────────────────

  /// Queues [content] for sending. Returns `false` only when the text is
  /// rejected locally (empty / too long); delivery failures show up on the
  /// message itself so the user never loses what they typed.
  Future<bool> send(String content) async {
    final s = state;
    if (s is! DirectChatLoaded) return false;
    final text = content.trim();
    if (text.isEmpty || text.length > maxLength) return false;

    final clientId =
        'local_${DateTime.now().microsecondsSinceEpoch}'
        '_${_localSeq++}';
    final pending = DirectMessage(
      id: clientId,
      clientId: clientId,
      threadId: threadId,
      fromTeacher: !asParent,
      content: text,
      sentAt: DateTime.now(),
      isRead: false,
      status: MessageStatus.sending,
    );
    emit(s.copyWith(messages: [...s.messages, pending]));
    _enqueue(() => _deliver(clientId));
    return true;
  }

  /// Sends run strictly one after another so messages keep their order even
  /// on a slow link.
  void _enqueue(Future<void> Function() job) {
    _sendQueue = _sendQueue.then((_) => job()).catchError((Object _) {});
  }

  DirectMessage? _byClientId(String clientId) {
    final s = state;
    if (s is! DirectChatLoaded) return null;
    for (final m in s.messages) {
      if (m.clientId == clientId) return m;
    }
    return null;
  }

  Future<void> _deliver(String clientId) async {
    final pending = _byClientId(clientId);
    if (pending == null || pending.status == MessageStatus.sent) return;
    try {
      final sent = await _repo.sendDirectMessage(
        threadId: threadId,
        content: pending.content,
        fromTeacher: !asParent,
      );
      _confirm(clientId, sent);
    } on Exception {
      _setStatus(clientId, MessageStatus.failed);
    }
  }

  void _confirm(String clientId, DirectMessage sent) {
    final s = state;
    if (isClosed || s is! DirectChatLoaded) return;
    final list = [...s.messages];
    final i = list.indexWhere((m) => m.clientId == clientId);
    final already = list.indexWhere(
      (m) => m.id == sent.id && m.clientId == null,
    );
    if (i == -1) {
      // Already adopted from the push (or discarded): just make sure the
      // server copy is present once.
      if (already == -1) list.add(sent);
    } else if (already != -1) {
      list.removeAt(i); // the push got there first
    } else {
      list[i] = sent;
    }
    emit(s.copyWith(messages: _withReadFlags(_normalize(list))));
  }

  void _setStatus(String clientId, MessageStatus status) {
    final s = state;
    if (isClosed || s is! DirectChatLoaded) return;
    emit(
      s.copyWith(
        messages: [
          for (final m in s.messages)
            if (m.clientId == clientId) m.copyWith(status: status) else m,
        ],
      ),
    );
  }

  /// Re-sends a failed message. A timeout can hide a send that did reach the
  /// server, so look for it first to avoid a duplicate.
  void retry(String clientId) {
    final m = _byClientId(clientId);
    if (m == null || m.status != MessageStatus.failed) return;
    _setStatus(clientId, MessageStatus.sending);
    _enqueue(() async {
      final delivered = await _findDelivered(m);
      if (delivered != null) {
        _confirm(clientId, delivered);
      } else {
        await _deliver(clientId);
      }
    });
  }

  Future<DirectMessage?> _findDelivered(DirectMessage pending) async {
    final s = state;
    if (s is! DirectChatLoaded) return null;
    try {
      final latest = await _repo.getDirectMessagesFor(threadId);
      final known = {for (final m in s.messages) m.id};
      final since = pending.sentAt.subtract(const Duration(minutes: 2));
      for (final m in latest.reversed) {
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

  void discard(String clientId) {
    final s = state;
    if (s is! DirectChatLoaded) return;
    emit(
      s.copyWith(
        messages: [
          for (final m in s.messages)
            if (m.clientId != clientId) m,
        ],
      ),
    );
  }

  // ─── History ────────────────────────────────────────────────────────

  Future<void> loadOlder() async {
    final s = state;
    if (s is! DirectChatLoaded || s.isLoadingOlder || !s.hasMore) return;
    final oldest = s.messages.firstWhere(
      (m) => m.status == MessageStatus.sent,
      orElse: () => s.messages.first,
    );
    if (oldest.status != MessageStatus.sent) return;

    emit(s.copyWith(isLoadingOlder: true));
    try {
      final older = await _repo.getOlderDirectMessages(
        threadId,
        beforeMessageId: oldest.id,
      );
      final cur = state;
      if (isClosed || cur is! DirectChatLoaded) return;
      final known = {for (final m in cur.messages) m.id};
      final fresh = [
        for (final m in older)
          if (!known.contains(m.id)) m,
      ];
      emit(
        cur.copyWith(
          messages: _withReadFlags(_normalize([...fresh, ...cur.messages])),
          hasMore: older.length >= ChatRepository.pageSize,
          isLoadingOlder: false,
        ),
      );
    } on Exception {
      final cur = state;
      if (!isClosed && cur is DirectChatLoaded) {
        emit(cur.copyWith(isLoadingOlder: false));
      }
    }
  }

  // ─── Read receipts ──────────────────────────────────────────────────

  void _scheduleMarkRead() {
    _markReadTimer?.cancel();
    _markReadTimer = Timer(markReadDelay, () {
      if (isClosed) return;
      unawaited(
        _repo
            .markDirectThreadRead(threadId, asParent: asParent)
            .whenComplete(() => onSeen?.call()),
      );
    });
  }

  static String _describe(Object e) =>
      e is ApiException ? e.message : 'Something went wrong. Please retry.';

  @override
  Future<void> close() async {
    _markReadTimer?.cancel();
    await _events?.cancel();
    final listener = _liveListener;
    if (listener != null) _repo.isLive.removeListener(listener);
    if (_watching) unawaited(_repo.unwatchDirectThread(threadId));
    return super.close();
  }
}
