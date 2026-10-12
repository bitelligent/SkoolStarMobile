import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_state.dart';

/// Day filter value for "today" (also the default). `''` means all days,
/// `'week'` the current Monday–Sunday week and `'month'` the current month.
const defaultDayFilter = 'today';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({
    required InstituteRepository instituteRepository,
    required UserRepository userRepository,
    required SessionRepository sessionRepository,
    required ClassRepository classRepository,
    required SubjectRepository subjectRepository,
    required NotificationsRepository notificationsRepository,
  }) : _instituteRepository = instituteRepository,
       _userRepository = userRepository,
       _sessionRepository = sessionRepository,
       _classRepository = classRepository,
       _subjectRepository = subjectRepository,
       _notificationsRepository = notificationsRepository,
       super(const DashboardState.initial());

  final InstituteRepository _instituteRepository;
  final UserRepository _userRepository;
  final SessionRepository _sessionRepository;
  final ClassRepository _classRepository;
  final SubjectRepository _subjectRepository;
  final NotificationsRepository _notificationsRepository;

  /// Date range of sessions currently held in state.
  DateTime? _loadedFrom;
  DateTime? _loadedTo;

  /// Loads the current month plus the neighbouring months so the calendar
  /// and agenda are populated while paging.
  Future<void> load() async {
    emit(const DashboardState.loading());
    try {
      emit(await _fetch(DateTime.now(), refresh: false));
    } on Object catch (e, st) {
      emit(DashboardState.error(errorMessage(e, st)));
    }
  }

  /// Pull-to-refresh: keeps the current screen (and filters) and swaps in
  /// fresh data. Returns an error message if it failed, `null` otherwise.
  Future<String?> refresh() async {
    final current = state;
    if (current is! DashboardLoaded) {
      await load();
      return null;
    }
    try {
      final fresh = await _fetch(current.focusDate, refresh: true);
      if (isClosed) return null;
      emit(
        current.copyWith(
          institute: fresh.institute,
          user: fresh.user,
          liveSession: fresh.liveSession,
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

  Future<DashboardLoaded> _fetch(
    DateTime focus, {
    required bool refresh,
  }) async {
    final from = DateTime(focus.year, focus.month - 1);
    final to = DateTime(focus.year, focus.month + 2, 0);

    final institute = await _instituteRepository.getCurrent();
    final results = await Future.wait([
      _userRepository.getCurrentUser(),
      _sessionRepository.getBetween(from, to, refresh: refresh),
      _classRepository.getAll(),
      _subjectRepository.getAll(),
      _hasUnreadNotifications(),
    ]);
    final sessions = results[1] as List<Session>;
    _loadedFrom = from;
    _loadedTo = to;

    return DashboardLoaded(
      institute: institute,
      user: (results[0] as UserModel).copyWith(
        hasUnreadNotifications: results[4] as bool,
      ),
      liveSession: sessions.where((s) => s.isLive).firstOrNull,
      sessions: sessions,
      classes: results[2] as List<ClassGroup>,
      subjects: results[3] as List<Subject>,
      focusDate: focus,
      // Open on what a teacher needs first: today's sessions.
      dayFilter: defaultDayFilter,
      view: DashboardView.agenda,
    );
  }

  /// Notifications have no backend yet (mock data); never fail the dashboard
  /// because of them.
  Future<bool> _hasUnreadNotifications() async {
    try {
      final data = await _notificationsRepository.getNotifications();
      return data.items.any((n) => !n.isRead);
    } on Object {
      return false;
    }
  }

  void setQuery(String query) {
    final s = state;
    if (s is DashboardLoaded) emit(s.copyWith(query: query));
  }

  /// Chooses a relative day range (`''`, `'today'`, `'week'`, `'month'`).
  /// Picking one replaces any specific day chosen on the calendar.
  void setDayFilter(String value) {
    final s = state;
    if (s is DashboardLoaded) {
      emit(s.copyWith(dayFilter: value, selectedDate: null));
    }
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
          dayFilter: defaultDayFilter,
          classFilterIds: const {},
          subjectFilterIds: const {},
          query: '',
          selectedDate: null,
        ),
      );
    }
  }

  Future<void> stepMonth(int delta) async {
    final s = state;
    if (s is! DashboardLoaded) return;
    final d = DateTime(s.focusDate.year, s.focusDate.month + delta, 1);
    emit(s.copyWith(focusDate: d));
    await _ensureMonthLoaded(d);
  }

  /// Fetches months outside the loaded window when the user pages the
  /// calendar. Failures are ignored: the month just shows no sessions and
  /// pulling to refresh retries.
  Future<void> _ensureMonthLoaded(DateTime month) async {
    final from = _loadedFrom;
    final to = _loadedTo;
    if (from == null || to == null) return;
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);
    if (!first.isBefore(from) && !last.isAfter(to)) return;

    try {
      final more = await _sessionRepository.getBetween(first, last);
      final cur = state;
      if (isClosed || cur is! DashboardLoaded) return;
      final byId = {for (final s in cur.sessions) s.id: s};
      for (final s in more) {
        byId[s.id] = s;
      }
      _loadedFrom = first.isBefore(from) ? first : from;
      _loadedTo = last.isAfter(to) ? last : to;
      emit(cur.copyWith(sessions: byId.values.toList()));
    } on Object {
      // Leave the month empty; see doc comment.
    }
  }

  Future<void> goToToday() async {
    final s = state;
    if (s is! DashboardLoaded) return;
    final now = DateTime.now();
    emit(s.copyWith(focusDate: now));
    await _ensureMonthLoaded(now);
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

  /// Sessions today that match the class/subject filters (the "Today" stat).
  int todayCount() {
    final s = state;
    if (s is! DashboardLoaded) return 0;
    final now = DateTime.now();
    return calendarSessions().where((x) => _sameDay(x.date, now)).length;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Whether [date] falls in the relative range named by [filter].
  static bool _matchesDayFilter(DateTime date, String filter, DateTime now) {
    final d = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    switch (filter) {
      case 'today':
        return d == today;
      case 'week':
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final sunday = monday.add(const Duration(days: 6));
        return !d.isBefore(monday) && !d.isAfter(sunday);
      case 'month':
        return d.year == today.year && d.month == today.month;
      default:
        return true; // '' = all days
    }
  }

  /// Sessions filtered by query/day/class/subject but ignoring the month
  /// focus — used to populate the agenda list.
  List<Session> filteredSessions() {
    final s = state;
    if (s is! DashboardLoaded) return const [];
    final now = DateTime.now();
    return s.sessions.where((session) {
      // A day picked on the calendar wins over the relative day filter.
      final selected = s.selectedDate;
      if (selected != null) {
        if (!_sameDay(session.date, selected)) return false;
      } else if (!_matchesDayFilter(session.date, s.dayFilter, now)) {
        return false;
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
    }).toList()..sort((a, b) {
      final c = a.date.compareTo(b.date);
      if (c != 0) return c;
      return a.startTime.compareTo(b.startTime);
    });
  }
}
