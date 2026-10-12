import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/session_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

abstract interface class SessionRepository {
  /// Sessions whose date is within `[from, to]` (inclusive, date-only),
  /// sorted by date then start time. Months already fetched are served from
  /// cache unless [refresh] is true.
  Future<List<Session>> getBetween(
    DateTime from,
    DateTime to, {
    bool refresh = false,
  });

  /// A single session by its public id, or `null` if it does not exist.
  Future<Session?> getById(String id);
}

class SessionRepositoryImpl extends AuthScopedCache
    implements SessionRepository {
  SessionRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;

  /// `yyyy-MM` → in-flight/completed fetch. Storing the future de-duplicates
  /// concurrent requests for the same month.
  final Map<String, Future<List<Session>>> _months = {};
  final Map<String, Session> _byId = {};

  @override
  void clearCache() {
    _months.clear();
    _byId.clear();
  }

  @override
  Future<List<Session>> getBetween(
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async {
    if (refresh) clearCache();
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);

    final fetches = <Future<List<Session>>>[];
    for (
      var m = DateTime(start.year, start.month);
      !m.isAfter(end);
      m = DateTime(m.year, m.month + 1)
    ) {
      fetches.add(_month(m));
    }

    final all = (await Future.wait(fetches)).expand((e) => e);
    return all
        .where((s) => !s.date.isBefore(start) && !s.date.isAfter(end))
        .toList();
  }

  Future<List<Session>> _month(DateTime month) {
    final key = '${month.year}-${month.month}';
    return _months.putIfAbsent(key, () async {
      try {
        final staffId = await requireStaffId();
        final json = await _api.get(
          ApiEndpoints.teacherOccurrences(staffId),
          query: {
            'from': dateOnly(DateTime(month.year, month.month)),
            'to': dateOnly(DateTime(month.year, month.month + 1, 0)),
          },
        );
        final sessions = sessionsFromOccurrences(json, staffId: staffId);
        for (final s in sessions) {
          _byId[s.id] = s;
        }
        return sessions;
      } on Object {
        // Don't cache failures: the next call must retry.
        _months.remove(key);
        rethrow;
      }
    });
  }

  @override
  Future<Session?> getById(String id) async {
    final cached = _byId[id];
    if (cached != null) return cached;
    try {
      final staffId = await requireStaffId();
      final json = await _api.get(ApiEndpoints.occurrenceByPublicId(id));
      if (json is! Json) return null;
      final session = sessionFromOccurrence(json, staffId: staffId);
      if (session != null) _byId[session.id] = session;
      return session;
    } on NotFoundException {
      return null;
    }
  }
}
