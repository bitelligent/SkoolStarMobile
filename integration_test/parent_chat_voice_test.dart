import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parent chat: live thread opens, mic is offered and usable', (
    tester,
  ) async {
    await launchAndSignIn(
      tester,
      email: parentEmail,
      roleLabel: 'Parent',
      homeMarker: find.text('Progress'),
    );

    await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded).last);
    await pumpUntil(tester, find.text('Search chats'));
    await checkpoint(tester, 'chat_list');

    // 1-to-1 tab, then the first thread.
    await tester.tap(find.textContaining('1 to 1').first);
    await tester.pump(const Duration(seconds: 1));
    final tahir = find.text('Tahir Mughal');
    await pumpUntil(tester, tahir);
    await tester.tap(tahir.first);
    await pumpUntil(tester, find.byIcon(Icons.send_rounded));
    await checkpoint(tester, 'chat_thread');

    // The microphone is offered next to send.
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.mic_none_rounded));
    await tester.pump(const Duration(seconds: 3));
    await checkpoint(tester, 'chat_mic_tapped');

    final listening = find.byIcon(Icons.stop_rounded).evaluate().isNotEmpty;
    final explained = find.byType(SnackBar).evaluate().isNotEmpty;
    // iOS shows its own speech-permission dialog (cannot be tapped from a
    // test); the mic button shows a spinner while it is open.
    final awaitingPermission = find
        .descendant(
          of: find.byType(Tooltip),
          matching: find.byType(CircularProgressIndicator),
        )
        .evaluate()
        .isNotEmpty;
    // ignore: avoid_print
    print(
      'MIC RESULT listening=$listening snackbar=$explained '
      'permissionPrompt=$awaitingPermission',
    );
    // Listening, explained why not, or waiting on the OS prompt: never
    // silently nothing.
    expect(listening || explained || awaitingPermission, isTrue);

    if (listening) {
      await tester.tap(find.byIcon(Icons.stop_rounded));
      await tester.pump(const Duration(seconds: 2));
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    }
  });
}
