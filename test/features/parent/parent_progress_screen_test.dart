import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
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
}
