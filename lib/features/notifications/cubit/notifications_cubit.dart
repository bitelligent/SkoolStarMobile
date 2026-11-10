import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/core/utils/app_lifecycle.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';

enum NotificationsStatus { idle, loading, loaded, error }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.unreadCount = 0,
    this.items = const [],
    this.status = NotificationsStatus.idle,
    this.error,
    this.take = NotificationsCubit.pageSize,
  });

  /// Server-side unread total (the bell badge), independent of how many rows
  /// are loaded.
  final int unreadCount;
  final List<AppNotification> items;
  final NotificationsStatus status;
  final String? error;

  /// How many rows were requested for [items].
  final int take;

  /// The server may have more than [items] (only `take` newest are fetched).
  bool get hasMore => items.length >= take && take < NotificationsCubit.maxTake;

  NotificationsState copyWith({
    int? unreadCount,
    List<AppNotification>? items,
    NotificationsStatus? status,
    String? Function()? error,
    int? take,
  }) => NotificationsState(
    unreadCount: unreadCount ?? this.unreadCount,
    items: items ?? this.items,
    status: status ?? this.status,
    error: error != null ? error() : this.error,
    take: take ?? this.take,
  );

  @override
  List<Object?> get props => [unreadCount, items, status, error, take];
}

/// App-wide notification state: the bell badge and the list.
///
/// The backend has no push channel for these, so the badge stays fresh by
/// polling the (cheap) unread-count endpoint while the app is in the
/// foreground, on resume, and whenever a chat event shows something new
/// arrived. It is cleared and reloaded when the signed-in role changes.
class NotificationsCubit extends SafeCubit<NotificationsState> {
  NotificationsCubit({
    required NotificationsRepository repository,
    required AuthRepository auth,
    Stream<ChatEvent>? events,
    this.pollInterval = const Duration(seconds: 45),
    this.debounce = const Duration(seconds: 1),
  }) : _repo = repository,
       _auth = auth,
       super(const NotificationsState()) {
    _key = _activeKey;
    _auth.session.addListener(_onSession);
    _events = events?.listen(_onChatEvent);
    if (pollInterval > Duration.zero) {
      _poll = Timer.periodic(pollInterval, (_) {
        if (_active && isAppInForeground) unawaited(refreshCount());
      });
    }
    if (_active) unawaited(refreshCount());
  }

  static const pageSize = 50;
  static const maxTake = NotificationsRepositoryImpl.maxTake;

  final NotificationsRepository _repo;
  final AuthRepository _auth;

  /// How often the badge is re-checked while the app is in the foreground;
  /// [Duration.zero] turns polling off.
  final Duration pollInterval;
  final Duration debounce;

  StreamSubscription<ChatEvent>? _events;
  Timer? _poll;
  Timer? _debounce;
  String? _key;

  /// Bumped when the signed-in role changes so late answers are dropped.
  int _generation = 0;

  /// Ids with a mark-read request in flight (no double counting).
  final Set<String> _pendingRead = {};

  DateTime? _unreadFetchedAt;
  List<AppNotification>? _unreadCache;

  bool get _active => _activeKey != null;

  String? get _activeKey {
    final s = _auth.session.value;
    return s.signedIn && s.role != null ? s.contextKey : null;
  }

  void _onSession() {
    final key = _activeKey;
    if (key == _key) return;
    _key = key;
    _generation++;
    _unreadCache = null;
    _pendingRead.clear();
    emit(const NotificationsState());
    if (key != null) unawaited(refreshCount());
  }

  void _onChatEvent(ChatEvent e) {
    if (!_active) return;
    switch (e) {
      case DirectMessageReceived() ||
          FeedbackMessageReceived() ||
          FeedbackListChanged() ||
          ChatResync():
        _debounce?.cancel();
        _debounce = Timer(debounce, () => unawaited(refreshCount()));
      default:
        break;
    }
  }

  /// Call when the app returns to the foreground.
  void onResumed() {
    if (_active) unawaited(refreshCount());
  }

  // ─── Badge ──────────────────────────────────────────────────────────

  /// Quietly updates the badge. When it changed and the list is open, the
  /// list is refreshed too so it never contradicts the badge.
  Future<void> refreshCount() async {
    if (!_active) return;
    final generation = _generation;
    try {
      final count = await _repo.unreadCount();
      if (generation != _generation) return;
      final changed = count != state.unreadCount;
      emit(state.copyWith(unreadCount: count));
      if (changed && state.status == NotificationsStatus.loaded) {
        unawaited(load(quiet: true));
      }
    } on UnauthorizedException {
      // The API client signs the user out; nothing to show.
    } on Object {
      // Keep the last known badge.
    }
  }

  // ─── List ───────────────────────────────────────────────────────────

  /// Loads the newest [NotificationsState.take] notifications. With [quiet]
  /// the screen keeps what it shows (no spinner, errors ignored).
  Future<String?> load({bool quiet = false}) async {
    if (!_active) return null;
    final generation = _generation;
    final hadItems = state.items.isNotEmpty;
    if (!quiet && !hadItems) {
      emit(
        state.copyWith(status: NotificationsStatus.loading, error: () => null),
      );
    }
    try {
      final results = await Future.wait<Object>([
        _repo.getNotifications(take: state.take),
        _repo.unreadCount(),
      ]);
      if (generation != _generation) return null;
      emit(
        state.copyWith(
          items: results[0] as List<AppNotification>,
          unreadCount: results[1] as int,
          status: NotificationsStatus.loaded,
          error: () => null,
        ),
      );
      return null;
    } on UnauthorizedException {
      return null;
    } on Object catch (e, st) {
      final message = errorMessage(e, st);
      if (generation != _generation) return null;
      if (!hadItems && !quiet) {
        emit(
          state.copyWith(
            status: NotificationsStatus.error,
            error: () => message,
          ),
        );
      }
      return quiet ? null : message;
    }
  }

  /// Pull-to-refresh: returns an error message or `null`.
  Future<String?> refresh() => load();

  /// Fetches the next, larger window (the API has no offset).
  Future<void> loadMore() async {
    if (!state.hasMore) return;
    emit(
      state.copyWith(
        take: (state.take + pageSize).clamp(pageSize, maxTake),
      ),
    );
    await load(quiet: true);
  }

  // ─── Marking read ───────────────────────────────────────────────────

  /// Marks one notification read. Optimistic; undone if the server refuses.
  Future<bool> markRead(String id) async {
    if (!_pendingRead.add(id)) return true;
    final index = state.items.indexWhere((n) => n.id == id);
    if (index != -1 && state.items[index].isRead) {
      _pendingRead.remove(id);
      return true;
    }
    final generation = _generation;
    _apply(id, read: true);
    try {
      await _repo.markRead(id);
      return true;
    } on Object {
      if (generation == _generation) _apply(id, read: false);
      return false;
    } finally {
      _pendingRead.remove(id);
    }
  }

  void _apply(String id, {required bool read}) {
    final items = [
      for (final n in state.items)
        if (n.id == id) n.copyWith(isRead: read) else n,
    ];
    final next = (state.unreadCount + (read ? -1 : 1)).clamp(0, 1 << 30);
    emit(state.copyWith(items: items, unreadCount: next));
  }

  /// Marks every notification read. Returns an error message, or `null`.
  Future<String?> markAllRead() async {
    if (state.unreadCount == 0 && !state.items.any((n) => !n.isRead)) {
      return null;
    }
    final before = state;
    final generation = _generation;
    emit(
      state.copyWith(
        items: [for (final n in state.items) n.copyWith(isRead: true)],
        unreadCount: 0,
      ),
    );
    try {
      await _repo.markAllRead();
      _unreadCache = null;
      return null;
    } on Object catch (e, st) {
      if (generation == _generation) emit(before);
      return errorMessage(e, st);
    }
  }

  /// Marks the unread notifications about one conversation as read.
  ///
  /// The server does not do this when a chat is opened, so a screen showing a
  /// thread calls it (also when new messages arrive while it is open),
  /// otherwise the badge would keep counting messages the user is reading.
  Future<void> markRelatedRead({
    required NotificationType type,
    required Set<String> referenceIds,
  }) async {
    if (referenceIds.isEmpty || !_active) return;
    if (state.unreadCount == 0 && state.status == NotificationsStatus.loaded) {
      return;
    }
    final generation = _generation;
    try {
      final unread = await _unreadNotifications();
      if (generation != _generation) return;
      final matches = [
        for (final n in unread)
          if (!n.isRead &&
              n.type == type &&
              n.referenceId != null &&
              referenceIds.contains(n.referenceId))
            n,
      ];
      // A few at a time: a long backlog must not flood the server.
      for (var i = 0; i < matches.length; i += 4) {
        await Future.wait([
          for (final n in matches.skip(i).take(4)) markRead(n.id),
        ]);
      }
    } on Object {
      // Cosmetic; the next badge refresh reconciles.
    }
  }

  /// Unread rows, from the loaded list when it covers them all, else fetched
  /// (cached briefly so a burst of events costs one request).
  Future<List<AppNotification>> _unreadNotifications() async {
    final loadedUnread = state.items.where((n) => !n.isRead).length;
    if (state.status == NotificationsStatus.loaded &&
        loadedUnread >= state.unreadCount) {
      return state.items;
    }
    final fetchedAt = _unreadFetchedAt;
    final cache = _unreadCache;
    if (cache != null &&
        fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < const Duration(seconds: 5)) {
      return cache;
    }
    final fresh = await _repo.getNotifications(
      unreadOnly: true,
      take: maxTake,
    );
    _unreadCache = fresh;
    _unreadFetchedAt = DateTime.now();
    return fresh;
  }

  @override
  Future<void> close() async {
    _auth.session.removeListener(_onSession);
    _poll?.cancel();
    _debounce?.cancel();
    await _events?.cancel();
    return super.close();
  }
}
