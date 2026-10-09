import 'package:skoolstar_teacher_module/core/config/attendance_status_config.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/mappers/people_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';

/// Roster of a session with the attendance already recorded for it.
class AttendanceSheet {
  const AttendanceSheet({required this.students, required this.statuses});

  final List<Student> students;

  /// studentId → `present` | `absent` | `late` | `unmarked`.
  final Map<String, String> statuses;
}

abstract interface class AttendanceRepository {
  Future<AttendanceSheet> getSheet(Session session, List<ClassGroup> classes);

  /// Saves the marked students (unmarked ones are not sent).
  Future<void> submit(Session session, Map<String, String> statuses);
}

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<AttendanceSheet> getSheet(
    Session session,
    List<ClassGroup> classes,
  ) async {
    final classIdByName = {for (final c in classes) c.name: c.id};
    final classIds = session.classIds.map(int.tryParse).whereType<int>();

    // A slot can span several classes; the endpoint is per class.
    final responses = await Future.wait([
      for (final classId in classIds)
        _api
            .get(
              ApiEndpoints.attendanceForClass(classId),
              query: {
                'date': dateOnly(session.date),
                'scheduleId': session.scheduleId,
                'scheduleOccurrenceId': session.occurrenceId,
                'scheduleOccurrencePublicId': session.id,
              },
            )
            .then((json) => (classId, json)),
    ]);

    final students = <String, Student>{};
    final statuses = <String, String>{};
    for (final (classId, json) in responses) {
      final rows = json is Json ? json.objects('students') : <Json>[];
      for (final row in rows) {
        final student = studentFromAttendanceRow(
          row,
          fallbackClassId: '$classId',
          classIdByName: classIdByName,
        );
        if (student == null) continue;
        // Classes of one slot can return the same pupils; keep the first.
        students.putIfAbsent(student.id, () => student);
        statuses.putIfAbsent(
          student.id,
          () => AttendanceStatusConfig.fromId(row.intOrNull('statusId')),
        );
      }
    }

    final list = students.values.toList()
      ..sort(
        (a, b) => '${a.firstName} ${a.lastName}'.compareTo(
          '${b.firstName} ${b.lastName}',
        ),
      );
    return AttendanceSheet(students: list, statuses: statuses);
  }

  @override
  Future<void> submit(Session session, Map<String, String> statuses) async {
    final items = [
      for (final e in statuses.entries)
        if (AttendanceStatusConfig.toId(e.value) != null &&
            int.tryParse(e.key) != null)
          {
            'studentId': int.parse(e.key),
            'statusId': AttendanceStatusConfig.toId(e.value),
          },
    ];
    if (items.isEmpty) return;

    await _api.post(
      ApiEndpoints.markAttendance,
      body: {
        'date': dateOnly(session.date),
        'scheduleId': session.scheduleId,
        'scheduleOccurrenceId': session.occurrenceId,
        'scheduleOccurrencePublicId': session.id,
        'items': items,
      },
    );
  }
}
