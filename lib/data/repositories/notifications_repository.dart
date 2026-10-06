import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/notification_model.dart';

abstract class NotificationsRepository {
  Future<NotificationsData> getNotifications();
}

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;

  @override
  Future<NotificationsData> getNotifications() async {
    final json = await _dataSource.readJsonObject(
      'assets/json/notifications.json',
    );
    return NotificationsData.fromJson(json);
  }
}
