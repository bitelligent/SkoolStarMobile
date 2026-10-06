import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/features/schedule/cubit/schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  ScheduleCubit({
    required SessionRepository sessionRepository,
    required ClassRepository classRepository,
    required SubjectRepository subjectRepository,
  })  : _sessionRepository = sessionRepository,
        _classRepository = classRepository,
        _subjectRepository = subjectRepository,
        super(const ScheduleState.initial());

  final SessionRepository _sessionRepository;
  final ClassRepository _classRepository;
  final SubjectRepository _subjectRepository;

  Future<void> load() async {
    emit(const ScheduleState.loading());
    try {
      final sessions = await _sessionRepository.getAll();
      final classes = await _classRepository.getAll();
      final subjects = await _subjectRepository.getAll();
      emit(
        ScheduleState.loaded(
          sessions: sessions,
          classes: classes,
          subjects: subjects,
          dateFilter: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      emit(ScheduleState.error(e.toString()));
    }
  }

  void setDate(DateTime? date) {
    final s = state;
    if (s is ScheduleLoaded) emit(s.copyWith(dateFilter: date));
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
          dateFilter: null,
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
