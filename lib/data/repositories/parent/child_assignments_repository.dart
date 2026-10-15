import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

abstract interface class ChildAssignmentsRepository {
  /// Assignments of one child, latest deadline first.
  Future<List<ChildAssignment>> getForChild(
    String childId, {
    bool refresh = false,
  });
}

class ChildAssignmentsRepositoryImpl extends AuthScopedCache
    implements ChildAssignmentsRepository {
  ChildAssignmentsRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;
  final Map<String, Future<List<ChildAssignment>>> _byChild = {};

  @override
  void clearCache() => _byChild.clear();

  @override
  Future<List<ChildAssignment>> getForChild(
    String childId, {
    bool refresh = false,
  }) {
    if (refresh) _byChild.remove(childId);
    return _byChild[childId] ??= _api
        .get(ApiEndpoints.childAssignments, query: {'studentId': childId})
        .then(
          (json) => assignmentsFromJson(
            json,
          ).where((a) => a.childId == childId).toList(),
        )
        .catchError((Object e, StackTrace st) {
          _byChild.remove(childId);
          Error.throwWithStackTrace(e, st);
        });
  }
}
