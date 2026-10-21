import 'dart:async';

import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/core/utils/day_filter.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_scoped_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_state.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';

class ParentHomeCubit extends ChildScopedCubit<ParentHomeState> {
  ParentHomeCubit({
    required ChildrenCubit children,
    required ChildScheduleRepository schedule,
    required ChildAssignmentsRepository assignments,
    required ChildAttendanceRepository attendance,
    DateTime Function()? clock,
  }) : _schedule = schedule,
       _assignments = assignments,
       _attendance = attendance,
       _now = clock ?? DateTime.now,
       super(const ParentHomeState.initial(), children);

  final ChildScheduleRepository _schedule;
  final ChildAssignmentsRepository _assignments;
  final ChildAttendanceRepository _attendance;
  final DateTime Function() _now;

  /// Date range of sessions currently held in state.
  DateTime? _loadedFrom;
  DateTime? _loadedTo;

  @override
  Future<void> load({bool refresh = false}) async {
    final c = child;
    if (c == null) {
      emit(const ParentHomeState.initial());
      return;
    }
    final ticket = beginLoad();
    emit(const ParentHomeState.loading());
    try {
      final loaded = await _fetch(c, _now(), refresh: refresh);
      if (isCurrent(ticket)) emit(loaded);
    } on Object catch (e, st) {
      if (isCurrent(ticket)) emit(ParentHomeState.error(errorMessage(e, st)));
    }
  }

  /// Pull-to-refresh: keeps filters and the current view. Returns an error
  /// message on failure, `null` on success.
  Future<String?> refresh() async {
    // Newly linked / unlinked children appear without a dedicated button.
    // The selected child is kept, so this does not reload the screens.
    unawaited(children.load(refresh: true));
    final current = state;
    final c = child;
    if (current is! ParentHomeLoaded || c == null) {
      await load(refresh: true);
      return null;
    }
    final ticket = beginLoad();
    try {
      final fresh = await _fetch(c, current.focusDate, refresh: true);
      if (!isCurrent(ticket)) return null;
      emit(
        current.copyWith(
          sessions: fresh.sessions,
          subjects: fresh.subjects,
          classes: fresh.classes,
          attendanceStat: fresh.attendanceStat,
          homeworkStat: fresh.homeworkStat,
          scoreStat: fresh.scoreStat,
        ),
      );
      return null;
    } on Object catch (e, st) {
      return errorMessage(e, st);
    }
  }

  Future<ParentHomeLoaded> _fetch(
    Child c,
    DateTime around, {
    required bool refresh,
  }) async {
    final from = DateTime(around.year, around.month - 1);
    final to = DateTime(around.year, around.month + 2, 0);

    // The schedule is essential; the stat tiles are not.
    final scheduleFuture = _schedule.getBetween(
      c.id,
      from,
      to,
      refresh: refresh,
    );
    final assignmentsFuture = _assignments
        .getForChild(c.id, refresh: refresh)
        .then<List<ChildAssignment>?>((list) => list)
        .catchError((Object _) => null as List<ChildAssignment>?);
    final attendanceFuture = _attendance
        .getForChild(c.id, refresh: refresh)
        .then<List<ChildAttendanceRecord>?>((list) => list)
        .catchError((Object _) => null as List<ChildAttendanceRecord>?);

    final schedule = (await scheduleFuture).withClass(c.className);
    final assignments = await assignmentsFuture;
    final attendance = await attendanceFuture;
    final now = _now();
    _loadedFrom = from;
    _loadedTo = to;

    return ParentHomeLoaded(
      child: c,
      sessions: schedule.sessions,
      subjects: schedule.subjects,
      classes: schedule.classes,
      focusDate: around,
      attendanceStat: attendance == null
          ? null
          : ProgressStats.attendance(attendance, now: now),
      homeworkStat: assignments == null
          ? null
          : ProgressStats.homework(assignments, now: now),
      scoreStat: assignments == null
          ? null
          : ProgressStats.score(assignments, now: now),
    );
  }

  // ── Filters ────────────────────────────────────────────────────────────

  ParentHomeLoaded? get _loaded {
    final s = state;
    return s is ParentHomeLoaded ? s : null;
  }

  void setQuery(String query) {
    final s = _loaded;
    if (s != null) emit(s.copyWith(query: query));
  }

  /// Picking a relative day range replaces a specific day from the calendar.
  void setDayFilter(String value) {
    final s = _loaded;
    if (s != null) emit(s.copyWith(dayFilter: value, selectedDate: null));
  }

  void setSubjectFilters(Set<String> ids) {
    final s = _loaded;
    if (s != null) emit(s.copyWith(subjectFilterIds: ids));
  }

  void setTeacherFilters(Set<String> ids) {
    final s = _loaded;
    if (s != null) emit(s.copyWith(teacherFilterIds: ids));
  }

  void setView(ParentHomeView view) {
    final s = _loaded;
    if (s != null) emit(s.copyWith(view: view));
  }

  void focusDate(DateTime date) {
    final s = _loaded;
    if (s == null) return;
    emit(
      s.copyWith(
        selectedDate: DateTime(date.year, date.month, date.day),
        focusDate: date,
        view: ParentHomeView.agenda,
      ),
    );
  }

  void clearSelectedDate() {
    final s = _loaded;
    if (s != null) emit(s.copyWith(selectedDate: null));
  }

  void resetFilters() {
    final s = _loaded;
    if (s == null) return;
    emit(
      s.copyWith(
        dayFilter: defaultDayFilter,
        subjectFilterIds: const {},
        teacherFilterIds: const {},
        query: '',
        selectedDate: null,
      ),
    );
  }

  Future<void> stepMonth(int delta) async {
    final s = _loaded;
    if (s == null) return;
    final d = DateTime(s.focusDate.year, s.focusDate.month + delta, 1);
    emit(s.copyWith(focusDate: d));
    await _ensureMonthLoaded(d);
  }

  Future<void> goToToday() async {
    final s = _loaded;
    if (s == null) return;
    final now = _now();
    emit(s.copyWith(focusDate: now));
    await _ensureMonthLoaded(now);
  }

  /// Fetches months outside the loaded window when the user pages the
  /// calendar. Failures leave that month empty; pull-to-refresh retries.
  Future<void> _ensureMonthLoaded(DateTime month) async {
    final from = _loadedFrom;
    final to = _loadedTo;
    final c = child;
    if (from == null || to == null || c == null) return;
    final first = DateTime(month.year, month.month);
    final last = DateTime(month.year, month.month + 1, 0);
    if (!first.isBefore(from) && !last.isAfter(to)) return;

    try {
      final more = (await _schedule.getBetween(
        c.id,
        first,
        last,
      )).withClass(c.className);
      final cur = _loaded;
      if (isClosed || cur == null || cur.child.id != c.id) return;
      final byId = {for (final s in cur.sessions) s.id: s};
      for (final s in more.sessions) {
        byId[s.id] = s;
      }
      final subjects = {for (final s in cur.subjects) s.id: s};
      for (final s in more.subjects) {
        subjects[s.id] = s;
      }
      _loadedFrom = first.isBefore(from) ? first : from;
      _loadedTo = last.isAfter(to) ? last : to;
      emit(
        cur.copyWith(
          sessions: byId.values.toList(),
          subjects: subjects.values.toList(),
        ),
      );
    } on Object {
      // Leave the month empty.
    }
  }

  // ── Derived data ───────────────────────────────────────────────────────

  /// Distinct teachers across the loaded sessions, for the filter sheet.
  List<SessionTeacher> teachers() {
    final s = _loaded;
    if (s == null) return const [];
    final byId = <String, SessionTeacher>{};
    for (final session in s.sessions) {
      for (final t in session.teachers) {
        byId.putIfAbsent(t.id, () => t);
      }
    }
    return byId.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  bool _matches(ParentHomeLoaded s, Session session, {required bool byDay}) {
    if (byDay) {
      final selected = s.selectedDate;
      if (selected != null) {
        if (!sameDay(session.date, selected)) return false;
      } else if (!matchesDayFilter(session.date, s.dayFilter, _now())) {
        return false;
      }
    }
    if (s.subjectFilterIds.isNotEmpty &&
        !session.subjectIds.any(s.subjectFilterIds.contains)) {
      return false;
    }
    if (s.teacherFilterIds.isNotEmpty &&
        !session.teachers.any((t) => s.teacherFilterIds.contains(t.id))) {
      return false;
    }
    final q = s.query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final names = [
        for (final sub in s.subjects)
          if (session.subjectIds.contains(sub.id)) sub.name,
        for (final t in session.teachers) t.name,
      ].join(' ').toLowerCase();
      if (!names.contains(q)) return false;
    }
    return true;
  }

  /// Sessions for the Month calendar markers: everything except the day
  /// filter, so days keep their dot.
  List<Session> calendarSessions() {
    final s = _loaded;
    if (s == null) return const [];
    return s.sessions.where((x) => _matches(s, x, byDay: false)).toList();
  }

  /// Sessions for the Agenda list.
  List<Session> filteredSessions() {
    final s = _loaded;
    if (s == null) return const [];
    return s.sessions.where((x) => _matches(s, x, byDay: true)).toList()
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.startTime.compareTo(b.startTime);
      });
  }

  /// The next classes that have not finished yet (ignores the filters: this
  /// is "what's coming", whatever the schedule below is showing), soonest
  /// first. A class already in progress is shown by the live banner instead.
  List<Session> upcomingSessions({int limit = 4}) {
    final s = _loaded;
    if (s == null) return const [];
    final now = _now();
    final upcoming = [
      for (final x in s.sessions)
        if (x.phaseAt(now) == SessionPhase.upcoming ||
            x.phaseAt(now) == SessionPhase.laterToday)
          x,
    ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return upcoming.take(limit).toList();
  }

  int todayCount() {
    final now = _now();
    return calendarSessions().where((x) => sameDay(x.date, now)).length;
  }
}
