import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parent progress: figures, attention, activity, reply link', (
    tester,
  ) async {
    await launchAndSignIn(
      tester,
      email: parentEmail,
      roleLabel: 'Parent',
      homeMarker: find.text('Progress'),
    );
    await pumpUntil(tester, find.text('Attendance'));

    // Open the full report from the home progress header.
    await tester.tap(find.text('View Progress'));
    await pumpUntil(tester, find.text('Homework handed in'));
    await checkpoint(tester, 'progress_top');

    expect(find.text('Average score'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);

    // The report's vertical list (the period chips scroll sideways).
    final list = find.byType(ListView).last;
    final listScroll = find
        .descendant(of: list, matching: find.byType(Scrollable))
        .first;
    await tester.drag(list, const Offset(0, -650));
    await tester.pump(const Duration(seconds: 1));
    await checkpoint(tester, 'progress_mid');

    await tester.drag(list, const Offset(0, -700));
    await tester.pump(const Duration(seconds: 1));
    await checkpoint(tester, 'progress_activity');

    // Switch period.
    await tester.drag(list, const Offset(0, 3000));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('All time'));
    await tester.pump(const Duration(seconds: 1));
    await checkpoint(tester, 'progress_all_time');

    // Follow a feedback row into the teacher thread.
    // (Whatever feedback the live data has: teacher or "You replied".)
    final rows = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          ((w.data ?? '').startsWith('Feedback from') ||
              w.data == 'You replied'),
    );
    await tester.scrollUntilVisible(
      find.text('Recent activity'),
      250,
      scrollable: listScroll,
    );
    await tester.drag(listScroll, const Offset(0, -250));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(rows.first);
    // We left the report for the teacher's feedback thread.
    final end = DateTime.now().add(const Duration(seconds: 30));
    while (find.text('Progress').evaluate().isNotEmpty) {
      if (DateTime.now().isAfter(end)) fail('Reply did not open the chat');
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pump(const Duration(seconds: 2));
    await checkpoint(tester, 'progress_reply_opens_chat');
  });
}
