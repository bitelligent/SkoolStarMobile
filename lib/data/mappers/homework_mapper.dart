import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';

/// Tolerant mapping for `TeacherModule/homework/class/{id}` rows. The live
/// server returned no rows when this was written, so every field except an
/// id and title is optional.
Homework? homeworkFromJson(
  Json j, {
  required String sessionId,
  required String classId,
  required DateTime fallbackDeadline,
}) {
  final id = j.strOrNull('taskId') ?? j.strOrNull('id');
  final title = j.strOrNull('title');
  if (id == null || title == null) return null;

  final studentIds = <String>[
    for (final s in (j['studentIds'] as List? ?? const [])) s.toString(),
    for (final s in j.objects('students'))
      if (s.intOrNull('studentId') != null) s.str('studentId'),
  ];

  return Homework(
    id: id,
    sessionId: sessionId,
    classId: j.strOrNull('classId') ?? classId,
    subjectId: j.str('subjectId'),
    title: title,
    description: j.str('description'),
    deadline: j.dateOrNull('deadline') ?? fallbackDeadline,
    maxMarks: j.integer('maxMarks', 100),
    assignedStudentIds: studentIds.toSet().toList(),
    assignedCount: j.integer('totalAssigned', j.integer('assignedCount')),
    attachments: [
      for (final a in (j['attachments'] as List? ?? const []))
        attachmentFromJson(a),
    ],
  );
}

/// The server prefixes stored files with `yyyyMMddHHmmssfff-<guid>-`; hide it
/// so users see the name they uploaded.
final _storedNamePrefix = RegExp(r'^\d{14,17}-[0-9a-fA-F]{32}-');

String displayFileName(String name) {
  final clean = name.replaceFirst(_storedNamePrefix, '');
  return clean.isEmpty ? name : clean;
}

HomeworkAttachment attachmentFromJson(Object? a) {
  if (a is Json) {
    final name = displayFileName(
      a.str('fileName', a.str('name', 'attachment')),
    );
    return HomeworkAttachment(
      fileName: name,
      sizeKb: a.integer('sizeKb'),
      type: _extension(name),
      reference: a.str('url', a.str('path', a.str('id'))),
    );
  }
  final ref = '$a';
  return HomeworkAttachment(
    fileName: displayFileName(ref.split('/').last),
    sizeKb: 0,
    type: _extension(ref),
    reference: ref,
  );
}

String _extension(String name) {
  final i = name.lastIndexOf('.');
  return i < 0 ? '' : name.substring(i + 1).toLowerCase();
}
