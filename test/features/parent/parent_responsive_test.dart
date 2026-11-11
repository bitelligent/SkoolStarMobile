import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_attendance_record.dart';
import 'package:skoolstar_teacher_module/data/models/parent/guardian_profile.dart';
import 'package:skoolstar_teacher_module/data/models/session_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_assignments_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/child_schedule_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/children_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/guardian_repository.dart';
import 'package:skoolstar_teacher_module/features/auth/view/role_selection_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/attendance/parent_attendance_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/attendance/parent_attendance_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_gate.dart';
import 'package:skoolstar_teacher_module/features/parent/common/child_switcher_header.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/home/parent_home_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/profile/parent_profile_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/profile/parent_profile_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/session_detail/parent_session_detail_screen.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import '../../helpers/test_fonts.dart';

const _sizes = <String, Size>{
  'small phone 320x568': Size(320, 568),
  'phone 360x740': Size(360, 740),
  'iPhone 390x844': Size(390, 844),
  'large phone 430x932': Size(430, 932),
  'tablet 768x1024': Size(768, 1024),
};

// +8% over the app's 1.1 clamp (Roboto is narrower than Inter in tests).
const _textScale = 1.19;

const _longChild = Child(
  id: '2',
  name: 'Muhammad Abdul-Rahman Al-Farsi Bin Abdullah',
  className: 'Grade 10 - Section Alpha (Evening Batch)',
  sectionName: 'Section A',
);

class _Children implements ChildrenRepository {
  @override
  Future<List<Child>> getChildren({bool refresh = false}) async => const [
    _longChild,
    Child(id: '3', name: 'Irha', className: 'Class 2'),
  ];
}

class _Schedule implements ChildScheduleRepository {
  @override
  Future<ChildSchedule> getBetween(
    String childId,
    DateTime from,
    DateTime to, {
    bool refresh = false,
  }) async {
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    Session s(String id, DateTime d, String start) => Session(
      id: id,
      date: d,
      startTime: start,
      endTime: '23:59',
      classIds: const ['c'],
      subjectIds: const ['1', '2', '3'],
      teacherId: '',
      teachers: const [
        SessionTeacher(
          id: '1',
          name: 'Dr. Muhammad Abdul-Rahman Al-Farsi',
          subjectIds: ['1', '2'],
        ),
        SessionTeacher(id: '2', name: 'Ms. Adnan Ilyas', subjectIds: ['3']),
      ],
    );
    return ChildSchedule(
      sessions: [
        s('live', day, '00:00'),
        s('tomorrow', day.add(const Duration(days: 1)), '09:00'),
        s('yesterday', day.subtract(const Duration(days: 1)), '09:00'),
      ],
      subjects: const [
        Subject(id: '1', name: 'Computer Science & Programming'),
        Subject(id: '2', name: 'English Literature'),
        Subject(id: '3', name: 'Mathematics'),
      ],
      classes: const [
        ClassGroup(id: 'c', name: 'Grade 10 - Section Alpha (Evening Batch)'),
      ],
    );
  }

  @override
  Future<Session?> getById(String childId, String sessionId) async {
    final data = await getBetween(childId, DateTime.now(), DateTime.now());
    return data.sessions.where((x) => x.id == sessionId).firstOrNull;
  }
}

class _Attendance implements ChildAttendanceRepository {
  @override
  Future<List<ChildAttendanceRecord>> getForChild(
    String childId, {
    bool refresh = false,
  }) async => [
    for (var i = 0; i < 12; i++)
      ChildAttendanceRecord(
        childId: childId,
        date: DateTime(2026, 10, 1).add(Duration(days: i)),
        status: ['present', 'late', 'absent', 'unmarked'][i % 4],
        className: 'Grade 10 - Section Alpha (Evening Batch)',
        subjectName: 'Computer Science & Programming',
        startTime: '14:40',
        endTime: '23:40',
        remarks: i == 0 ? 'Arrived ten minutes after the bell rang.' : null,
        occurrenceId: i == 0 ? 'live' : null,
      ),
  ];
}

class _Assignments implements ChildAssignmentsRepository {
  @override
  Future<List<ChildAssignment>> getForChild(
    String childId, {
    bool refresh = false,
  }) async => [
    for (var i = 0; i < 6; i++)
      ChildAssignment(
        id: '$i',
        childId: childId,
        title: 'Chapter ${i + 1} - Algorithms and Flowcharts worksheet (final)',
        description:
            'Solve every question in the worksheet and upload a clear photo '
            'of your work before the deadline. Late work loses marks.',
        deadline: DateTime(2026, 12, 20 + i, 18, 30),
        maxMarks: 100,
        isCompleted: i == 1,
        marks: i == 0 ? 89 : null,
        feedback: i == 0
            ? 'Well done, the explanation of each step was very clear.'
            : null,
        className: 'Grade 10 - Section Alpha (Evening Batch)',
        sessionDate: DateTime(2026, 10, 9),
        occurrenceId: i == 0 ? 'live' : null,
      ),
  ];
}

class _Guardian implements GuardianRepository {
  @override
  Future<GuardianProfile> getProfile({String? childId}) async =>
      const GuardianProfile(
        name: 'Muhammad Abdul-Rahman Al-Farsi Bin Abdullah',
        email:
            'a.very.long.parent.email.address@some-long-school-domain.edu.pk',
        relationship: 'Father',
      );
}

Future<void> _pump(
  WidgetTester tester,
  Size size,
  Widget Function(ChildrenCubit children) screen, {
  bool withHeader = true,
  List<AuthContext>? contexts,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final auth = FakeAuthRepository(
    context: AuthContext.fromJson(fx.parentContext),
    contexts:
        contexts ??
        [
          AuthContext.fromJson(fx.adminContext),
          AuthContext.fromJson(fx.parentContext),
          AuthContext.fromJson(fx.teacherContext),
        ],
  );
  final children = ChildrenCubit(
    repository: _Children(),
    store: InMemoryKeyValueStore(),
    auth: auth,
  );
  addTearDown(children.close);

  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: auth),
        RepositoryProvider<ChildScheduleRepository>.value(value: _Schedule()),
        RepositoryProvider<ChildAttendanceRepository>.value(
          value: _Attendance(),
        ),
        RepositoryProvider<ChildAssignmentsRepository>.value(
          value: _Assignments(),
        ),
        RepositoryProvider<GuardianRepository>.value(value: _Guardian()),
      ],
      child: BlocProvider.value(
        value: children,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(_textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: Column(
              children: [
                if (withHeader) const ChildSwitcherHeader(),
                Expanded(child: ChildGate(builder: (_) => screen(children))),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 150));
  }
}

void _noLayoutErrors(WidgetTester tester, String where) {
  final errors = <Object>[];
  Object? e;
  while ((e = tester.takeException()) != null) {
    errors.add(e!);
  }
  expect(errors, isEmpty, reason: '$where: ${errors.join('\n')}');
}

Future<void> _scroll(WidgetTester tester, double dy) async {
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isEmpty) return;
  for (var i = 0; i < 5; i++) {
    await tester.drag(scrollable.first, Offset(0, dy), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(loadTestFonts);

  for (final entry in _sizes.entries) {
    final label = entry.key;
    final size = entry.value;

    group(label, () {
      testWidgets('home: agenda, month, filters, scrolled', (tester) async {
        await _pump(
          tester,
          size,
          (c) => BlocProvider(
            create: (ctx) => ParentHomeCubit(
              children: c,
              schedule: ctx.read<ChildScheduleRepository>(),
              assignments: ctx.read<ChildAssignmentsRepository>(),
              attendance: ctx.read<ChildAttendanceRepository>(),
            )..load(),
            child: const ParentHomeScreen(),
          ),
        );
        _noLayoutErrors(tester, 'home agenda @ $label');
        await tester.scrollUntilVisible(
          find.text('Schedule Overview'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Schedule Overview'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Progress'),
          -200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Progress'), findsOneWidget);

        await _scroll(tester, -500);
        _noLayoutErrors(tester, 'home agenda scrolled @ $label');
        await _scroll(tester, 500);

        await tester.scrollUntilVisible(
          find.text('Month'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.text('Month'));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 200));
        }
        _noLayoutErrors(tester, 'home month @ $label');
      });

      testWidgets('attendance', (tester) async {
        await _pump(
          tester,
          size,
          (c) => BlocProvider(
            create: (ctx) => ParentAttendanceCubit(
              children: c,
              repository: ctx.read<ChildAttendanceRepository>(),
            )..load(),
            child: const ParentAttendanceScreen(),
          ),
        );
        _noLayoutErrors(tester, 'attendance @ $label');
        await _scroll(tester, -600);
        _noLayoutErrors(tester, 'attendance scrolled @ $label');
      });

      testWidgets('assignments + detail sheet', (tester) async {
        await _pump(
          tester,
          size,
          (c) => BlocProvider(
            create: (ctx) => ParentAssignmentsCubit(
              children: c,
              repository: ctx.read<ChildAssignmentsRepository>(),
            )..load(),
            child: const ParentAssignmentsScreen(),
          ),
        );
        _noLayoutErrors(tester, 'assignments @ $label');
        await _scroll(tester, -600);
        _noLayoutErrors(tester, 'assignments scrolled @ $label');

        await _scroll(tester, 600);
        final card = find.textContaining('Chapter 1 ');
        if (card.evaluate().isNotEmpty) {
          await tester.tap(card.first);
          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 200));
          }
          _noLayoutErrors(tester, 'assignment detail @ $label');
        }
      });

      testWidgets('profile', (tester) async {
        await _pump(
          tester,
          size,
          (c) => BlocProvider(
            create: (ctx) => ParentProfileCubit(
              children: c,
              repository: ctx.read<GuardianRepository>(),
            )..load(),
            child: const ParentProfileScreen(),
          ),
        );
        _noLayoutErrors(tester, 'profile @ $label');
        expect(find.text('Switch role'), findsOneWidget);
      });

      testWidgets('session detail', (tester) async {
        await _pump(
          tester,
          size,
          (c) =>
              ParentSessionDetailScreen(child: _longChild, sessionId: 'live'),
          withHeader: false,
        );
        _noLayoutErrors(tester, 'session detail @ $label');
        await _scroll(tester, -600);
        _noLayoutErrors(tester, 'session detail scrolled @ $label');
      });

      testWidgets('role list with long role names', (tester) async {
        tester.view
          ..physicalSize = size
          ..devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final auth = FakeAuthRepository(
          context: AuthContext.fromJson(fx.parentContext),
          contexts: [
            AuthContext.fromJson({
              ...fx.adminContext,
              'displayName':
                  'Client Administrator — International School of Languages '
                  '& Academic Centre (Evening Campus)',
            }),
            AuthContext.fromJson(fx.parentContext),
            AuthContext.fromJson(fx.teacherContext),
          ],
        );
        await tester.pumpWidget(
          RepositoryProvider<AuthRepository>.value(
            value: auth,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(_textScale)),
                child: child!,
              ),
              home: const RoleSelectionScreen(),
            ),
          ),
        );
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        _noLayoutErrors(tester, 'role list @ $label');
      });
    });
  }

  // ─── Client feedback: a calmer home screen ──────────────────────────
  group('home screen (client feedback)', () {
    Future<void> pumpHome(
      WidgetTester tester, {
      Size? size,

      /// Pins the cubit's clock; the dated fixtures age out of the 30-day
      /// window under the real one.
      DateTime? now,
    }) => _pump(
      tester,
      size ?? const Size(390, 844),
      (c) => BlocProvider(
        create: (ctx) => ParentHomeCubit(
          children: c,
          schedule: ctx.read<ChildScheduleRepository>(),
          assignments: ctx.read<ChildAssignmentsRepository>(),
          attendance: ctx.read<ChildAttendanceRepository>(),
          clock: now == null ? null : () => now,
        )..load(),
        child: const ParentHomeScreen(),
      ),
    );

    testWidgets('header: no "CHILD" label; class shown without the word', (
      tester,
    ) async {
      await pumpHome(tester);
      expect(find.text('CHILD'), findsNothing);
      expect(find.text('Child'), findsNothing);
      // Long class names that do not start with "Class" are kept whole.
      expect(
        find.textContaining('Grade 10 - Section Alpha'),
        findsWidgets,
      );
      // (The live banner legitimately says "Class in progress": only the
      // header is checked.)
      expect(
        find.descendant(
          of: find.byType(ChildSwitcherHeader),
          matching: find.textContaining('Class'),
        ),
        findsNothing,
      );
    });

    testWidgets('progress cards show a percentage and a label, no counts', (
      tester,
    ) async {
      await pumpHome(tester, now: DateTime(2026, 10, 12, 10));
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Attendance'), findsOneWidget);
      expect(find.text('Homework'), findsOneWidget);
      expect(find.text('Avg. score'), findsOneWidget);
      expect(find.textContaining('%'), findsWidgets);
      // The old captions ("7 of 7 classes", "0 of 2 done", "89 / 100 marks").
      expect(find.textContaining(' of '), findsNothing);
      expect(find.textContaining(RegExp(r'\d+ of \d+ classes')), findsNothing);
      expect(find.textContaining('marks'), findsNothing);
      expect(find.textContaining(' done'), findsNothing);
      expect(find.text('No data yet'), findsNothing);
    });

    testWidgets('"Up Coming" replaces "Up next"', (tester) async {
      await pumpHome(tester);
      expect(find.text('Up Coming'), findsOneWidget);
      expect(find.text('Up next'), findsNothing);
    });

    testWidgets('up coming rows show the day once and the time once', (
      tester,
    ) async {
      await pumpHome(tester);
      // Tomorrow's class: "09:00 – 23:59" as the subtitle, "Tomorrow" as the
      // only day label; no date and no second clock time.
      expect(find.text('09:00 – 23:59'), findsOneWidget);
      expect(find.text('Tomorrow'), findsOneWidget);
      expect(find.textContaining('AM'), findsNothing);
      expect(find.textContaining('PM'), findsNothing);
    });

    testWidgets('Up Coming says how many classes it lists', (tester) async {
      await pumpHome(tester);
      expect(
        find.textContaining(RegExp(r'^Next (class|\d+ classes)$')),
        findsOneWidget,
      );
    });

    testWidgets('search is tucked behind an icon, and clears when closed', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.scrollUntilVisible(
        find.text('Schedule Overview'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Search subject or teacher'), findsNothing);

      await tester.tap(find.byIcon(Icons.search_rounded).first);
      await tester.pump();
      expect(find.text('Search subject or teacher'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'mathematics');
      await tester.pump();
      expect(find.byIcon(Icons.close_rounded), findsWidgets);

      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pump();
      expect(find.text('Search subject or teacher'), findsNothing);
    });

    for (final entry in _sizes.entries) {
      testWidgets('no layout errors at ${entry.key}', (tester) async {
        await pumpHome(tester, size: entry.value);
        _noLayoutErrors(tester, 'home ${entry.key}');
        await _scroll(tester, -400);
        _noLayoutErrors(tester, 'home scrolled ${entry.key}');
      });
    }
  });
}
