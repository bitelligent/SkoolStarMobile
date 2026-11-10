import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_progress.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/exam_results_section.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_screen.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import 'progress_fakes.dart';

Future<void> _pump(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  FakeAtt? att,
  FakeHw? hw,
  FakeProgress? progress,
  FakeFeedbackChat? chat,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final children = ChildrenCubit(
    repository: FakeKids(),
    store: InMemoryKeyValueStore(),
    auth: FakeAuthRepository(context: AuthContext.fromJson(fx.parentContext)),
  );
  addTearDown(children.close);
  final cubit = ParentProgressCubit(
    children: children,
    attendance: att ?? FakeAtt(),
    assignments: hw ?? FakeHw(),
    progress: progress ?? FakeProgress(),
    chat: chat ?? FakeFeedbackChat(),
    clock: () => progressNow,
  );
  addTearDown(cubit.close);

  await tester.pumpWidget(
    MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: children),
          BlocProvider.value(value: cubit),
        ],
        child: const ParentProgressScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await cubit.load();
  await tester.pumpAndSettle();
}

void _noOverflow(WidgetTester tester, String where) {
  final e = tester.takeException();
  expect(e, isNull, reason: 'layout error at $where: $e');
}

void main() {
  testWidgets('shows labelled figures, attention, trend, activity', (
    tester,
  ) async {
    await _pump(tester);
    _noOverflow(tester, 'phone');

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Attendance'), findsWidgets);
    expect(find.text('Homework handed in'), findsOneWidget);
    expect(find.text('Average score'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget); // 3 of 4 classes
    expect(find.text('80%'), findsOneWidget); // 8 of 10 marks
    expect(find.text('3 of 4 classes attended'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Recent activity'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Feedback from Tahir'), findsOneWidget);
    expect(find.text('Reply'), findsWidgets);
    _noOverflow(tester, 'phone scrolled');
  });

  testWidgets('period chips change the report without reloading', (
    tester,
  ) async {
    final att = FakeAtt();
    await _pump(tester, att: att);
    final calls = att.requested.length;

    await tester.tap(find.text('7 days'));
    await tester.pumpAndSettle();
    expect(att.requested.length, calls);
    expect(find.text('Arrows compare vs previous 7 days'), findsOneWidget);

    await tester.ensureVisible(find.text('All time'));
    await tester.tap(find.text('All time'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Arrows compare'), findsNothing);
  });

  testWidgets('weekly chart toggles between attendance and homework', (
    tester,
  ) async {
    await _pump(tester);
    await tester.scrollUntilVisible(
      find.text('Weekly trend'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Weekly trend'), findsOneWidget);
    await tester.tap(find.text('Homework').last);
    await tester.pumpAndSettle();
    _noOverflow(tester, 'toggle');
  });

  testWidgets('nothing to show yet: friendly empty state', (tester) async {
    await _pump(
      tester,
      att: FakeAtt()..records = const [],
      hw: FakeHw()..items = const [],
      chat: FakeFeedbackChat()..noFeedback = true,
    );
    expect(find.text('Nothing to show yet'), findsOneWidget);
    expect(find.text('Talk to the teacher'), findsOneWidget);
    _noOverflow(tester, 'empty');
  });

  testWidgets('partial data shows a notice', (tester) async {
    await _pump(tester, chat: FakeFeedbackChat()..error = Exception('x'));
    expect(find.textContaining('could not be loaded'), findsOneWidget);
    expect(find.text('Attendance'), findsWidgets);
  });

  for (final size in const [Size(320, 568), Size(430, 932), Size(768, 1024)]) {
    testWidgets(
      'no layout errors at ${size.width.toInt()}x${size.height.toInt()}',
      (
        tester,
      ) async {
        await _pump(tester, size: size);
        _noOverflow(tester, 'top');
        for (var i = 0; i < 6; i++) {
          await tester.drag(find.byType(ListView).first, const Offset(0, -400));
          await tester.pump();
          _noOverflow(tester, 'scroll $i');
        }
      },
    );
  }

  group('exam results', () {
    final progress = FakeProgress()
      ..summary = const ChildProgress(
        childId: '3',
        completedAssignments: 6,
        totalAssignments: 8,
        totalResults: 7,
        averageScore: 78.5,
      )
      ..results = [
        for (var i = 1; i <= 7; i++)
          ExamResult(
            examId: '$i',
            examName: 'Exam $i',
            score: i * 10.0,
            remarks: i == 7 ? 'Excellent work' : null,
            createdAt: DateTime(2026, 10, 30 - i),
          ),
      ];

    testWidgets('shows the school\'s totals and the latest results', (
      tester,
    ) async {
      await _pump(tester, progress: progress, size: const Size(390, 3200));
      expect(find.text('Overall (all time)'), findsOneWidget);
      expect(find.text('6/8'), findsOneWidget);
      expect(find.text('78.5'), findsOneWidget);
      expect(find.text('Exam results'), findsOneWidget);
      expect(find.text('Exam 1'), findsOneWidget);
      expect(find.text('Exam 6'), findsNothing, reason: 'only the first five');
      await tester.tap(find.text('Show 2 more'));
      await tester.pumpAndSettle();
      expect(find.text('Exam 7'), findsOneWidget);
      expect(find.text('Excellent work'), findsOneWidget);
      expect(find.text('Show fewer'), findsOneWidget);
      _noOverflow(tester, 'exam results');
    });

    testWidgets('results alone are enough to leave the empty state', (
      tester,
    ) async {
      await _pump(
        tester,
        att: FakeAtt()..records = const [],
        hw: FakeHw()..items = const [],
        chat: FakeFeedbackChat()..noFeedback = true,
        progress: progress,
      );
      expect(find.text('Nothing to show yet'), findsNothing);
      expect(find.text('Exam results'), findsOneWidget);
    });

    testWidgets('no results and no totals keeps the empty state', (
      tester,
    ) async {
      await _pump(
        tester,
        att: FakeAtt()..records = const [],
        hw: FakeHw()..items = const [],
        chat: FakeFeedbackChat()..noFeedback = true,
      );
      expect(find.text('Nothing to show yet'), findsOneWidget);
      expect(find.text('Exam results'), findsNothing);
    });

    test('scores print without a trailing .0', () {
      expect(formatScore(82), '82');
      expect(formatScore(82.0), '82');
      expect(formatScore(78.5), '78.5');
      expect(formatScore(78.25), '78.3');
    });
  });
}
