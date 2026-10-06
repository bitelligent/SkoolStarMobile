import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';

abstract class UserRepository {
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;
  UserModel? _cached;

  @override
  Future<UserModel> getCurrentUser() async {
    if (_cached != null) return _cached!;
    final json = await _dataSource.readJsonObject('assets/json/user.json');
    _cached = UserModel.fromJson(json);
    return _cached!;
  }

  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final current = await getCurrentUser();
    _cached = current.copyWith(firstName: firstName, lastName: lastName);
    return _cached!;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (currentPassword.isEmpty) {
      throw Exception('Current password required');
    }
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters');
    }
  }
}
