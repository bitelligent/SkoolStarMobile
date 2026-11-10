import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/core/utils/palette.dart';
import 'package:skoolstar_teacher_module/data/mappers/session_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_scoped_cache.dart';

/// A child's sessions plus the subject / class names needed to render them.
class ChildSchedule {
  const ChildSchedule({
    required this.sessions,
    required this.subjects,
    required this.classes,
  });

  static const empty = ChildSchedule(sessions: [], subjects: [], classes: []);

  final List<Session> sessions;
  final List<Subject> subjects;
  final List<ClassGroup> classes;

  /// A slot can be shared by several classes ("Class 1, Class 2"), but a
  /// parent only cares about their child's class. Re-labels every session
  /// with [className] (or no class when it is unknown).
  ChildSchedule withClass(String className) {
    const key = 'child-class';
    final label = className.trim();
    return ChildSchedule(
      sessions: [
        for (final s in sessions)
          s.copyWith(classIds: label.isEmpty ? const [] : const [key]),
      ],
      subjects: subjects,
      classes: label.isEmpty ? const [] : [ClassGroup(id: key, name: label)],
    );
  }
}

abstract interface class ChildScheduleRepository {
  /// Sessions of [childId] whose date is within `[from, to]`, sorted by date
  /// then time. Months already fetched are served from cache.
  Future<ChildSchedule> getBetween(
    String childId,
    DateTime from,
    DateTime to, {
    bool refresh = false,
  });

  /// One session of [childId] by its public id, or `null`.
  Future<Session?> getById(String childId, String sessionId);
}

class ChildScheduleRepositoryImpl extends AuthScopedCache
    implements ChildScheduleRepository {
  ChildScheduleRepositoryImpl({
    required ApiClient apiClient,
    required AuthRepository authRepository,
  }) : _api = apiClient,
       super(authRepository);

  final ApiClient _api;

  /// `childId|yyyy-M` → in-flight/completed fetch of that month.
  final Map<String, Future<_Month>> _months = {};

  @override
  void clearCache() => _months.clear();

  @override
  Future<ChildSchedule> getBetween(
    String childId,
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async {
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (refresh) {
      _months.removeWhere((key, _) => key.startsWith('$childId|'));
    }

    final fetches = <Future<_Month>>[];
    for (
      var m = DateTime(start.year, start.month);
      !m.isAfter(end);
      m = DateTime(m.year, m.month + 1)
    ) {
      fetches.add(_month(childId, m));
    }
    final months = await Future.wait(fetches);

    final sessions =
        months
            .expand((m) => m.sessions)
            .where((s) => !s.date.isBefore(start) && !s.date.isAfter(end))
            .toList()
          ..sort((a, b) {
            final c = a.date.compareTo(b.date);
            return c != 0 ? c : a.startTime.compareTo(b.startTime);
          });

    final subjects = <String, String>{};
    final classes = <String, String>{};
    for (final m in months) {
      subjects.addAll(m.subjectNames);
      classes.addAll(m.classNames);
    }
    return ChildSchedule(
      sessions: sessions,
      subjects: [
        for (final e in subjects.entries)
          Subject(
            id: e.key,
            name: e.value,
            colorHex: colorHexFor(int.tryParse(e.key) ?? 0),
          ),
      ]..sort((a, b) => a.name.compareTo(b.name)),
      classes: [
        for (final e in classes.entries)
          ClassGroup(
            id: e.key,
            name: e.value,
            colorHex: colorHexFor(int.tryParse(e.key) ?? 0),
          ),
      ],
    );
  }

  Future<_Month> _month(String childId, DateTime month) {
    final key = '$childId|${month.year}-${month.month}';
    return _months.putIfAbsent(key, () async {
      try {
        final json = await _api.get(
          ApiEndpoints.studentOccurrences(childId),
          query: {
            'from': dateOnly(DateTime(month.year, month.month)),
            'to': dateOnly(DateTime(month.year, month.month + 1, 0)),
          },
        );
        return _Month.from(json);
      } on Object {
        _months.remove(key); // retry next time
        rethrow;
      }
    });
  }

  @override
  Future<Session?> getById(String childId, String sessionId) async {
    for (final entry in _months.entries) {
      if (!entry.key.startsWith('$childId|')) continue;
      final month = await entry.value;
      final hit = month.sessions.where((s) => s.id == sessionId).firstOrNull;
      if (hit != null) return hit;
    }
    try {
      final json = await _api.get(ApiEndpoints.occurrenceByPublicId(sessionId));
      return json is Json ? sessionFromOccurrence(json) : null;
    } on NotFoundException {
      return null;
    }
  }
}

class _Month {
  const _Month(this.sessions, this.subjectNames, this.classNames);

  factory _Month.from(Object? json) {
    final rows = asObjects(json);
    final subjects = <String, String>{};
    final classes = <String, String>{};
    for (final o in rows) {
      for (final t in o.objects('teacherSubjects')) {
        final id = t.strOrNull('subjectId');
        if (id != null) subjects[id] = t.str('subjectName', 'Subject $id');
      }
      final classId = o.strOrNull('classId');
      if (classId != null) {
        classes[classId] = o.str('className', 'Class $classId');
      }
    }
    return _Month(sessionsFromOccurrences(json), subjects, classes);
  }

  final List<Session> sessions;
  final Map<String, String> subjectNames;
  final Map<String, String> classNames;
}
