import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

abstract interface class UserRepository {
  Future<UserModel> getCurrentUser();

  /// Updates the display name and, when [newPassword] is given, the password
  /// (which requires [currentPassword]).
  ///
  /// Throws [ValidationException] with field errors on rejected input.
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    String? currentPassword,
    String? newPassword,
  });
}

class UserRepositoryImpl extends AuthScopedCache implements UserRepository {
  UserRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;
  UserModel? _cached;

  @override
  void clearCache() => _cached = null;

  @override
  Future<UserModel> getCurrentUser() async {
    final cached = _cached;
    if (cached != null) return cached;

    final staffId = await requireStaffId();
    final json = await _api.get(ApiEndpoints.staff(staffId));
    if (json is! Json) throw const ParseException();

    return _cached = UserModel(
      id: '$staffId',
      firstName: json.str('firstName'),
      lastName: json.str('lastName'),
      email: json.str('email'),
      avatarUrl: json.str('photoUrl'),
    );
  }

  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    String? currentPassword,
    String? newPassword,
  }) async {
    final current = await getCurrentUser();
    final changingPassword = newPassword != null && newPassword.isNotEmpty;

    await _api.put(
      ApiEndpoints.myProfile,
      body: {
        'firstName': firstName,
        'lastName': lastName,
        if (changingPassword) ...{
          'currentPassword': currentPassword ?? '',
          'newPassword': newPassword,
          'confirmNewPassword': newPassword,
        },
      },
    );

    return _cached = current.copyWith(
      firstName: firstName,
      lastName: lastName,
    );
  }
}
