import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/parent/guardian_profile.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

abstract interface class GuardianRepository {
  /// The signed-in parent's name and e-mail. [childId] is any linked child
  /// (the name is stored on the child's contact persons).
  Future<GuardianProfile> getProfile({String? childId});
}

class GuardianRepositoryImpl extends AuthScopedCache
    implements GuardianRepository {
  GuardianRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;
  GuardianProfile? _cached;

  @override
  void clearCache() => _cached = null;

  @override
  Future<GuardianProfile> getProfile({String? childId}) async {
    final cached = _cached;
    if (cached != null && cached.name.isNotEmpty) return cached;

    final info = await _api.get(ApiEndpoints.manageInfo);
    final email = info is Json ? info.str('email') : '';

    var profile = GuardianProfile(name: '', email: email);
    if (childId != null) {
      try {
        final people = await _api.get(
          ApiEndpoints.studentContactPersons(childId),
        );
        profile = guardianFromJson(people, email: email);
      } on Object {
        // The name is a nicety: fall back to the e-mail only.
      }
    }
    return _cached = profile;
  }
}
