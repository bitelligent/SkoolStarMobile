import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required InstituteRepository instituteRepository,
    required UserRepository userRepository,
    required SessionRepository sessionRepository,
    required ClassRepository classRepository,
    required SubjectRepository subjectRepository,
  })  : _instituteRepository = instituteRepository,
        _userRepository = userRepository,
        _sessionRepository = sessionRepository,
        _classRepository = classRepository,
        _subjectRepository = subjectRepository,
        super(const DashboardState.initial());

  final InstituteRepository _instituteRepository;
  final UserRepository _userRepository;
  final SessionRepository _sessionRepository;
  final ClassRepository _classRepository;
  final SubjectRepository _subjectRepository;

  Future<void> load() async {
    emit(const DashboardState.loading());
    try {
      final institute = await _instituteRepository.getCurrent();
      final user = await _userRepository.getCurrentUser();
      final sessions = await _sessionRepository.getAll();
      final classes = await _classRepository.getAll();
      final subjects = await _subjectRepository.getAll();
      final live = await _sessionRepository.getLive();

      emit(
        DashboardState.loaded(
          institute: institute,
          user: user,
          liveSession: live,
          sessions: sessions,
          classes: classes,
          subjects: subjects,
          focusDate: DateTime.now(),
        ),
      );
    } on Exception catch (e) {
      emit(DashboardState.error(e.toString()));
    }
  }

  void setQuery(String query) {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(query: query));
  }

  void setDayFilter(String value) {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(dayFilter: value));
  }

  void setClassFilters(Set<String> ids) {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(classFilterIds: ids));
  }

  void toggleClassFilter(String id) {
    final s = state;
    if (s is DashboardLoaded) {
      final updated = Set<String>.from(s.classFilterIds);
      updated.contains(id) ? updated.remove(id) : updated.add(id);
      emit(s.copyWith(classFilterIds: updated));
    }
  }

  void setSubjectFilters(Set<String> ids) {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(subjectFilterIds: ids));
  }

  void toggleSubjectFilter(String id) {
    final s = state;
    if (s is DashboardLoaded) {
      final updated = Set<String>.from(s.subjectFilterIds);
      updated.contains(id) ? updated.remove(id) : updated.add(id);
      emit(s.copyWith(subjectFilterIds: updated));
    }
  }

  void setView(DashboardView view) {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(view: view));
  }

  /// Jump the Agenda view to focus a specific day. Also updates
  /// [DashboardLoaded.focusDate] so the calendar highlights the same day
  /// when the user switches back to the Month view.
  void focusDate(DateTime date) {
    final s = state;
    if (s is DashboardLoaded) {
      emit(
        s.copyWith(
          selectedDate: DateTime(date.year, date.month, date.day),
          focusDate: date,
          view: DashboardView.agenda,
        ),
      );
    }
  }

  void clearSelectedDate() {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(selectedDate: null));
  }

  void resetFilters() {
    final s = state;
    if (s is DashboardLoaded) {
      emit(
        s.copyWith(
          dayFilter: '',
          classFilterIds: const {},
          subjectFilterIds: const {},
          query: '',
          selectedDate: null,
        ),
      );
    }
  }

  void stepMonth(int delta) {
    final s = state;
    if (s is DashboardLoaded) {
      final d = DateTime(s.focusDate.year, s.focusDate.month + delta, 1);
      emit(s.copyWith(focusDate: d));
    }
  }

  void goToToday() {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(focusDate: DateTime.now()));
  }

  /// Sessions filtered by class/subject only — used by the Month calendar
  /// so each day keeps its "has sessions" marker even after the user picks
  /// a specific day in the agenda view.
  List<Session> calendarSessions() {
    final s = state;
    if (s is! DashboardLoaded) return const [];
    return s.sessions.where((session) {
      if (s.classFilterIds.isNotEmpty &&
          !session.classIds.any(s.classFilterIds.contains)) {
        return false;
      }
      if (s.subjectFilterIds.isNotEmpty &&
          !session.subjectIds.any(s.subjectFilterIds.contains)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Sessions filtered by query/day/class/subject but ignoring the month
  /// focus — used to populate the agenda list.
  List<Session> filteredSessions() {
    final s = state;
    if (s is! DashboardLoaded) return const [];
    return s.sessions.where((session) {
      if (s.selectedDate != null) {
        final d = s.selectedDate!;
        if (session.date.year != d.year ||
            session.date.month != d.month ||
            session.date.day != d.day) {
          return false;
        }
      }
      if (s.classFilterIds.isNotEmpty &&
          !session.classIds.any(s.classFilterIds.contains)) {
        return false;
      }
      if (s.subjectFilterIds.isNotEmpty &&
          !session.subjectIds.any(s.subjectFilterIds.contains)) {
        return false;
      }
      if (s.query.isNotEmpty) {
        final q = s.query.toLowerCase();
        final subjectNames = s.subjects
            .where((sub) => session.subjectIds.contains(sub.id))
            .map((e) => e.name.toLowerCase())
            .join(' ');
        if (!subjectNames.contains(q)) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        if (c != 0) return c;
        return a.startTime.compareTo(b.startTime);
      });
  }
}
