import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/attendance_entry.dart';

abstract class AttendanceRepository {
  Future<Map<String, String>> getForSession(String sessionId);
  Future<void> submit({
    required String sessionId,
    required Map<String, String> studentIdToStatus,
  });
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;
  final Map<String, Map<String, String>> _memoryStore = {};

  @override
  Future<Map<String, String>> getForSession(String sessionId) async {
    if (_memoryStore.containsKey(sessionId)) {
      return Map<String, String>.from(_memoryStore[sessionId]!);
    }
    final data = await _dataSource.readJsonObject(
      'assets/json/attendance.json',
    );
    final entries = (data['entries'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(AttendanceEntry.fromJson)
        .where((e) => e.sessionId == sessionId)
        .toList();
    final map = <String, String>{};
    for (final e in entries) {
      map[e.studentId] = e.status;
    }
    _memoryStore[sessionId] = Map<String, String>.from(map);
    return map;
  }

  @override
  Future<void> submit({
    required String sessionId,
    required Map<String, String> studentIdToStatus,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _memoryStore[sessionId] = Map<String, String>.from(studentIdToStatus);
  }
}
