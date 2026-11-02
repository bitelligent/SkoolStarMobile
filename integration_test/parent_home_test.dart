import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parent home: progress percentages and up next', (tester) async {
    await launchAndSignIn(
      tester,
      email: parentEmail,
      roleLabel: 'Parent',
      homeMarker: find.text('Progress'),
    );
    await pumpUntil(tester, find.text('Attendance'));
    await checkpoint(tester, 'home_top');

    // Calmer home: labelled percentages only, no counts, no "CHILD" label.
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Homework'), findsOneWidget);
    expect(find.text('Avg. score'), findsOneWidget);
    expect(find.text('View Progress'), findsOneWidget);
    expect(find.text('CHILD'), findsNothing);
    expect(find.textContaining(' of '), findsNothing);
    expect(find.text('Up next'), findsNothing);

    await tester.drag(find.byType(ListView).first, const Offset(0, -380));
    await tester.pump(const Duration(seconds: 1));
    await checkpoint(tester, 'home_scrolled');
  });
}
