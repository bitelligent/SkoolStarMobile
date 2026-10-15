import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

abstract interface class ChildrenRepository {
  /// Pupils linked to the signed-in parent. Cached until [refresh] or sign-out
  /// / role change.
  Future<List<Child>> getChildren({bool refresh = false});
}

class ChildrenRepositoryImpl extends AuthScopedCache
    implements ChildrenRepository {
  ChildrenRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;
  Future<List<Child>>? _cached;

  @override
  void clearCache() => _cached = null;

  @override
  Future<List<Child>> getChildren({bool refresh = false}) {
    if (refresh) _cached = null;
    return _cached ??= _api
        .get(ApiEndpoints.myChildren)
        .then(childrenFromJson)
        .catchError((Object e, StackTrace st) {
          _cached = null; // never cache a failure
          Error.throwWithStackTrace(e, st);
        });
  }
}
