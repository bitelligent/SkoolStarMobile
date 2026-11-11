import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/utils/keyboard.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_dropdown.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_session.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/models/user_model.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/live_now_banner.dart';
import 'package:skoolstar_teacher_module/features/profile/cubit/profile_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_subjects_repository.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/feedback_tab.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/homework_tab.dart';

import '../fixtures/fixtures.dart' as fx;
import '../helpers/detail_harness.dart';
import '../helpers/repo_fakes.dart';
import '../helpers/test_fonts.dart';

Homework _hw({int marks = 50}) => Homework(
  id: '1',
  sessionId: 's1',
  classId: '23',
  subjectId: '18',
  title: 'Algebra',
  description: '',
  deadline: DateTime(2030),
  maxMarks: marks,
);

Future<Widget> _tab(
  WidgetTester tester,
  Widget Function(SessionDetailLoaded) tab,
) async {
  final cubit = await buildDetailCubit(RecordingHomeworkRepo([_hw()]));
  addTearDown(cubit.close);
  return RepositoryProvider<FeedbackSubjectsRepository>.value(
    value: FakeFeedbackSubjects(),
    child: MaterialApp(
      home: Scaffold(
        body: BlocProvider.value(
          value: cubit,
          child: BlocBuilder<SessionDetailCubit, SessionDetailState>(
            builder: (_, s) => tab(s as SessionDetailLoaded),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadTestFonts);

  group('role switching', () {
    AuthSession session(List<Map<String, Object?>> contexts) => AuthSession(
      signedIn: true,
      contexts: [for (final c in contexts) AuthContext.fromJson(c)],
    );

    test('one role: nothing to switch to', () {
      expect(session([fx.parentContext]).canSwitchRole, isFalse);
    });

    test('a role the app cannot run does not count', () {
      expect(
        session([fx.adminContext, fx.parentContext]).canSwitchRole,
        isFalse,
      );
    });

    test('teacher + parent can switch', () {
      expect(
        session([fx.teacherContext, fx.parentContext]).canSwitchRole,
        isTrue,
      );
    });
  });

  group('profile Save', () {
    const user = UserModel(
      id: '1',
      firstName: 'A',
      lastName: 'B',
      email: 'a@b.c',
    );
    ProfileLoaded loaded({
      String first = 'A',
      bool password = false,
      String current = '',
      String next = '',
      String confirm = '',
      bool saving = false,
    }) => ProfileLoaded(
      user: user,
      firstNameDraft: first,
      changePasswordEnabled: password,
      currentPasswordDraft: current,
      newPasswordDraft: next,
      confirmPasswordDraft: confirm,
      isSaving: saving,
    );

    test('needs a first name', () {
      expect(loaded().canSave, isTrue);
      expect(loaded(first: '  ').canSave, isFalse);
    });

    test('password change needs all fields, matching', () {
      expect(loaded(password: true).canSave, isFalse);
      expect(
        loaded(password: true, current: 'a', next: 'b', confirm: 'c').canSave,
        isFalse,
      );
      expect(
        loaded(password: true, current: 'a', next: 'b', confirm: 'b').canSave,
        isTrue,
      );
    });

    test(
      'not while saving',
      () => expect(loaded(saving: true).canSave, isFalse),
    );
  });

  testWidgets('live banner uses the brand gradient, not the secondary colour', (
    tester,
  ) async {
    final brand = BrandColors.fromSeeds(
      primary: const Color(0xFF2563EB),
      secondary: const Color(0xFFDC2626), // red
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [brand]),
        home: Scaffold(
          body: LiveNowBanner(
            session: stressSession('s', DateTime.now()),
            subjects: const [Subject(id: '1', name: 'Math')],
            classes: const [ClassGroup(id: '1', name: 'Class 1')],
            onOpen: () {},
          ),
        ),
      ),
    );
    final box = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(LiveNowBanner),
            matching: find.byType(Container),
          )
          .first,
    );
    final gradient = (box.decoration! as BoxDecoration).gradient!;
    expect(gradient, brand.gradient);
    expect(
      (gradient as LinearGradient).colors,
      isNot(contains(const Color(0xFFDC2626))),
    );
    await tester.pump(const Duration(milliseconds: 100));
  });

  group('Assignment review form', () {
    Finder saveButton() => find.byWidgetPredicate(
      (w) => w is PrimaryButton && w.label == 'Save Review',
    );
    bool enabled(WidgetTester t) =>
        t.widget<PrimaryButton>(saveButton()).onPressed != null;

    /// Opens the tab and picks the first student in the Student dropdown.
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 3000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(await _tab(tester, (s) => FeedbackTab(state: s)));
      await tester.pump();
      await tester.tap(find.byType(AppDropdown<String>).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.person_rounded).last);
      await tester.pumpAndSettle();
    }

    testWidgets('review text is required to save', (tester) async {
      await pump(tester);
      expect(enabled(tester), isFalse, reason: 'review is empty');

      final review = find.byType(TextField).last;
      await tester.enterText(review, '   ');
      await tester.pump();
      expect(enabled(tester), isFalse, reason: 'whitespace is empty');

      await tester.enterText(review, 'Good effort');
      await tester.pump();
      expect(enabled(tester), isTrue);
    });

    testWidgets('marks are required and capped at the task maximum', (
      tester,
    ) async {
      await pump(tester);
      final fields = find.byType(TextField);
      final marks = fields.at(fields.evaluate().length - 2);
      await tester.enterText(fields.last, 'Well done');

      await tester.enterText(marks, '');
      await tester.pump();
      expect(find.text('Enter the marks.'), findsOneWidget);
      expect(enabled(tester), isFalse);

      await tester.enterText(marks, '51');
      await tester.pump();
      expect(find.textContaining('Cannot exceed'), findsOneWidget);
      expect(enabled(tester), isFalse);

      await tester.enterText(marks, '50');
      await tester.pump();
      expect(find.textContaining('Cannot exceed'), findsNothing);
      expect(enabled(tester), isTrue);
    });
  });

  testWidgets('homework deadline picker offers no past dates', (tester) async {
    tester.view.physicalSize = const Size(800, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(await _tab(tester, (s) => HomeworkTab(state: s)));
    await tester.pump();
    await tester.tap(find.text('Pick a date'));
    await tester.pumpAndSettle();
    final picker = tester.widget<CalendarDatePicker>(
      find.byType(CalendarDatePicker),
    );
    expect(picker.firstDate, DateUtils.dateOnly(DateTime.now()));
  });

  testWidgets('dismissKeyboard drops focus from the field', (tester) async {
    final node = FocusNode();
    addTearDown(node.dispose);
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (c) {
              ctx = c;
              return TextField(focusNode: node);
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(node.hasFocus, isTrue);
    ctx.dismissKeyboard();
    await tester.pump();
    expect(node.hasFocus, isFalse);
  });
}
