import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_progress.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

abstract interface class ChildProgressRepository {
  /// The school's all-time totals for [childId], or `null` when it has none.
  Future<ChildProgress?> getSummary(String childId, {bool refresh = false});

  /// Exam results of [childId], newest first.
  Future<List<ExamResult>> getResults(String childId, {bool refresh = false});
}

class ChildProgressRepositoryImpl extends AuthScopedCache
    implements ChildProgressRepository {
  ChildProgressRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;
  final Map<String, Future<ChildProgress?>> _summaries = {};
  final Map<String, Future<List<ExamResult>>> _results = {};

  @override
  void clearCache() {
    _summaries.clear();
    _results.clear();
  }

  @override
  Future<ChildProgress?> getSummary(String childId, {bool refresh = false}) {
    if (refresh) _summaries.remove(childId);
    return _summaries[childId] ??= _api
        .get(ApiEndpoints.childProgress, query: {'studentId': childId})
        .then((json) => progressFromJson(json, childId: childId))
        .catchError((Object e, StackTrace st) {
          _summaries.remove(childId);
          Error.throwWithStackTrace(e, st);
        });
  }

  @override
  Future<List<ExamResult>> getResults(String childId, {bool refresh = false}) {
    if (refresh) _results.remove(childId);
    return _results[childId] ??= _api
        .get(ApiEndpoints.childResults, query: {'studentId': childId})
        .then((json) => resultsFromJson(json, childId: childId))
        .catchError((Object e, StackTrace st) {
          _results.remove(childId);
          Error.throwWithStackTrace(e, st);
        });
  }
}
