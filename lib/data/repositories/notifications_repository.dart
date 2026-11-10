import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';

abstract interface class NotificationsRepository {
  /// Newest first. The API returns at most 200 per request.
  Future<List<AppNotification>> getNotifications({
    bool unreadOnly = false,
    int take = 50,
  });

  Future<int> unreadCount();

  Future<void> markRead(String id);

  /// Marks everything read; returns how many were unread.
  Future<int> markAllRead();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._api);

  final ApiClient _api;

  /// Server cap per request.
  static const maxTake = 200;

  @override
  Future<List<AppNotification>> getNotifications({
    bool unreadOnly = false,
    int take = 50,
  }) async {
    final json = await _api.get(
      ApiEndpoints.notifications,
      query: {
        if (unreadOnly) 'unreadOnly': true,
        'take': take.clamp(1, maxTake),
      },
    );
    return [for (final row in asObjects(json)) ?AppNotification.fromJson(row)];
  }

  @override
  Future<int> unreadCount() async {
    final json = await _api.get(ApiEndpoints.notificationsUnreadCount);
    return json is Json ? json.integer('count') : 0;
  }

  @override
  Future<void> markRead(String id) =>
      _api.post(ApiEndpoints.notificationRead(id));

  @override
  Future<int> markAllRead() async {
    final json = await _api.post(ApiEndpoints.notificationsReadAll);
    return json is Json ? json.integer('count') : 0;
  }
}
