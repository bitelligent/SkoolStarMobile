import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_dropdown.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_selectable_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_subjects_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_subjects_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/feedback_subject_picker.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/new_feedback_sheet.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/feedback_tab.dart';

import '../helpers/detail_harness.dart';
import '../helpers/repo_fakes.dart';
import '../helpers/test_fonts.dart';

Widget _host(FeedbackSubjectsRepository repo, Widget child) =>
    RepositoryProvider<FeedbackSubjectsRepository>.value(
      value: repo,
      child: MaterialApp(home: Scaffold(body: child)),
    );

void main() {
  setUpAll(loadTestFonts);

  group('FeedbackSubjectsCubit', () {
    test('nobody selected: nothing is requested', () async {
      final repo = FakeFeedbackSubjects();
      final cubit = FeedbackSubjectsCubit(repo);
      await cubit.load(const []);
      expect(repo.calls, isEmpty);
      expect(cubit.state.subjects, isEmpty);
      expect(cubit.state.failed, isFalse);
      await cubit.close();
    });

    test('loads, fails, and retries', () async {
      final repo = FakeFeedbackSubjects({
        '1': ['Maths', 'English'],
      })..error = const NetworkException();
      final cubit = FeedbackSubjectsCubit(repo);
      await cubit.load(['1']);
      expect(cubit.state.failed, isTrue);
      repo.error = null;
      await cubit.retry();
      expect(cubit.state.subjects.map((s) => s.name), ['English', 'Maths']);
      expect(cubit.state.failed, isFalse);
      await cubit.close();
    });

    test('an answer for the previous recipients is dropped', () async {
      final slow = _SlowRepo();
      final cubit = FeedbackSubjectsCubit(slow);
      final first = cubit.load(['1']); // held
      await Future<void>.delayed(Duration.zero);
      await cubit.load(['2']);
      expect(cubit.state.subjects.single.name, 'Two');
      slow.gate.complete();
      await first;
      expect(cubit.state.subjects.single.name, 'Two');
      await cubit.close();
    });
  });

  group('FeedbackSubjectPicker', () {
    Future<void> pump(
      WidgetTester tester,
      FakeFeedbackSubjects repo, {
      required List<String> ids,
      String? value,
      required ValueChanged<String?> onChanged,
    }) async {
      await tester.pumpWidget(
        _host(
          repo,
          FeedbackSubjectPicker(
            studentIds: ids,
            value: value,
            onChanged: onChanged,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('asks to pick a recipient first', (tester) async {
      await pump(tester, FakeFeedbackSubjects(), ids: [], onChanged: (_) {});
      expect(find.text('Subject (optional)'), findsOneWidget);
      expect(
        find.text('Select a recipient to choose a subject.'),
        findsOneWidget,
      );
      expect(find.byType(AppDropdown<String>), findsNothing);
    });

    testWidgets('lists "none" first, then subjects, and reports the pick', (
      tester,
    ) async {
      String? picked = 'untouched';
      await pump(
        tester,
        FakeFeedbackSubjects({
          '1': ['Maths', 'English'],
        }),
        ids: ['1'],
        onChanged: (v) => picked = v,
      );
      expect(find.text('No subject'), findsOneWidget);
      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Maths'), findsOneWidget);
      await tester.tap(find.text('Maths'));
      await tester.pumpAndSettle();
      expect(picked, 'Maths');
    });

    testWidgets('choosing "none" clears the subject', (tester) async {
      String? picked = 'Maths';
      await pump(
        tester,
        FakeFeedbackSubjects({
          '1': ['Maths'],
        }),
        ids: ['1'],
        value: 'Maths',
        onChanged: (v) => picked = v,
      );
      await tester.tap(find.byType(AppDropdown<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No subject'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
    });

    testWidgets('a pick that stops applying is cleared', (tester) async {
      final repo = FakeFeedbackSubjects({
        '1': ['Maths', 'English'],
        '2': ['English'],
      });
      String? value = 'Maths';
      var ids = ['1'];
      late StateSetter set;
      await tester.pumpWidget(
        _host(
          repo,
          StatefulBuilder(
            builder: (context, setState) {
              set = setState;
              return FeedbackSubjectPicker(
                studentIds: ids,
                value: value,
                onChanged: (v) => set(() => value = v),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(value, 'Maths');
      set(() => ids = ['1', '2']); // student 2 does not study Maths
      await tester.pumpAndSettle();
      expect(value, isNull);
      expect(repo.calls.last, ['1', '2']);
    });

    testWidgets('no shared subject is explained, not an empty list', (
      tester,
    ) async {
      await pump(
        tester,
        FakeFeedbackSubjects({
          '1': ['Maths'],
          '2': ['Art'],
        }),
        ids: ['1', '2'],
        onChanged: (_) {},
      );
      expect(
        find.text('No common subject for the selected students.'),
        findsOneWidget,
      );
    });

    testWidgets('a failure offers Retry', (tester) async {
      final repo = FakeFeedbackSubjects({
        '1': ['Maths'],
      })..error = const NetworkException();
      await pump(tester, repo, ids: ['1'], onChanged: (_) {});
      expect(find.text(const NetworkException().message), findsOneWidget);
      repo.error = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDropdown<String>), findsOneWidget);
    });
  });

  group('New feedback sheet', () {
    Future<NewFeedbackDraft?> open(
      WidgetTester tester,
      FakeFeedbackSubjects repo, {
      required Future<void> Function() interact,
    }) async {
      NewFeedbackDraft? result;
      var done = false;
      await tester.pumpWidget(
        _host(
          repo,
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showNewFeedbackSheet(
                  context,
                  parentName: 'Muhammad',
                  studentId: '7',
                );
                done = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await interact();
      await tester.pumpAndSettle();
      expect(done, isTrue);
      return result;
    }

    testWidgets('sends without a subject by default', (tester) async {
      final draft = await open(
        tester,
        FakeFeedbackSubjects({
          '7': ['Maths'],
        }),
        interact: () async {
          expect(find.text('General feedback'), findsOneWidget);
          await tester.enterText(find.byType(TextField), 'Good week');
          await tester.pump();
          await tester.tap(find.widgetWithText(PrimaryButton, 'Send feedback'));
        },
      );
      expect(draft!.subject, isNull);
      expect(draft.message, 'Good week');
      expect(draft.tone, FeedbackTone.positive);
    });

    testWidgets('sends the chosen subject name', (tester) async {
      final draft = await open(
        tester,
        FakeFeedbackSubjects({
          '7': ['Maths', 'English'],
        }),
        interact: () async {
          await tester.tap(find.byType(AppDropdown<String>));
          await tester.pumpAndSettle();
          await tester.tap(find.text('English'));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField), 'Read more');
          await tester.pump();
          await tester.tap(find.widgetWithText(PrimaryButton, 'Send feedback'));
        },
      );
      expect(draft!.subject, 'English');
    });

    testWidgets('a failed subject list never blocks sending', (tester) async {
      final draft = await open(
        tester,
        FakeFeedbackSubjects()..error = const NetworkException(),
        interact: () async {
          expect(find.text(const NetworkException().message), findsOneWidget);
          await tester.enterText(find.byType(TextField), 'Still works');
          await tester.pump();
          await tester.tap(find.widgetWithText(PrimaryButton, 'Send feedback'));
        },
      );
      expect(draft!.subject, isNull);
      expect(draft.message, 'Still works');
    });

    testWidgets('the message is still required', (tester) async {
      await tester.pumpWidget(
        _host(
          FakeFeedbackSubjects(),
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showNewFeedbackSheet(
                context,
                parentName: 'M',
                studentId: '7',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final button = tester.widget<PrimaryButton>(
        find.widgetWithText(PrimaryButton, 'Send feedback'),
      );
      expect(button.onPressed, isNull);
    });
  });

  group('Session feedback tab', () {
    testWidgets('subject follows the selected recipients', (tester) async {
      tester.view
        ..physicalSize = const Size(800, 3000)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final cubit = await buildDetailCubit(RecordingHomeworkRepo(const []));
      addTearDown(cubit.close);
      final student = (cubit.state as SessionDetailLoaded).students.first;
      final repo = FakeFeedbackSubjects({
        student.id: ['Computer'],
      });
      await tester.pumpWidget(
        _host(
          repo,
          BlocProvider.value(
            value: cubit,
            child: BlocBuilder<SessionDetailCubit, SessionDetailState>(
              builder: (_, s) => FeedbackTab(state: s as SessionDetailLoaded),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Select a recipient to choose a subject.'),
        findsOneWidget,
      );

      await tester.tap(find.byType(AppSelectableTile).first);
      await tester.pumpAndSettle();
      expect(repo.calls.last, [student.id]);
      expect(find.text("This lesson's subject"), findsOneWidget);

      // Deselecting again returns to the prompt.
      await tester.tap(find.byType(AppSelectableTile).first);
      await tester.pumpAndSettle();
      expect(
        find.text('Select a recipient to choose a subject.'),
        findsOneWidget,
      );
    });
  });
}

class _SlowRepo implements FeedbackSubjectsRepository {
  final gate = Completer<void>();

  @override
  Future<List<Subject>> commonFor(Iterable<String> studentIds) async {
    if (studentIds.first == '1') await gate.future;
    return [
      Subject(
        id: studentIds.first,
        name: studentIds.first == '1' ? 'One' : 'Two',
      ),
    ];
  }
}
