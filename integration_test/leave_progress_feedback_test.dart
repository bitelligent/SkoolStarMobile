import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/session_card.dart';

import 'support.dart';

/// Read-only against the live backend: nothing is submitted, so no admin or
/// parent is notified.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parent: leave requests and progress results', (tester) async {
    await launchAndSignIn(
      tester,
      email: parentEmail,
      roleLabel: 'Parent',
      homeMarker: find.text('Progress'),
    );

    // Attendance tab offers a shortcut to the leave screen.
    await tester.tap(find.text('Attendance').first);
    await pumpUntil(tester, find.textContaining('Session attendance for'));
    expect(find.text('Request leave'), findsOneWidget);
    await checkpoint(tester, 'attendance_request_leave');

    // Profile → Leave requests.
    await tester.tap(find.byIcon(Icons.person_outline_rounded).last);
    await pumpUntil(tester, find.text('My Profile'));
    await checkpoint(tester, 'profile_leave_row');
    await tester.tap(find.text('Leave requests'));
    await pumpUntil(tester, find.byType(FloatingActionButton));
    await checkpoint(tester, 'leave_list');

    // The form: submit stays disabled until there is a reason. Not sent.
    await tester.tap(find.byType(FloatingActionButton));
    await pumpUntil(tester, find.text('Submit request'));
    await checkpoint(tester, 'leave_form');
    await tester.enterText(find.byType(TextField).last, 'Family travel');
    await tester.pump(const Duration(milliseconds: 500));
    FocusManager.instance.primaryFocus?.unfocus();
    await checkpoint(tester, 'leave_form_filled');
    await tester.tap(find.byIcon(Icons.close_rounded).last);
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pump(const Duration(seconds: 1));

    // Progress: exam results come from the new endpoints.
    await tester.tap(find.byIcon(Icons.home_outlined).last);
    await pumpUntil(tester, find.text('View Progress'));
    await tester.tap(find.text('View Progress'));
    await pumpUntil(tester, find.text('Progress').last);
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    final results = find.text('Exam results');
    final overall = find.text('Overall (all time)');
    for (var i = 0; i < 8 && overall.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -450));
      await tester.pump(const Duration(milliseconds: 400));
    }
    // ignore: avoid_print
    print(
      'PROGRESS overall=${overall.evaluate().isNotEmpty} '
      'results=${results.evaluate().isNotEmpty}',
    );
    await checkpoint(tester, 'progress_exam_section');
    expect(tester.takeException(), isNull);
  });

  testWidgets('teacher: feedback subject picker', (tester) async {
    await launchAndSignIn(
      tester,
      email: teacherEmail,
      roleLabel: 'Teacher',
      homeMarker: find.text('Schedule Overview'),
    );
    await tester.tap(find.text('Today').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('All days').last);
    await tester.pump(const Duration(seconds: 1));
    final card = find.byType(SessionCard);
    await pumpUntil(tester, card);
    await tester.tap(card.first);
    await tester.pump(const Duration(seconds: 3));

    // Chat icon of a learner → thread (or the new-feedback sheet directly).
    final chat = find.byIcon(Icons.chat_bubble_outline_rounded);
    await pumpUntil(tester, chat);
    await tester.tap(chat.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    if (find.text('Subject (optional)').evaluate().isEmpty) {
      await tester.tap(find.text('New feedback').last);
      await pumpUntil(tester, find.text('Subject (optional)'));
    }
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    final loading = find.text('Loading subjects…').evaluate().isNotEmpty;
    final failed = find.text('Could not load subjects.').evaluate().isNotEmpty;
    final none = find
        .text('No common subject for the selected students.')
        .evaluate()
        .isNotEmpty;
    // ignore: avoid_print
    print('SUBJECTS loading=$loading failed=$failed noCommon=$none');
    await checkpoint(tester, 'subject_picker');
    expect(loading, isFalse);
    expect(failed, isFalse);
    expect(tester.takeException(), isNull);
  });
}
