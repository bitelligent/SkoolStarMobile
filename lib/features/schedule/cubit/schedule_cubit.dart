import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/features/schedule/cubit/schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({
    required SessionRepository sessionRepository,
    required ClassRepository classRepository,
    required SubjectRepository subjectRepository,
  }) : _sessionRepository = sessionRepository,
       _classRepository = classRepository,
       _subjectRepository = subjectRepository,
       super(const ScheduleState.initial());

  final SessionRepository _sessionRepository;
  final ClassRepository _classRepository;
  final SubjectRepository _subjectRepository;

  /// Date range of sessions currently held in state.
  DateTime? _loadedFrom;
  DateTime? _loadedTo;

  Future<void> load() async {
    emit(const ScheduleState.loading());
    try {
      emit(await _fetch(DateTime.now(), refresh: false));
    } on Object catch (e, st) {
      emit(ScheduleState.error(errorMessage(e, st)));
    }
  }

  /// Pull-to-refresh: keeps the current screen and filters. Returns an error
  /// message on failure, `null` otherwise.
  Future<String?> refresh() async {
    final current = state;
    if (current is! ScheduleLoaded) {
      await load();
      return null;
    }
    try {
      final fresh = await _fetch(
        current.dateFilter ?? DateTime.now(),
        refresh: true,
      );
      if (isClosed) return null;
      emit(
        current.copyWith(
          sessions: fresh.sessions,
          classes: fresh.classes,
          subjects: fresh.subjects,
        ),
      );
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  Future<ScheduleLoaded> _fetch(
    DateTime around, {
    required bool refresh,
  }) async {
    final from = DateTime(around.year, around.month - 1);
    final to = DateTime(around.year, around.month + 2, 0);
    final results = await Future.wait([
      _sessionRepository.getBetween(from, to, refresh: refresh),
      _classRepository.getAll(),
      _subjectRepository.getAll(),
    ]);
    _loadedFrom = from;
    _loadedTo = to;
    return ScheduleLoaded(
      sessions: results[0] as List<Session>,
      classes: results[1] as List<ClassGroup>,
      subjects: results[2] as List<Subject>,
      dateFilter: around,
    );
  }

  Future<void> setDate(DateTime? date) async {
    final s = state;
    if (s is! ScheduleLoaded) return;
    emit(s.copyWith(dateFilter: date));
    if (date != null) await _ensureLoaded(date);
  }

  /// The date strip shows about two weeks around the selected day; fetch more
  /// when that spills outside the loaded window. Failures leave the days empty.
  Future<void> _ensureLoaded(DateTime date) async {
    final from = _loadedFrom;
    final to = _loadedTo;
    if (from == null || to == null) return;
    final need0 = DateTime(date.year, date.month, date.day - 15);
    final need1 = DateTime(date.year, date.month, date.day + 15);
    if (!need0.isBefore(from) && !need1.isAfter(to)) return;

    try {
      final more = await _sessionRepository.getBetween(need0, need1);
      final cur = state;
      if (isClosed || cur is! ScheduleLoaded) return;
      final byId = {for (final x in cur.sessions) x.id: x};
      for (final x in more) {
        byId[x.id] = x;
      }
      _loadedFrom = need0.isBefore(from) ? need0 : from;
      _loadedTo = need1.isAfter(to) ? need1 : to;
      emit(cur.copyWith(sessions: byId.values.toList()));
    } on Object {
      // Ignore; pull-to-refresh retries.
    }
  }

  void setClassFilters(Set<String> ids) {
    final s = state;
    if (s is ScheduleLoaded) emit(s.copyWith(classFilterIds: ids));
  }

  void toggleClassFilter(String id) {
    final s = state;
    if (s is ScheduleLoaded) {
      final updated = Set<String>.from(s.classFilterIds);
      updated.contains(id) ? updated.remove(id) : updated.add(id);
      emit(s.copyWith(classFilterIds: updated));
    }
  }

  void setSubjectFilters(Set<String> ids) {
    final s = state;
    if (s is ScheduleLoaded) emit(s.copyWith(subjectFilterIds: ids));
  }

  void toggleSubjectFilter(String id) {
    final s = state;
    if (s is ScheduleLoaded) {
      final updated = Set<String>.from(s.subjectFilterIds);
      updated.contains(id) ? updated.remove(id) : updated.add(id);
      emit(s.copyWith(subjectFilterIds: updated));
    }
  }

  void reset() {
    final s = state;
    if (s is ScheduleLoaded) {
      emit(
        s.copyWith(
          dateFilter: DateTime.now(),
          classFilterIds: const {},
          subjectFilterIds: const {},
        ),
      );
    }
  }

  List<Session> filtered() {
    final s = state;
    if (s is! ScheduleLoaded) return const [];
    var items = List<Session>.from(s.sessions);
    if (s.dateFilter != null) {
      final d = s.dateFilter!;
      items = items
          .where(
            (x) =>
                x.date.year == d.year &&
                x.date.month == d.month &&
                x.date.day == d.day,
          )
          .toList();
    }
    if (s.classFilterIds.isNotEmpty) {
      items = items
          .where((x) => x.classIds.any(s.classFilterIds.contains))
          .toList();
    }
    if (s.subjectFilterIds.isNotEmpty) {
      items = items
          .where((x) => x.subjectIds.any(s.subjectFilterIds.contains))
          .toList();
    }
    items.sort((a, b) {
      final c = a.date.compareTo(b.date);
      if (c != 0) return c;
      return a.startTime.compareTo(b.startTime);
    });
    return items;
  }
}
