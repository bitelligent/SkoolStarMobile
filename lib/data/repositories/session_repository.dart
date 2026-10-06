import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';

abstract class SessionRepository {
  Future<List<Session>> getAll();
  Future<Session?> getById(String id);
  Future<Session?> getLive();
  Future<List<Session>> getForDate(DateTime date);
  Future<List<Session>> filter({
    DateTime? date,
    String? classId,
    String? subjectId,
    String? query,
  });
}

class SessionRepositoryImpl implements SessionRepository {
  const SessionRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;

  @override
  Future<List<Session>> getAll() async {
    final list = await _dataSource.readJsonArray('assets/json/sessions.json');
    return list
        .cast<Map<String, dynamic>>()
        .map(Session.fromJson)
        .toList();
  }

  @override
  Future<Session?> getById(String id) async {
    final all = await getAll();
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  @override
  Future<Session?> getLive() async {
    final all = await getAll();
    for (final s in all) {
      if (s.isLive) return s;
    }
    return null;
  }

  @override
  Future<List<Session>> getForDate(DateTime date) async {
    final all = await getAll();
    return all
        .where(
          (s) =>
              s.date.year == date.year &&
              s.date.month == date.month &&
              s.date.day == date.day,
        )
        .toList();
  }

  @override
  Future<List<Session>> filter({
    DateTime? date,
    String? classId,
    String? subjectId,
    String? query,
  }) async {
    var all = await getAll();
    if (date != null) {
      all = all
          .where(
            (s) =>
                s.date.year == date.year &&
                s.date.month == date.month &&
                s.date.day == date.day,
          )
          .toList();
    }
    if (classId != null && classId.isNotEmpty) {
      all = all.where((s) => s.classIds.contains(classId)).toList();
    }
    if (subjectId != null && subjectId.isNotEmpty) {
      all = all.where((s) => s.subjectIds.contains(subjectId)).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      all = all
          .where(
            (s) =>
                s.id.toLowerCase().contains(q) ||
                s.startTime.contains(q) ||
                s.endTime.contains(q),
          )
          .toList();
    }
    all.sort((a, b) {
      final c = a.date.compareTo(b.date);
      if (c != 0) return c;
      return a.startTime.compareTo(b.startTime);
    });
    return all;
  }
}
