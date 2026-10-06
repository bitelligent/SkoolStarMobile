part of 'notifications_screen.dart';

class _NState {
  const _NState({this.data});
  final NotificationsData? data;
}

class _NotificationsCubit extends Cubit<_NState> {
  _NotificationsCubit(this._repo) : super(const _NState());

  final NotificationsRepository _repo;

  Future<void> load() async {
    final data = await _repo.getNotifications();
    emit(_NState(data: data));
  }
}
