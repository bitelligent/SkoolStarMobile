import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/core/utils/palette.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

/// Classes and subjects this teacher is linked to.
class TeacherCatalog {
  const TeacherCatalog({required this.classes, required this.subjects});

  final List<ClassGroup> classes;
  final List<Subject> subjects;
}

/// Builds the teacher's class + subject lists from three endpoints and caches
/// the result (cleared on sign-out):
///  - `Schedules/teacher/{id}` – every class/subject on the teacher's slots
///  - `TeacherModule/my-classes` – classes the teacher is assigned to
///  - `TeacherModule/my-students` – used for per-class student counts
class TeacherCatalogSource extends AuthScopedCache {
  TeacherCatalogSource({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;
  Future<TeacherCatalog>? _cached;

  @override
  void clearCache() => _cached = null;

  /// Concurrent callers share one request; a failed load is not cached.
  Future<TeacherCatalog> load() => _cached ??= _fetch().catchError(
    (Object e, StackTrace st) {
      _cached = null;
      Error.throwWithStackTrace(e, st);
    },
  );

  Future<TeacherCatalog> _fetch() async {
    final staffId = await requireStaffId();
    final results = await Future.wait([
      _api.get(ApiEndpoints.teacherSchedules(staffId)),
      _api.get(ApiEndpoints.myClasses),
      _api.get(ApiEndpoints.myStudents),
    ]);
    return buildCatalog(
      schedules: results[0],
      myClasses: results[1],
      myStudents: results[2],
      staffId: staffId,
    );
  }
}

/// Pure mapping, separated for unit testing.
TeacherCatalog buildCatalog({
  required Object? schedules,
  required Object? myClasses,
  required Object? myStudents,
  required int staffId,
}) {
  final classNames = <int, String>{};
  final subjectNames = <int, String>{};

  for (final slot in asObjects(schedules)) {
    for (final c in slot.objects('classes')) {
      final id = c.intOrNull('id');
      if (id != null) classNames[id] = c.str('name', 'Class $id');
    }
    final subjects = slot
        .objects('teacherSubjects')
        .where((t) => t.intOrNull('teacherId') == staffId);
    for (final t in subjects) {
      final id = t.intOrNull('subjectId');
      if (id != null) subjectNames[id] = t.str('subjectName', 'Subject $id');
    }
  }
  for (final c in asObjects(myClasses)) {
    final id = c.intOrNull('classId');
    if (id != null) classNames.putIfAbsent(id, () => c.str('className'));
  }

  final studentsPerClass = <String, int>{};
  for (final s in asObjects(myStudents)) {
    final name = s.str('className');
    studentsPerClass[name] = (studentsPerClass[name] ?? 0) + 1;
  }

  final classes = [
    for (final e in classNames.entries)
      ClassGroup(
        id: '${e.key}',
        name: e.value,
        studentCount: studentsPerClass[e.value] ?? 0,
        colorHex: colorHexFor(e.key),
      ),
  ]..sort((a, b) => a.name.compareTo(b.name));

  final subjects = [
    for (final e in subjectNames.entries)
      Subject(id: '${e.key}', name: e.value, colorHex: colorHexFor(e.key)),
  ]..sort((a, b) => a.name.compareTo(b.name));

  return TeacherCatalog(classes: classes, subjects: subjects);
}
