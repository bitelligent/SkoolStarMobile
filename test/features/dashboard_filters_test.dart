import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/institute_model.dart';
import 'package:skoolstar_teacher_module/data/models/notification_model.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:skoolstar_teacher_module/features/dashboard/cubit/dashboard_state.dart';
import 'package:skoolstar_teacher_module/features/schedule/cubit/schedule_cubit.dart';
import 'package:skoolstar_teacher_module/features/schedule/cubit/schedule_state.dart';

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

Session _s(
  String id,
  DateTime date, {
  List<String> classes = const ['23'],
  List<String> subjects = const ['18'],
}) => Session(
  id: id,
  date: _day(date),
  startTime: '09:00',
  endTime: '10:00',
  classIds: classes,
  subjectIds: subjects,
  teacherId: '3',
);

class _Sessions implements SessionRepository {
  _Sessions(this.items);
  final List<Session> items;

  @override
  Future<List<Session>> getBetween(
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async => items;

  @override
  Future<Session?> getById(String id) async => null;
}

class _Inst implements InstituteRepository {
  @override
  Future<InstituteInfo> getCurrent() async =>
      const InstituteInfo(id: '1', name: 'I', type: 'T');
}

class _User implements UserRepository {
  @override
  Future<UserModel> getCurrentUser() async =>
      const UserModel(id: '3', firstName: 'A', lastName: 'B', email: 'e');
  @override
  Future<UserModel> updateProfile({
    required String firstName,
    required String lastName,
    String? currentPassword,
    String? newPassword,
  }) => throw UnimplementedError();
}

class _Classes implements ClassRepository {
  @override
  Future<List<ClassGroup>> getAll() async => const [
    ClassGroup(id: '23', name: 'Class 1'),
    ClassGroup(id: '24', name: 'Class 2'),
  ];
}

class _Subjects implements SubjectRepository {
  @override
  Future<List<Subject>> getAll() async => const [
    Subject(id: '18', name: 'Computer'),
    Subject(id: '19', name: 'English'),
  ];
}

class _Notifs implements NotificationsRepository {
  @override
  Future<NotificationsData> getNotifications() async =>
      const NotificationsData(items: []);
}

void main() {
  final now = DateTime.now();
  final today = _day(now);
  final weekStart = today.subtract(Duration(days: today.weekday - 1)); // Mon
  final weekEnd = weekStart.add(const Duration(days: 6)); // Sun
  final nextWeek = weekEnd.add(const Duration(days: 1));
  final monthStart = DateTime(today.year, today.month);
  final monthEnd = DateTime(today.year, today.month + 1, 0);
  final lastMonth = monthStart.subtract(const Duration(days: 1));
  final nextMonth = DateTime(today.year, today.month + 1);

  final sessions = [
    _s('today_c23_s18', today),
    _s('today_c24_s19', today, classes: ['24'], subjects: ['19']),
    _s('weekStart', weekStart),
    _s('weekEnd', weekEnd),
    _s('nextWeek', nextWeek),
    _s('monthStart', monthStart),
    _s('monthEnd', monthEnd),
    _s('lastMonth', lastMonth),
    _s('nextMonth', nextMonth),
  ];

  DashboardCubit build() => DashboardCubit(
    instituteRepository: _Inst(),
    userRepository: _User(),
    sessionRepository: _Sessions(sessions),
    classRepository: _Classes(),
    subjectRepository: _Subjects(),
    notificationsRepository: _Notifs(),
  );

  Set<String> ids(DashboardCubit c) =>
      c.filteredSessions().map((s) => s.id).toSet();

  group('DashboardCubit day filter', () {
    test('defaults to today, in the agenda view', () async {
      final c = build();
      await c.load();
      final s = c.state as DashboardLoaded;
      expect(s.dayFilter, 'today');
      expect(s.view, DashboardView.agenda);
      expect(
        ids(c),
        {for (final x in sessions.where((x) => x.date == today)) x.id},
      );
    });

    test('all days shows everything loaded', () async {
      final c = build();
      await c.load();
      c.setDayFilter('');
      expect(ids(c), {for (final x in sessions) x.id});
    });

    test('this week is Monday through Sunday of the current week', () async {
      final c = build();
      await c.load();
      c.setDayFilter('week');
      final expected = {
        for (final x in sessions)
          if (!x.date.isBefore(weekStart) && !x.date.isAfter(weekEnd)) x.id,
      };
      expect(ids(c), expected);
      expect(ids(c), isNot(contains('nextWeek')));
      expect(ids(c), contains('weekStart'));
      expect(ids(c), contains('weekEnd'));
    });

    test('this month is the current calendar month only', () async {
      final c = build();
      await c.load();
      c.setDayFilter('month');
      final got = ids(c);
      expect(got, contains('monthStart'));
      expect(got, contains('monthEnd'));
      expect(got, contains('today_c23_s18'));
      expect(got, isNot(contains('lastMonth')));
      expect(got, isNot(contains('nextMonth')));
    });

    test('picking a calendar day overrides the day filter; picking a '
        'day filter clears the calendar day', () async {
      final c = build();
      await c.load();
      c.focusDate(weekStart);
      expect(
        ids(c),
        {for (final x in sessions.where((x) => x.date == weekStart)) x.id},
      );
      c.setDayFilter('today');
      expect((c.state as DashboardLoaded).selectedDate, isNull);
      expect(
        ids(c),
        {for (final x in sessions.where((x) => x.date == today)) x.id},
      );
    });
  });

  group('DashboardCubit class / subject filters', () {
    test('class filter keeps only sessions of that class', () async {
      final c = build();
      await c.load();
      c.setDayFilter('');
      c.setClassFilters({'24'});
      expect(ids(c), {'today_c24_s19'});
    });

    test('subject filter keeps only sessions of that subject', () async {
      final c = build();
      await c.load();
      c.setDayFilter('');
      c.setSubjectFilters({'19'});
      expect(ids(c), {'today_c24_s19'});
    });

    test(
      'multi-select is an OR within a filter and AND across filters',
      () async {
        final c = build();
        await c.load();
        c.setDayFilter('');
        c.setClassFilters({'23', '24'});
        expect(ids(c), {for (final x in sessions) x.id});
        c.setSubjectFilters({'19'});
        expect(ids(c), {'today_c24_s19'});
      },
    );

    test('class + day filters combine', () async {
      final c = build();
      await c.load();
      c.setClassFilters({'24'}); // day filter stays "today"
      expect(ids(c), {'today_c24_s19'});
      c.setClassFilters({'23'});
      expect(ids(c), {'today_c23_s18'});
    });

    test(
      'calendar markers follow class/subject but ignore the day filter',
      () async {
        final c = build();
        await c.load();
        c.setSubjectFilters({'19'});
        expect(c.calendarSessions().map((s) => s.id), ['today_c24_s19']);
        c.setSubjectFilters({});
        expect(c.calendarSessions(), hasLength(sessions.length));
      },
    );

    test('reset returns to the defaults (today, nothing selected)', () async {
      final c = build();
      await c.load();
      c.setDayFilter('month');
      c.setClassFilters({'24'});
      c.setSubjectFilters({'19'});
      c.setQuery('comp');
      c.resetFilters();
      final s = c.state as DashboardLoaded;
      expect(s.dayFilter, 'today');
      expect(s.classFilterIds, isEmpty);
      expect(s.subjectFilterIds, isEmpty);
      expect(s.query, '');
      expect(s.selectedDate, isNull);
    });

    test('filters survive a pull-to-refresh', () async {
      final c = build();
      await c.load();
      c.setDayFilter('month');
      c.setClassFilters({'24'});
      expect(await c.refresh(), isNull);
      final s = c.state as DashboardLoaded;
      expect(s.dayFilter, 'month');
      expect(s.classFilterIds, {'24'});
    });

    test('the Today stat counts today regardless of the day filter', () async {
      final c = build();
      await c.load();
      c.setDayFilter('month');
      expect(c.todayCount(), 2);
      c.setClassFilters({'24'});
      expect(c.todayCount(), 1);
    });
  });

  group('ScheduleCubit filters', () {
    ScheduleCubit sched() => ScheduleCubit(
      sessionRepository: _Sessions(sessions),
      classRepository: _Classes(),
      subjectRepository: _Subjects(),
    );

    test('defaults to today and filters by class / subject', () async {
      final c = sched();
      await c.load();
      expect(
        c.filtered().map((s) => s.id).toSet(),
        {for (final x in sessions.where((x) => x.date == today)) x.id},
      );
      c.setClassFilters({'24'});
      expect(c.filtered().map((s) => s.id), ['today_c24_s19']);
      c.setClassFilters({});
      c.setSubjectFilters({'18'});
      expect(c.filtered().map((s) => s.id), ['today_c23_s18']);
    });

    test('clearing the date shows every day; reset restores today', () async {
      final c = sched();
      await c.load();
      await c.setDate(null);
      expect(c.filtered(), hasLength(sessions.length));
      c.reset();
      final s = c.state as ScheduleLoaded;
      expect(s.dateFilter, isNotNull); // reset returns to today
    });
  });
}
