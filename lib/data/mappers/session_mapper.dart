import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';

/// Backend `ScheduleOccurrence` status for a normal, open session.
const _scheduledStatus = 0;

/// Maps an occurrence from `Schedules/occurrences/*` to a [Session].
///
/// Returns `null` for breaks and rows without a usable date, so a bad row
/// never breaks the whole list.
Session? sessionFromOccurrence(Json o, {required int staffId}) {
  if (o.boolean('isBreak')) return null;

  final date = DateTime.tryParse(o.str('sessionDate'));
  if (date == null) return null;

  final occurrenceId = o.integer('id');
  final id =
      o.strOrNull('publicId') ?? (occurrenceId == 0 ? null : '$occurrenceId');
  if (id == null) return null;

  final classes = o.objects('classes');
  final classIds = classes.isNotEmpty
      ? classes.map((c) => c.str('id')).where((e) => e.isNotEmpty).toList()
      : [if (o.intOrNull('classId') != null) o.str('classId')];

  // The slot lists every teacher's subjects; only ours belong on this app.
  final subjectIds = o
      .objects('teacherSubjects')
      .where((t) => t.intOrNull('teacherId') == staffId)
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
    teacherId: '$staffId',
    isLocked: o.integer('status', _scheduledStatus) != _scheduledStatus,
    occurrenceId: occurrenceId,
    scheduleId: o.integer('classScheduleId'),
    sectionId: o.intOrNull('sectionId'),
  );
}

List<Session> sessionsFromOccurrences(Object? json, {required int staffId}) {
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
