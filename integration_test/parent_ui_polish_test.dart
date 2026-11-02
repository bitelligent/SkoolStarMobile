import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parent: QA polish round', (tester) async {
    await launchAndSignIn(
      tester,
      email: parentEmail,
      roleLabel: 'Parent',
      homeMarker: find.text('Progress'),
    );
    await checkpoint(tester, 'home');
    expect(find.text('Last 30 days'), findsNothing);

    // Homework card → Assignments tab; Attendance card → Attendance tab.
    await tester.tap(find.text('Homework'));
    await pumpUntil(tester, find.textContaining('Homework and tasks for'));
    await checkpoint(tester, 'assignments_tab');
    // Filter highlight: no "Showing …" chip.
    await tester.tap(find.text('Completed'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Showing'), findsNothing);
    await checkpoint(tester, 'assignments_filtered');

    await tester.tap(find.byIcon(Icons.home_outlined).last);
    await pumpUntil(tester, find.text('View Progress'));
    await tester.tap(find.text('Attendance').first);
    await pumpUntil(tester, find.textContaining('Session attendance for'));
    await tester.tap(find.text('Late'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('Showing'), findsNothing);
    await checkpoint(tester, 'attendance_filtered');

    // Chat search with the keyboard open + clear button.
    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded).last);
    await pumpUntil(tester, find.text('Search chats'));
    await tester.tap(find.byType(TextField).first);
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump(const Duration(seconds: 1));
    await checkpoint(tester, 'chat_search_keyboard');
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('zzz'), findsNothing);

    // This account's other role (admin) has no mobile module, so there is
    // nothing to switch to; notifications live behind the bell.
    await tester.tap(find.byIcon(Icons.person_outline_rounded).last);
    await pumpUntil(tester, find.text('My Profile'));
    expect(find.text('Switch role'), findsNothing);
    expect(find.text('Notifications'), findsNothing);
    await checkpoint(tester, 'parent_profile');
  });
}
