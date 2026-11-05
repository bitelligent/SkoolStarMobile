import 'package:skoolstar_teacher_module/core/config/attendance_status_config.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_progress.dart';
import 'package:skoolstar_teacher_module/data/models/parent/guardian_profile.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';

/// `GET Users/my-children` rows. Rows without a student id are skipped.
List<Child> childrenFromJson(Object? json) => [
  for (final row in asObjects(json))
    if (row.intOrNull('studentId') != null)
      Child(
        id: row.str('studentId'),
        name: row.str('studentName', 'Student'),
        className: row.str('className'),
        sectionName: row.str('sectionName'),
        isPrimaryGuardian: row.boolean('isPrimaryGuardian'),
      ),
];

DateTime? _dateOnly(Json j, List<String> keys) {
  for (final k in keys) {
    final d = j.dateOrNull(k);
    if (d != null) return DateTime(d.year, d.month, d.day);
  }
  return null;
}

/// `GET TeacherModule/children/attendance` rows, newest first.
List<ChildAttendanceRecord> attendanceFromJson(Object? json) {
  final records = <ChildAttendanceRecord>[];
  for (final row in asObjects(json)) {
    final date = _dateOnly(row, ['sessionDate', 'date']);
    final childId = row.strOrNull('studentId');
    if (date == null || childId == null) continue;
    records.add(
      ChildAttendanceRecord(
        childId: childId,
        date: date,
        status: AttendanceStatusConfig.fromId(
          row.intOrNull('statusId'),
          withExcused: true,
        ),
        className: row.str('className'),
        subjectName: row.str('subjectName'),
        startTime: hhmm(row.strOrNull('startTime')),
        endTime: hhmm(row.strOrNull('endTime')),
        remarks: row.strOrNull('remarks'),
        occurrenceId: row.strOrNull('scheduleOccurrencePublicId'),
      ),
    );
  }
  records.sort((a, b) {
    final c = b.date.compareTo(a.date);
    return c != 0 ? c : b.startTime.compareTo(a.startTime);
  });
  return records;
}

/// `GET TeacherModule/children/assignments` rows, latest deadline first.
List<ChildAssignment> assignmentsFromJson(Object? json) {
  final items = <ChildAssignment>[];
  for (final row in asObjects(json)) {
    final id = row.strOrNull('taskId');
    final title = row.strOrNull('title');
    final childId = row.strOrNull('studentId');
    final deadline = row.dateOrNull('deadline');
    if (id == null || title == null || childId == null || deadline == null) {
      continue;
    }
    items.add(
      ChildAssignment(
        id: id,
        childId: childId,
        title: title,
        deadline: deadline,
        description: row.str('description'),
        maxMarks: row.integer('maxMarks', 100),
        isCompleted: row.boolean('isCompleted'),
        completedAt: row.dateOrNull('completedAt'),
        feedback: row.strOrNull('feedback'),
        marks: row.intOrNull('marks'),
        sessionDate: _dateOnly(row, ['sessionDate']),
        className: row.str('className'),
        subjectName: row.str('subjectName'),
        occurrenceId: row.strOrNull('scheduleOccurrencePublicId'),
      ),
    );
  }
  items.sort((a, b) => b.deadline.compareTo(a.deadline));
  return items;
}

/// Picks the signed-in parent from `StudentContactPersons/by-student/{id}`:
/// the person whose e-mail matches the login, else the primary guardian,
/// else just the e-mail.
GuardianProfile guardianFromJson(Object? json, {required String email}) {
  final people = asObjects(json);
  Json? match;
  for (final p in people) {
    if (p.str('email').toLowerCase() == email.toLowerCase()) {
      match = p;
      break;
    }
  }
  match ??= people.where((p) => p.boolean('isPrimaryGuardian')).firstOrNull;
  if (match == null) return GuardianProfile(name: '', email: email);
  return GuardianProfile(
    name: match.str('fullName'),
    email: match.str('email', email),
    relationship: match.str('relationship'),
    phone: match.str('phoneNumber'),
  );
}

/// One leave object (create / list item / cancel). `null` when it lacks the
/// fields needed to show it.
LeaveRequest? leaveFromJson(Object? json) {
  if (json is! Json) return null;
  final id = json.strOrNull('id');
  final start = _dateOnly(json, ['startDate']);
  final end = _dateOnly(json, ['endDate']);
  if (id == null || start == null || end == null) return null;
  return LeaveRequest(
    id: id,
    childId: json.str('studentId'),
    childName: json.str('studentName'),
    className: json.str('className'),
    startDate: start,
    endDate: end,
    durationDays: json.integer(
      'durationDays',
      LeaveRules.daysBetween(start, end),
    ),
    reason: json.str('reason'),
    status: LeaveStatus.fromId(json.intOrNull('statusId')),
    decisionReason: json.strOrNull('decisionReason'),
    submittedAt: json.dateOrNull('submittedAt')?.toLocal(),
    decidedAt: json.dateOrNull('decidedAt')?.toLocal(),
  );
}

/// `GET LeaveApplications/mine`: a paged envelope.
LeavePage leavePageFromJson(Object? json) {
  final map = json is Json ? json : const <String, dynamic>{};
  final items = [
    for (final row in asObjects(map['items'])) ?leaveFromJson(row),
  ];
  return LeavePage(
    items: items,
    pageNumber: map.integer('pageNumber', 1),
    totalCount: map.integer('totalCount', items.length),
    hasNextPage: map.boolean('hasNextPage'),
  );
}

/// `GET TeacherModule/children/progress`: one row per child; the row for
/// [childId] or `null`.
ChildProgress? progressFromJson(Object? json, {required String childId}) {
  for (final row in asObjects(json)) {
    if (row.strOrNull('studentId') != childId) continue;
    return ChildProgress(
      childId: childId,
      completedAssignments: row.integer('completedAssignments'),
      totalAssignments: row.integer('totalAssignments'),
      totalResults: row.integer('totalResults'),
      averageScore: (row['averageScore'] as num?)?.toDouble() ?? 0,
    );
  }
  return null;
}

/// `GET TeacherModule/children/results` rows of [childId], newest first.
List<ExamResult> resultsFromJson(Object? json, {required String childId}) {
  final results = [
    for (final row in asObjects(json))
      if (row.strOrNull('studentId') == childId &&
          row.strOrNull('examName') != null &&
          row['score'] is num)
        ExamResult(
          examId: row.str('examId', row.str('examName')),
          examName: row.str('examName'),
          score: (row['score'] as num).toDouble(),
          remarks: row.strOrNull('remarks'),
          createdAt: row.dateOrNull('createdAt'),
        ),
  ];
  results.sort(
    (a, b) =>
        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
  );
  return results;
}
