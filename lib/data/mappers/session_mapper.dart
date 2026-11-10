import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';

/// Backend `ScheduleOccurrence` status for a normal, open session.
const _scheduledStatus = 0;

/// Maps an occurrence from `Schedules/occurrences/*` to a [Session].
///
/// With [staffId] (teacher module) only that teacher's subjects are kept.
/// Without it (parent module) every subject and teacher of the slot is kept
/// and the session is attached to the single class the pupil is in.
///
/// Returns `null` for breaks and rows without a usable date, so a bad row
/// never breaks the whole list.
Session? sessionFromOccurrence(Json o, {int? staffId}) {
  if (o.boolean('isBreak')) return null;

  final date = DateTime.tryParse(o.str('sessionDate'));
  if (date == null) return null;

  final occurrenceId = o.integer('id');
  final id =
      o.strOrNull('publicId') ?? (occurrenceId == 0 ? null : '$occurrenceId');
  if (id == null) return null;

  final forStudent = staffId == null;
  final classes = o.objects('classes');
  final classIds = forStudent && o.intOrNull('classId') != null
      ? [o.str('classId')]
      : classes.isNotEmpty
      ? classes.map((c) => c.str('id')).where((e) => e.isNotEmpty).toList()
      : [if (o.intOrNull('classId') != null) o.str('classId')];

  // The slot lists every teacher's subjects; only ours belong on this app.
  final subjectIds = o
      .objects('teacherSubjects')
      .where((t) => forStudent || t.intOrNull('teacherId') == staffId)
      .map((t) => t.str('subjectId'))
      .where((e) => e.isNotEmpty)
      .toSet()
      .toList();
  if (subjectIds.isEmpty && o.intOrNull('subjectId') != null) {
    subjectIds.add(o.str('subjectId'));
  }

  return Session(
    id: id,
    date: DateTime(date.year, date.month, date.day),
    startTime: hhmm(o.strOrNull('startTime')),
    endTime: hhmm(o.strOrNull('endTime')),
    classIds: classIds,
    subjectIds: subjectIds,
    teacherId: staffId == null ? '' : '$staffId',
    isLocked: o.integer('status', _scheduledStatus) != _scheduledStatus,
    occurrenceId: occurrenceId,
    scheduleId: o.integer('classScheduleId'),
    sectionId: o.intOrNull('sectionId'),
    teachers: forStudent ? _teachersOf(o) : const [],
  );
}

/// Groups `teacherSubjects` rows by teacher: one entry per teacher with the
/// ids of the subjects they teach in this slot.
List<SessionTeacher> _teachersOf(Json o) {
  final byId = <String, ({String name, List<String> subjects})>{};
  for (final t in o.objects('teacherSubjects')) {
    final id = t.strOrNull('teacherId');
    if (id == null) continue;
    final entry = byId.putIfAbsent(
      id,
      () => (name: t.str('teacherName', 'Teacher'), subjects: <String>[]),
    );
    final subject = t.strOrNull('subjectId');
    if (subject != null && !entry.subjects.contains(subject)) {
      entry.subjects.add(subject);
    }
  }
  return [
    for (final e in byId.entries)
      SessionTeacher(
        id: e.key,
        name: e.value.name,
        subjectIds: e.value.subjects,
      ),
  ];
}

List<Session> sessionsFromOccurrences(Object? json, {int? staffId}) {
  final sessions =
      asObjects(json)
          .map((o) => sessionFromOccurrence(o, staffId: staffId))
          .whereType<Session>()
          .toList()
        ..sort((a, b) {
          final c = a.date.compareTo(b.date);
          return c != 0 ? c : a.startTime.compareTo(b.startTime);
        });
  return sessions;
}
