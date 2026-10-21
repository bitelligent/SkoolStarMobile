import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_engine.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_scope.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/feedback_composer.dart';

import '../../core/speech/fake_dictation_engine.dart';

Widget _host(
  FakeDictationEngine? engine,
  Future<bool> Function(String) onSend,
) => MaterialApp(
  home: DictationScope(
    engine: engine,
    child: Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: FeedbackComposer(onSend: onSend, enabled: true),
      ),
    ),
  ),
);

void main() {
  testWidgets('no mic without a dictation engine', (tester) async {
    await tester.pumpWidget(_host(null, (_) async => true));
    expect(find.byIcon(Icons.mic_none_rounded), findsNothing);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);
  });

  testWidgets('speak, see text, edit, send', (tester) async {
    final engine = FakeDictationEngine();
    final sent = <String>[];
    await tester.pumpWidget(
      _host(engine, (t) async {
        sent.add(t);
        return true;
      }),
    );

    await tester.tap(find.byIcon(Icons.mic_none_rounded));
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    expect(find.text('Listening…'), findsOneWidget);

    engine.say('please send the homework', isFinal: true);
    await tester.pump();
    expect(find.text('please send the homework'), findsOneWidget);

    // Dictation stops by itself; the user can still edit before sending.
    engine.end();
    await tester.pump();
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    expect(sent, ['please send the homework']);
  });

  testWidgets('sending while still listening includes the last words', (
    tester,
  ) async {
    final engine = FakeDictationEngine()..finalOnStop = 'see you tomorrow';
    final sent = <String>[];
    await tester.pumpWidget(
      _host(engine, (t) async {
        sent.add(t);
        return true;
      }),
    );
    await tester.tap(find.byIcon(Icons.mic_none_rounded));
    await tester.pump();
    await tester.pump();
    engine.say('see you');
    await tester.pump();

    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump();
    expect(sent, ['see you tomorrow']);
  });

  testWidgets('refused permission explains itself', (tester) async {
    final engine = FakeDictationEngine()
      ..availability = DictationAvailability.permissionDenied;
    await tester.pumpWidget(_host(engine, (_) async => true));
    await tester.tap(find.byIcon(Icons.mic_none_rounded));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Settings'), findsOneWidget);
    expect(engine.starts, 0);
  });

  testWidgets('a device without a recogniser loses the mic button', (
    tester,
  ) async {
    final engine = FakeDictationEngine()
      ..availability = DictationAvailability.unavailable;
    await tester.pumpWidget(_host(engine, (_) async => true));
    await tester.tap(find.byIcon(Icons.mic_none_rounded));
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.mic_none_rounded), findsNothing);
    expect(find.textContaining("isn't available"), findsOneWidget);
  });

  testWidgets('leaving the screen without using the mic does not throw', (
    tester,
  ) async {
    await tester.pumpWidget(_host(FakeDictationEngine(), (_) async => true));
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    // Remove the composer (as navigating away does).
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving while listening does not throw and stops the engine', (
    tester,
  ) async {
    final engine = FakeDictationEngine();
    await tester.pumpWidget(_host(engine, (_) async => true));
    await tester.tap(find.byIcon(Icons.mic_none_rounded));
    await tester.pump();
    await tester.pump();
    expect(find.byIcon(Icons.stop_rounded), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
    expect(engine.cancels, 1);
  });
}
