import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/mappers/parent_mappers.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/children_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/attendance/parent_attendance_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/progress_stats.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_state.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';

class _Children implements ChildrenRepository {
  _Children(this.items);
  List<Child> items;
  Object? error;
  int calls = 0;

  @override
  Future<List<Child>> getChildren({bool refresh = false}) async {
    calls++;
    if (error != null) throw error!;
    return items;
  }
}

class _Attendance implements ChildAttendanceRepository {
  final Map<String, Completer<List<ChildAttendanceRecord>>> gates = {};
  final List<String> requested = [];
  Object? error;

  @override
  Future<List<ChildAttendanceRecord>> getForChild(
    String childId, {
    bool refresh = false,
  }) {
    requested.add(childId);
    if (error != null) return Future.error(error!);
    final gate = gates[childId];
    if (gate != null) return gate.future;
    return Future.value(
      attendanceFromJson(
        fx.childAttendance,
      ).map((r) => r.copyWith(childId: childId)).toList(),
    );
  }
}

class _Assignments implements ChildAssignmentsRepository {
  Object? error;
  @override
  Future<List<ChildAssignment>> getForChild(
    String childId, {
    bool refresh = false,
  }) async {
    if (error != null) throw error!;
    return assignmentsFromJson(
      fx.childAssignments,
    ).map((a) => a.copyWith(childId: childId)).toList();
  }
}

class _Schedule implements ChildScheduleRepository {
  final List<String> requested = [];
  Object? error;
  List<Session> sessions = [];

  @override
  Future<ChildSchedule> getBetween(
    String childId,
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async {
    requested.add(childId);
    if (error != null) throw error!;
    return ChildSchedule(
      sessions: sessions,
      subjects: const [Subject(id: '18', name: 'Computer')],
      classes: const [ClassGroup(id: '23', name: 'Class 1')],
    );
  }

  @override
  Future<Session?> getById(String childId, String sessionId) async => null;
}

const _irha = Child(id: '3', name: 'Irha Shahzadi', className: 'Class 2');
const _jannat = Child(id: '2', name: 'Jannat Shahzadi', className: 'Class 1');

Session _session(String id, DateTime date, {List<SessionTeacher>? teachers}) =>
    Session(
      id: id,
      date: DateTime(date.year, date.month, date.day),
      startTime: '09:00',
      endTime: '10:00',
      classIds: const ['23'],
      subjectIds: const ['18'],
      teacherId: '',
      teachers:
          teachers ??
          const [
            SessionTeacher(id: '3', name: 'Tahir Mughal', subjectIds: ['18']),
          ],
    );

void main() {
  late FakeAuthRepository auth;
  late InMemoryKeyValueStore store;
  late _Children repo;

  setUp(() {
    auth = FakeAuthRepository(context: AuthContext.fromJson(fx.parentContext));
    store = InMemoryKeyValueStore();
    repo = _Children([_irha, _jannat]);
  });

  ChildrenCubit makeChildren() =>
      ChildrenCubit(repository: repo, store: store, auth: auth);

  Future<ChildrenCubit> loaded() async {
    final c = makeChildren();
    await c.stream.firstWhere((s) => s is ChildrenLoaded);
    return c;
  }

  group('ChildrenCubit', () {
    test('selects the first child by default', () async {
      final c = await loaded();
      final s = c.state as ChildrenLoaded;
      expect(s.children, hasLength(2));
      expect(s.selected?.id, '3');
      await c.close();
    });

    test('select() changes the child and remembers it per role', () async {
      final c = await loaded();
      await c.select(_jannat);
      expect(c.state.selectedChild?.id, '2');
      expect(await store.read('parent.selected_child.Parent:8'), '2');
      await c.close();

      // Next app start picks the saved child.
      final again = await loaded();
      expect(again.state.selectedChild?.id, '2');
      await again.close();
    });

    test(
      'a saved child that is no longer linked falls back to the first',
      () async {
        await store.write('parent.selected_child.Parent:8', '999');
        final c = await loaded();
        expect(c.state.selectedChild?.id, '3');
        await c.close();
      },
    );

    test('selecting a child that is not in the list is ignored', () async {
      final c = await loaded();
      await c.select(const Child(id: '77', name: 'Stranger'));
      expect(c.state.selectedChild?.id, '3');
      await c.close();
    });

    test('no children → loaded with an empty list and no selection', () async {
      repo.items = [];
      final c = await loaded();
      final s = c.state as ChildrenLoaded;
      expect(s.children, isEmpty);
      expect(s.selected, isNull);
      await c.close();
    });

    test('failure → error state; retry recovers', () async {
      repo.error = const NetworkException();
      final c = makeChildren();
      await c.stream.firstWhere((s) => s is ChildrenError);
      repo.error = null;
      await c.load();
      expect(c.state, isA<ChildrenLoaded>());
      await c.close();
    });

    test('a failed background refresh keeps the current children', () async {
      final c = await loaded();
      repo.error = const ServerException();
      await c.load(refresh: true);
      expect(c.state, isA<ChildrenLoaded>());
      expect((c.state as ChildrenLoaded).children, hasLength(2));
      await c.close();
    });

    test('refresh keeps the selected child', () async {
      final c = await loaded();
      await c.select(_jannat);
      await c.load(refresh: true);
      expect(c.state.selectedChild?.id, '2');
      await c.close();
    });

    test(
      'resets when the role is no longer parent; reloads on return',
      () async {
        final c = await loaded();
        auth.signInAs(AuthContext.fromJson(fx.teacherContext));
        await Future<void>.delayed(Duration.zero);
        expect(c.state, isA<ChildrenInitial>());

        final callsBefore = repo.calls;
        auth.signInAs(AuthContext.fromJson(fx.parentContext));
        await c.stream.firstWhere((s) => s is ChildrenLoaded);
        expect(repo.calls, greaterThan(callsBefore));
        await c.close();
      },
    );
  });

  group('child-scoped cubits', () {
    test('attendance reloads for the newly selected child', () async {
      final children = await loaded();
      final att = _Attendance();
      final cubit = ParentAttendanceCubit(children: children, repository: att);
      await cubit.load();
      expect((cubit.state as ParentAttendanceLoaded).child.id, '3');

      await children.select(_jannat);
      await cubit.stream.firstWhere(
        (s) => s is ParentAttendanceLoaded && s.child.id == '2',
      );
      expect(att.requested, containsAllInOrder(['3', '2']));
      await cubit.close();
      await children.close();
    });

    test(
      'a slow response for the previous child never overwrites the new one',
      () async {
        final children = await loaded();
        final att = _Attendance()
          ..gates['3'] = Completer<List<ChildAttendanceRecord>>();
        final cubit = ParentAttendanceCubit(
          children: children,
          repository: att,
        );
        unawaited(cubit.load()); // child 3 is slow

        await children.select(_jannat);
        await cubit.stream.firstWhere(
          (s) => s is ParentAttendanceLoaded && s.child.id == '2',
        );

        // The slow answer for child 3 arrives afterwards: it must be ignored.
        att.gates['3']!.complete([
          ChildAttendanceRecord(
            childId: '3',
            date: DateTime(2026),
            status: 'absent',
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        final s = cubit.state as ParentAttendanceLoaded;
        expect(s.child.id, '2');
        expect(s.records.every((r) => r.childId == '2'), isTrue);
        await cubit.close();
        await children.close();
      },
    );

    test('attendance counts, filter toggle and error state', () async {
      final children = await loaded();
      final att = _Attendance();
      final cubit = ParentAttendanceCubit(children: children, repository: att);
      await cubit.load();

      final c = cubit.counts();
      expect((c.total, c.present, c.late, c.absent), (3, 2, 1, 0));

      cubit.setFilter('late');
      expect(cubit.visible(), hasLength(1));
      cubit.setFilter('late'); // tapping again clears
      expect(cubit.visible(), hasLength(3));

      att.error = const NetworkException();
      await cubit.load();
      expect(cubit.state, isA<ParentAttendanceError>());
      await cubit.close();
      await children.close();
    });

    test(
      'assignments: counts follow the web, overdue is a subset of pending',
      () async {
        final children = await loaded();
        final cubit = ParentAssignmentsCubit(
          children: children,
          repository: _Assignments(),
          clock: () => DateTime(2026, 10, 12),
        );
        await cubit.load();

        final c = cubit.counts();
        expect(c.total, 2);
        expect(c.completed, 0);
        // One is graded without a hand-in: neither pending nor overdue.
        expect(c.pending, 1);
        expect(c.overdue, 1); // both deadlines are before Oct 12

        cubit.setFilter(AssignmentFilter.overdue);
        expect(cubit.visible(), hasLength(1));
        cubit.setFilter(AssignmentFilter.pending);
        expect(cubit.visible(), hasLength(1));
        cubit.setFilter(AssignmentFilter.completed);
        expect(cubit.visible(), isEmpty);
        await cubit.close();
        await children.close();
      },
    );

    test('with no children the screens stay idle', () async {
      repo.items = [];
      final children = await loaded();
      final cubit = ParentAttendanceCubit(
        children: children,
        repository: _Attendance(),
      );
      await cubit.load();
      expect(cubit.state, isA<ParentAttendanceInitial>());
      await cubit.close();
      await children.close();
    });
  });

  group('ParentHomeCubit', () {
    final now = DateTime(2026, 10, 12, 10); // a Monday
    late _Schedule schedule;
    late ChildrenCubit children;

    ParentHomeCubit make() => ParentHomeCubit(
      children: children,
      schedule: schedule,
      assignments: _Assignments(),
      attendance: _Attendance(),
      clock: () => now,
    );

    setUp(() async {
      schedule = _Schedule()
        ..sessions = [
          _session('today', now),
          _session(
            'other_teacher',
            now,
            teachers: const [
              SessionTeacher(id: '9', name: 'Adnan Ilyas', subjectIds: ['18']),
            ],
          ),
          _session('tomorrow', now.add(const Duration(days: 1))),
          _session('lastWeek', now.subtract(const Duration(days: 7))),
        ];
      children = await loaded();
    });

    tearDown(() => children.close());

    group('upcoming sessions (Up Coming)', () {
      Session at(String id, DateTime d, String start, String end) =>
          _session(id, d).copyWith(startTime: start, endTime: end);

      setUp(() {
        schedule.sessions = [
          at('tonight', now, '18:00', '19:00'),
          at('tomorrow', now.add(const Duration(days: 1)), '09:00', '10:00'),
          at('day3', now.add(const Duration(days: 3)), '09:00', '10:00'),
          at('day4', now.add(const Duration(days: 4)), '09:00', '10:00'),
          at('day5', now.add(const Duration(days: 5)), '09:00', '10:00'),
          at('earlier', now, '08:00', '09:00'), // already over
        ];
      });

      test('is the next three classes, soonest first, across days', () async {
        final cubit = make();
        await cubit.load();
        expect(cubit.upcomingSessions().map((x) => x.id), [
          'tonight',
          'tomorrow',
          'day3',
        ]);
        expect(ParentHomeCubit.upcomingLimit, 3);
        await cubit.close();
      });

      test('does not change with the agenda, view or filters', () async {
        final cubit = make();
        await cubit.load();
        final before = cubit.upcomingSessions().map((x) => x.id).toList();
        cubit.setView(ParentHomeView.month);
        cubit.setQuery('no such subject');
        cubit.setDayFilter('');
        expect(cubit.upcomingSessions().map((x) => x.id), before);
        await cubit.close();
      });

      test('shows fewer when fewer are left', () async {
        final cubit = make();
        await cubit.load();
        expect(cubit.upcomingSessions(limit: 10).length, 5);
        schedule.sessions = [at('only', now, '23:00', '23:30')];
        await cubit.load();
        expect(cubit.upcomingSessions().map((x) => x.id), ['only']);
        await cubit.close();
      });

      test('classes that are over or in progress are not listed', () async {
        final cubit = make();
        await cubit.load();
        cubit.setView(ParentHomeView.month);
        final ids = cubit.upcomingSessions(limit: 10).map((x) => x.id);
        expect(ids, isNot(contains('earlier')));
        await cubit.close();
      });
    });

    test('defaults to today, agenda view, with stat inputs', () async {
      final cubit = make();
      await cubit.load();
      final s = cubit.state as ParentHomeLoaded;

      expect(s.dayFilter, 'today');
      expect(s.view, ParentHomeView.agenda);
      expect(s.child.id, '3');
      expect(s.attendanceStat, const RatioStat(3, 3));
      expect(s.homeworkStat, const RatioStat(0, 1)); // graded work is no miss
      expect(s.scoreStat, const RatioStat(89, 100));
      expect(cubit.filteredSessions().map((x) => x.id), [
        'today',
        'other_teacher',
      ]);
      expect(cubit.todayCount(), 2);
      await cubit.close();
    });

    test('day filters, subject and teacher filters combine', () async {
      final cubit = make();
      await cubit.load();

      cubit.setDayFilter('week');
      expect(cubit.filteredSessions().map((x) => x.id), [
        'today',
        'other_teacher',
        'tomorrow',
      ]);
      cubit.setDayFilter('');
      expect(cubit.filteredSessions(), hasLength(4));

      cubit.setTeacherFilters({'3'});
      expect(
        cubit.filteredSessions().map((x) => x.id),
        ['lastWeek', 'today', 'tomorrow'],
      );
      cubit.setSubjectFilters({'999'});
      expect(cubit.filteredSessions(), isEmpty);
      cubit.resetFilters();
      expect((cubit.state as ParentHomeLoaded).dayFilter, 'today');
      await cubit.close();
    });

    test('search matches subject and teacher names', () async {
      final cubit = make();
      await cubit.load();
      cubit.setDayFilter('');
      cubit.setQuery('adnan');
      expect(cubit.filteredSessions().map((x) => x.id), ['other_teacher']);
      cubit.setQuery('comput');
      expect(cubit.filteredSessions(), hasLength(4));
      cubit.setQuery('zzz');
      expect(cubit.filteredSessions(), isEmpty);
      await cubit.close();
    });

    test('teachers() lists distinct teachers for the filter sheet', () async {
      final cubit = make();
      await cubit.load();
      expect(cubit.teachers().map((t) => t.name), [
        'Adnan Ilyas',
        'Tahir Mughal',
      ]);
      await cubit.close();
    });

    test('switching child reloads and resets filters', () async {
      final cubit = make();
      await cubit.load();
      cubit.setDayFilter('month');

      await children.select(_jannat);
      await cubit.stream.firstWhere(
        (s) => s is ParentHomeLoaded && s.child.id == '2',
      );
      expect((cubit.state as ParentHomeLoaded).dayFilter, 'today');
      expect(schedule.requested, ['3', '2']);
      await cubit.close();
    });

    test(
      'schedule failure → error; stat failures never break the screen',
      () async {
        final cubit = make();
        schedule.error = const NetworkException();
        await cubit.load();
        expect(cubit.state, isA<ParentHomeError>());

        schedule.error = null;
        final failingAssignments = ParentHomeCubit(
          children: children,
          schedule: schedule,
          assignments: _Assignments()..error = const ServerException(),
          attendance: _Attendance()..error = const ServerException(),
          clock: () => now,
        );
        await failingAssignments.load();
        final s = failingAssignments.state as ParentHomeLoaded;
        // Tiles show "Unavailable"; the screen itself is fine.
        expect(s.attendanceStat, isNull);
        expect(s.homeworkStat, isNull);
        expect(s.scoreStat, isNull);
        await cubit.close();
        await failingAssignments.close();
      },
    );

    test(
      'refresh keeps filters and returns the error text on failure',
      () async {
        final cubit = make();
        await cubit.load();
        cubit.setDayFilter('week');

        expect(await cubit.refresh(), isNull);
        expect((cubit.state as ParentHomeLoaded).dayFilter, 'week');

        schedule.error = const ServerException();
        expect(await cubit.refresh(), isNotNull);
        expect(cubit.state, isA<ParentHomeLoaded>());
        await cubit.close();
      },
    );
  });
}
