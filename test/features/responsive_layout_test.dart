import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/repositories/attendance_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/class_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/homework_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/institute_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/session_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/subject_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/auth/view/login_screen.dart';
import 'package:skoolstar_teacher_module/features/dashboard/view/dashboard_screen.dart';
import 'package:skoolstar_teacher_module/features/profile/view/profile_screen.dart';
import 'package:skoolstar_teacher_module/features/schedule/view/schedule_screen.dart';
import 'package:skoolstar_teacher_module/features/session_detail/view/session_detail_screen.dart';

import '../helpers/fakes.dart';
import '../helpers/repo_fakes.dart';
import '../helpers/test_fonts.dart';

/// Phones from small to large, plus a tablet, in logical pixels.
const _sizes = <String, Size>{
  'small phone 320x568': Size(320, 568),
  'phone 360x740': Size(360, 740),
  'iPhone 390x844': Size(390, 844),
  'large phone 430x932': Size(430, 932),
  'tablet 768x1024': Size(768, 1024),
};

/// The app clamps text scale to 0.85-1.15 (see app.dart); test the maximum.
// (+8% over the app's 1.15 clamp to make up for Roboto being narrower than
// Inter in tests; see test_fonts.dart.)
const _textScale = 1.24;

Future<void> _pump(WidgetTester tester, Size size, Widget screen) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final now = DateTime.now();
  await tester.pumpWidget(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: FakeAuthRepository()),
        RepositoryProvider<InstituteRepository>.value(value: FakeInstitutes()),
        RepositoryProvider<UserRepository>.value(value: FakeUsers()),
        RepositoryProvider<SessionRepository>.value(
          value: FakeSessionsRepo([
            stressSession('s1', now, start: '00:00'),
            stressSession('s2', now.add(const Duration(days: 1))),
            stressSession('s3', now.subtract(const Duration(days: 1))),
          ]),
        ),
        RepositoryProvider<ClassRepository>.value(value: FakeClassesRepo()),
        RepositoryProvider<SubjectRepository>.value(value: FakeSubjectsRepo()),
        RepositoryProvider<NotificationsRepository>.value(
          value: FakeNotificationsRepo(),
        ),
        RepositoryProvider<AttendanceRepository>.value(
          value: FakeAttendanceRepo(),
        ),
        RepositoryProvider<HomeworkRepository>.value(value: FakeHomeworkRepo()),
        RepositoryProvider<FeedbackRepository>.value(value: FakeFeedbackRepo()),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(_textScale),
          ),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  // Several frames: data loads asynchronously and some widgets animate
  // forever, so pumpAndSettle would never return.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

/// Fails on any overflow/layout error, naming the screen and size.
void _expectNoLayoutErrors(WidgetTester tester, String where) {
  final errors = <Object>[];
  Object? e;
  while ((e = tester.takeException()) != null) {
    errors.add(e!);
  }
  expect(errors, isEmpty, reason: '$where: ${errors.join('\n')}');
}

Future<void> _scrollToBottom(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isEmpty) return;
  for (var i = 0; i < 6; i++) {
    await tester.drag(
      scrollable.first,
      const Offset(0, -500),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _scrollToTop(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isEmpty) return;
  for (var i = 0; i < 6; i++) {
    await tester.drag(
      scrollable.first,
      const Offset(0, 500),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapIfPresent(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) return;
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first, warnIfMissed: false);
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  setUpAll(loadTestFonts);

  for (final entry in _sizes.entries) {
    final label = entry.key;
    final size = entry.value;

    group(label, () {
      testWidgets('login', (tester) async {
        await _pump(tester, size, const LoginScreen());
        _expectNoLayoutErrors(tester, 'login @ $label');
        expect(find.text('Sign in'), findsWidgets);
      });

      testWidgets('dashboard: agenda and month views', (tester) async {
        await _pump(tester, size, const DashboardScreen());
        _expectNoLayoutErrors(tester, 'dashboard agenda @ $label');
        expect(find.byType(DashboardScreen), findsOneWidget);
        await _scrollToBottom(tester);
        _expectNoLayoutErrors(tester, 'dashboard agenda (scrolled) @ $label');

        await _scrollToTop(tester);
        await _tapIfPresent(tester, find.text('Month'));
        _expectNoLayoutErrors(tester, 'dashboard month @ $label');
        await _scrollToBottom(tester);
        _expectNoLayoutErrors(tester, 'dashboard month (scrolled) @ $label');
      });

      testWidgets('schedule', (tester) async {
        await _pump(tester, size, const ScheduleScreen());
        _expectNoLayoutErrors(tester, 'schedule @ $label');
        expect(find.text('My Schedule'), findsOneWidget);
        await _scrollToBottom(tester);
        _expectNoLayoutErrors(tester, 'schedule (scrolled) @ $label');
      });

      testWidgets('profile: view and edit', (tester) async {
        await _pump(tester, size, const ProfileScreen());
        _expectNoLayoutErrors(tester, 'profile @ $label');

        await _tapIfPresent(tester, find.byIcon(Icons.edit_rounded));
        _expectNoLayoutErrors(tester, 'profile edit @ $label');
      });

      testWidgets('session detail: all four tabs', (tester) async {
        await _pump(tester, size, const SessionDetailScreen(sessionId: 's1'));
        _expectNoLayoutErrors(tester, 'session tab @ $label');

        for (final icon in [
          Icons.rule_rounded,
          Icons.assignment_rounded,
          Icons.reviews_rounded,
        ]) {
          await _tapIfPresent(tester, find.byIcon(icon));
          _expectNoLayoutErrors(tester, 'session tab $icon @ $label');
          await _scrollToBottom(tester);
          _expectNoLayoutErrors(
            tester,
            'session tab $icon (scrolled) @ $label',
          );
          await _scrollToTop(tester);
        }
      });
    });
  }
}
