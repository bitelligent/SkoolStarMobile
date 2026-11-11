import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/core/utils/attachment_picker.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/assignment_submission_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/parent_assignments_screen.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';
import 'package:skoolstar_teacher_module/features/parent/progress/parent_progress_cubit.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import '../../helpers/test_fonts.dart';
import 'hand_in_fakes.dart';
import 'progress_fakes.dart';

ChildAssignment _hw(
  String id, {
  bool done = false,
  int? marks,
  int daysAgo = 2,
}) => ChildAssignment(
  id: id,
  childId: '3',
  title: 'Homework $id',
  deadline: progressNow.subtract(Duration(days: daysAgo)),
  isCompleted: done,
  marks: marks,
  completedAt: done ? progressNow : null,
  feedback: done && marks == null ? 'my note' : null,
);

void main() {
  setUpAll(loadTestFonts);

  late FakeHw hw;
  late FakeSubmissionRepo repo;
  late FakePicker picker;
  late ChildrenCubit children;

  setUp(() async {
    hw = FakeHw()
      ..items = [
        _hw('open'),
        _hw('graded', marks: 9),
        _hw('done', done: true),
      ];
    repo = FakeSubmissionRepo();
    picker = FakePicker();
    children = ChildrenCubit(
      repository: FakeKids(),
      store: InMemoryKeyValueStore(),
      auth: FakeAuthRepository(
        context: AuthContext.fromJson(fx.parentContext),
      ),
    );
    await children.stream.firstWhere((s) => s is ChildrenLoaded);
  });

  Future<ParentAssignmentsCubit> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late ParentAssignmentsCubit cubit;
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AssignmentSubmissionRepository>.value(value: repo),
          RepositoryProvider<AttachmentPicker>.value(value: picker),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: BlocProvider(
              create: (_) => cubit = ParentAssignmentsCubit(
                children: children,
                repository: hw,
                clock: () => progressNow,
              )..load(),
              child: const ParentAssignmentsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Closing awaits real async work, which a widget test's clock never runs.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(children.close);
    });
    return cubit;
  }

  testWidgets('"Hand in" is offered until it is handed in (graded work too)', (
    tester,
  ) async {
    await pump(tester);
    // open + graded-without-hand-in; not the completed one.
    expect(find.widgetWithText(FilledButton, 'Hand in'), findsNWidgets(2));
  });

  testWidgets('handing in from the card updates the list at once', (
    tester,
  ) async {
    final cubit = await pump(tester);
    expect(cubit.counts().completed, 1);

    await tester.tap(find.widgetWithText(FilledButton, 'Hand in').first);
    await tester.pumpAndSettle();
    expect(find.text('Hand in homework'), findsOneWidget);
    await tester.tap(find.text('Hand in').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Hand in'));
    await tester.pumpAndSettle();

    expect(repo.submits.single.taskId, 'open');
    expect(repo.submits.single.childId, '3');
    expect(find.text('Homework handed in.'), findsOneWidget);
    expect(cubit.counts().completed, 2);
    expect(cubit.counts().pending, 0);
    expect(find.widgetWithText(FilledButton, 'Hand in'), findsOneWidget);
  });

  testWidgets('cancelling the sheet leaves the list untouched', (tester) async {
    final cubit = await pump(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Hand in').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(repo.submits, isEmpty);
    expect(cubit.counts().completed, 1);
    expect(find.text('Homework handed in.'), findsNothing);
  });

  testWidgets('the detail sheet offers it too and then closes itself', (
    tester,
  ) async {
    final cubit = await pump(tester);
    await tester.tap(find.text('Homework open'));
    await tester.pumpAndSettle();
    expect(find.text('Hand in homework'), findsOneWidget); // detail button
    await tester.tap(find.text('Hand in homework'));
    await tester.pumpAndSettle();
    // Detail closed, hand-in sheet open.
    expect(find.text('Hand in homework'), findsOneWidget);
    expect(find.text('Note (optional)'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(cubit.counts().completed, 1);
  });

  testWidgets('a handed-in task has no button in its detail', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Homework done'));
    await tester.pumpAndSettle();
    expect(find.text('Hand in homework'), findsNothing);
  });

  testWidgets('the shared field reads "Note" until the teacher grades it', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Homework done'));
    await tester.pumpAndSettle();
    expect(find.text('Note'), findsOneWidget);
    expect(find.text("Teacher's feedback"), findsNothing);
  });

  group('markHandedIn', () {
    test('only touches the named task, and only once loaded', () async {
      final cubit = ParentAssignmentsCubit(
        children: children,
        repository: hw,
        clock: () => progressNow,
      );
      cubit.markHandedIn('open', progressNow); // not loaded: no-op
      expect(cubit.state, isA<ParentAssignmentsInitial>());
      await cubit.load();
      cubit.markHandedIn('nope', progressNow);
      expect(cubit.counts().completed, 1);
      cubit.markHandedIn('graded', progressNow);
      final s = cubit.state as ParentAssignmentsLoaded;
      expect(s.items.firstWhere((a) => a.id == 'graded').isCompleted, isTrue);
      expect(s.items.firstWhere((a) => a.id == 'open').isCompleted, isFalse);
      await cubit.close();
      await children.close();
    });
  });

  group('progress screen follows a hand-in', () {
    test('figures update without a spinner', () async {
      final handedIn = StreamController<String>.broadcast();
      final cubit = ParentProgressCubit(
        children: children,
        attendance: FakeAtt(),
        assignments: hw,
        progress: FakeProgress(),
        chat: FakeFeedbackChat(),
        handedIn: handedIn.stream,
        clock: () => progressNow,
      );
      await cubit.load();
      var s = cubit.state as ParentProgressLoaded;
      expect(s.assignments.where((a) => a.isCompleted), hasLength(1));

      final states = <ParentProgressState>[];
      final sub = cubit.stream.listen(states.add);
      hw.items = [
        _hw('open', done: true),
        _hw('graded', marks: 9),
        _hw('done', done: true),
      ];

      handedIn.add('999'); // another child
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(states, isEmpty);

      handedIn.add('3');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      s = cubit.state as ParentProgressLoaded;
      expect(s.assignments.where((a) => a.isCompleted), hasLength(2));
      expect(states.any((x) => x is ParentProgressLoading), isFalse);

      await sub.cancel();
      await cubit.close();
      await handedIn.close();
      await children.close();
    });

    test('a failing refresh keeps what is shown', () async {
      final handedIn = StreamController<String>.broadcast();
      final cubit = ParentProgressCubit(
        children: children,
        attendance: FakeAtt(),
        assignments: hw,
        progress: FakeProgress(),
        chat: FakeFeedbackChat(),
        handedIn: handedIn.stream,
        clock: () => progressNow,
      );
      await cubit.load();
      hw.error = Exception('offline');
      handedIn.add('3');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      // Both essential sources are not lost together, so the screen stays
      // loaded; nothing throws.
      expect(cubit.state, isA<ParentProgressLoaded>());
      await cubit.close();
      await handedIn.close();
      await children.close();
    });
  });
}
