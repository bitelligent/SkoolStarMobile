import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

abstract interface class ChildAttendanceRepository {
  /// Attendance of one child, newest first.
  Future<List<ChildAttendanceRecord>> getForChild(
    String childId, {
    bool refresh = false,
  });
}

class ChildAttendanceRepositoryImpl extends AuthScopedCache
    implements ChildAttendanceRepository {
  ChildAttendanceRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;
  final Map<String, Future<List<ChildAttendanceRecord>>> _byChild = {};

  @override
  void clearCache() => _byChild.clear();

  @override
  Future<List<ChildAttendanceRecord>> getForChild(
    String childId, {
    bool refresh = false,
  }) {
    if (refresh) _byChild.remove(childId);
    return _byChild[childId] ??= _api
        .get(ApiEndpoints.childAttendance, query: {'studentId': childId})
        .then((json) {
          // Keep only this child's rows even if the server returns more.
          return attendanceFromJson(
            json,
          ).where((r) => r.childId == childId).toList();
        })
        .catchError((Object e, StackTrace st) {
          _byChild.remove(childId);
          Error.throwWithStackTrace(e, st);
        });
  }
}
