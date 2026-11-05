import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skoolstar_teacher_module/features/dashboard/widgets/session_card.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('teacher: QA polish round', (tester) async {
    await launchAndSignIn(
      tester,
      email: teacherEmail,
      roleLabel: 'Teacher',
      homeMarker: find.text('Schedule Overview'),
    );
    await checkpoint(tester, 't_home');

    // Teacher has a single role: no "Switch role" in the profile.
    await tester.tap(find.byIcon(Icons.person_outline_rounded).last);
    await pumpUntil(tester, find.text('My Profile'));
    expect(find.text('Switch role'), findsNothing);
    expect(find.text('Notifications'), findsNothing);
    await checkpoint(tester, 't_profile');
    await tester.tap(find.byIcon(Icons.home_outlined).last);
    await tester.pump(const Duration(seconds: 1));

    // Today is empty for this teacher: widen to the whole month.
    await tester.tap(find.text('Today').last);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('All days').last);
    await tester.pump(const Duration(seconds: 1));

    // Open a session.
    final card = find.byType(SessionCard);
    await pumpUntil(tester, card);
    await checkpoint(tester, 't_list');
    await tester.tap(card.first);
    await tester.pump(const Duration(seconds: 3));
    await checkpoint(tester, 't_after_tap');
    await checkpoint(tester, 't_session');

    // Chat icon on the learner row.
    final chat = find.byIcon(Icons.chat_bubble_outline_rounded);
    await pumpUntil(tester, chat);
    await tester.tap(chat.first);
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    await checkpoint(tester, 't_chat_opened');
    final sheet = find.text('Send feedback').evaluate().isNotEmpty;
    final thread =
        find.byIcon(Icons.send_rounded).evaluate().isNotEmpty ||
        find.text('New feedback').evaluate().isNotEmpty;
    // ignore: avoid_print
    print('CHAT RESULT sheet=$sheet thread=$thread');
    expect(sheet || thread, isTrue);
  });
}
