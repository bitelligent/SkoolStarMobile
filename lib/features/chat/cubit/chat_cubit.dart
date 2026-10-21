import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/app_lifecycle.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/chat_state.dart';

/// The inbox: feedback threads and 1-to-1 threads.
///
/// Stays fresh without user action: realtime events trigger a (debounced)
/// quiet refresh, and a timer covers what the backend does not push (new
/// feedback threads).
class ChatCubit extends SafeCubit<ChatState> {
  ChatCubit(
    this._repo, {
    this.pollInterval = const Duration(seconds: 20),
    this.debounce = const Duration(milliseconds: 400),
  }) : super(const ChatState.initial());

  final ChatRepository _repo;
  final Duration pollInterval;
  final Duration debounce;

  StreamSubscription<ChatEvent>? _events;
  VoidCallback? _liveListener;
  Timer? _poll;
  Timer? _debounce;
  bool _refreshing = false;

  Future<void> load() async {
    emit(const ChatState.loading());
    try {
      final threads = await _repo.getThreads();
      emit(ChatState.loaded(threads: threads, isLive: _repo.isLive.value));
      _startLive();
    } on UnauthorizedException {
      rethrow;
    } on Exception catch (e) {
      emit(
        ChatState.error(
          e is ApiException ? e.message : 'Could not load your chats.',
        ),
      );
    }
  }

  void _startLive() {
    if (isClosed) return;
    _events ??= _repo.events.listen(_onEvent);
    if (_liveListener == null) {
      _liveListener = () {
        final s = state;
        if (s is ChatLoaded && s.isLive != _repo.isLive.value) {
          emit(s.copyWith(isLive: _repo.isLive.value));
        }
      };
      _repo.isLive.addListener(_liveListener!);
    }
    _poll ??= Timer.periodic(pollInterval, (_) {
      // No point hitting the server while the app is in the background.
      if (isAppInForeground) unawaited(refresh());
    });
  }

  void _onEvent(ChatEvent e) {
    switch (e) {
      case DirectMessageReceived() ||
          DirectThreadChanged() ||
          FeedbackMessageReceived() ||
          FeedbackListChanged() ||
          ChatResync():
        _debounce?.cancel();
        _debounce = Timer(debounce, () => unawaited(refresh()));
      case PeerPresenceChanged():
        final s = state;
        if (s is! ChatLoaded) return;
        emit(
          s.copyWith(
            threads: [
              for (final t in s.threads)
                if (t.peerUserId.isNotEmpty && t.peerUserId == e.peerUserId)
                  t.copyWith(isOnline: e.online)
                else
                  t,
            ],
          ),
        );
    }
  }

  /// Quiet re-fetch: never replaces the list with a spinner or an error.
  Future<void> refresh() async {
    if (_refreshing || state is! ChatLoaded) return;
    _refreshing = true;
    try {
      final threads = await _repo.getThreads();
      final s = state;
      if (!isClosed && s is ChatLoaded) emit(s.copyWith(threads: threads));
    } on UnauthorizedException {
      rethrow;
    } on Exception {
      // Keep what is on screen.
    } finally {
      _refreshing = false;
    }
  }

  void setActiveTab(ChatCategory tab) {
    final s = state;
    if (s is ChatLoaded) emit(s.copyWith(activeTab: tab));
  }

  void setQuery(String q) {
    final s = state;
    if (s is ChatLoaded) emit(s.copyWith(query: q));
  }

  /// Threads for the active tab, with the current search applied.
  List<ChatThread> visibleThreads() {
    final s = state;
    if (s is! ChatLoaded) return const [];
    final q = s.query.trim().toLowerCase();
    return s.threads.where((t) {
      if (t.category != s.activeTab) return false;
      if (q.isEmpty) return true;
      return t.name.toLowerCase().contains(q) ||
          t.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  /// Total unread count per category — used to decorate the pill tabs.
  int unreadCountFor(ChatCategory cat) {
    final s = state;
    if (s is! ChatLoaded) return 0;
    return s.threads
        .where((t) => t.category == cat)
        .fold<int>(0, (sum, t) => sum + t.unreadCount);
  }

  @override
  Future<void> close() async {
    _poll?.cancel();
    _debounce?.cancel();
    await _events?.cancel();
    final listener = _liveListener;
    if (listener != null) _repo.isLive.removeListener(listener);
    return super.close();
  }
}
