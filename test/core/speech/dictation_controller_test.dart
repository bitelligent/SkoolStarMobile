import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_controller.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_engine.dart';

import 'fake_dictation_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDictationEngine engine;
  late TextEditingController text;
  late DictationController dictation;

  setUp(() {
    engine = FakeDictationEngine();
    text = TextEditingController();
    dictation = DictationController(engine: engine, text: text);
  });

  tearDown(() {
    dictation.dispose();
    text.dispose();
  });

  Future<void> startListening() async {
    await dictation.toggle();
    expect(dictation.state, DictationState.listening);
  }

  test('tap starts listening; tap again stops', () async {
    await startListening();
    expect(engine.starts, 1);
    await dictation.toggle();
    expect(engine.stops, 1);
    expect(dictation.state, DictationState.idle);
  });

  test('partial results replace each other instead of piling up', () async {
    await startListening();
    engine.say('hello');
    engine.say('hello how');
    engine.say('hello how are you');
    expect(text.text, 'hello how are you');
  });

  test('speech is appended after what was already typed', () async {
    text.text = 'Dear teacher,';
    await startListening();
    engine.say('thank you');
    expect(text.text, 'Dear teacher, thank you');
    engine.say('thank you for the update');
    expect(text.text, 'Dear teacher, thank you for the update');
  });

  test('a final result is kept and the next utterance follows it', () async {
    await startListening();
    engine.say('first sentence', isFinal: true);
    engine.say('second');
    expect(text.text, 'first sentence second');
    engine.say('second sentence', isFinal: true);
    expect(text.text, 'first sentence second sentence');
  });

  test('cursor stays at the end of the transcript', () async {
    await startListening();
    engine.say('hello world');
    expect(text.selection, const TextSelection.collapsed(offset: 11));
  });

  test('typing while listening cancels dictation and keeps the text', () async {
    await startListening();
    engine.say('hello');
    text.text = 'hello there'; // the user edits by hand
    await Future<void>.delayed(Duration.zero);
    expect(engine.cancels, 1);
    expect(dictation.state, DictationState.idle);
    expect(text.text, 'hello there');
    // Late words from the dead session must not overwrite the edit.
    engine.say('ignored');
    expect(text.text, 'hello there');
  });

  test('silence ends the session by itself', () async {
    await startListening();
    engine.say('hello', isFinal: true);
    engine.end();
    expect(dictation.state, DictationState.idle);
    expect(text.text, 'hello');
  });

  test('ending without hearing anything says so, not silence', () async {
    await startListening();
    engine.end(); // no words, no error (e.g. no audio input)
    expect(dictation.state, DictationState.idle);
    expect(dictation.takeMessage(), contains("Didn't catch"));
  });

  test('no "didn\'t catch that" when the user stopped it themselves', () async {
    await startListening();
    await dictation.toggle(); // user taps stop
    expect(dictation.takeMessage(), isNull);
  });

  test('no message when words were heard', () async {
    await startListening();
    engine.say('hello', isFinal: true);
    engine.end();
    expect(dictation.takeMessage(), isNull);
  });

  test('an error is not followed by a second, generic message', () async {
    await startListening();
    engine.fail(DictationError.network);
    engine.end();
    expect(dictation.takeMessage(), contains('internet'));
    expect(dictation.takeMessage(), isNull);
  });

  test('permission refused shows guidance, does not listen', () async {
    engine.availability = DictationAvailability.permissionDenied;
    await dictation.toggle();
    expect(dictation.state, DictationState.idle);
    expect(engine.starts, 0);
    expect(dictation.takeMessage(), contains('Settings'));
    expect(dictation.takeMessage(), isNull); // one-shot
    expect(dictation.isAvailable, isTrue); // they can still grant it later
  });

  test('no recogniser on the device hides the mic', () async {
    engine.availability = DictationAvailability.unavailable;
    await dictation.toggle();
    expect(dictation.isAvailable, isFalse);
    expect(dictation.takeMessage(), contains("isn't available"));
  });

  test('errors map to friendly messages and end the session', () async {
    await startListening();
    engine.fail(DictationError.noSpeech);
    expect(dictation.state, DictationState.idle);
    expect(dictation.takeMessage(), contains("Didn't catch"));

    await startListening();
    engine.fail(DictationError.network);
    expect(dictation.takeMessage(), contains('internet'));

    await startListening();
    engine.fail(DictationError.other);
    expect(dictation.takeMessage(), contains('try again'));
  });

  test('stopAndSettle includes the final words in the field', () async {
    await startListening();
    engine.say('almost');
    engine.finalOnStop = 'almost done';
    await dictation.stopAndSettle();
    expect(text.text, 'almost done');
    expect(dictation.state, DictationState.idle);
  });

  test('stopAndSettle does not hang if the engine never finishes', () async {
    await startListening();
    // An engine whose stop() never ends the session.
    final stuck = _StuckEngine();
    final c = DictationController(engine: stuck, text: TextEditingController());
    await c.toggle();
    final sw = Stopwatch()..start();
    await c.stopAndSettle(timeout: const Duration(milliseconds: 200));
    expect(sw.elapsedMilliseconds, lessThan(1500));
    c.dispose();
  });

  test('going to the background stops listening', () async {
    await startListening();
    dictation.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(engine.cancels, 1);
    expect(dictation.state, DictationState.idle);
  });

  test('results arriving after dispose are ignored (no crash)', () async {
    await startListening();
    final session = engine.session!;
    dictation.dispose();
    session.onWords('late', isFinal: true);
    session.onEnded();
    // Re-create so tearDown can dispose normally.
    dictation = DictationController(engine: engine, text: text);
    expect(text.text, isEmpty);
  });

  test('a second tap while starting does nothing', () async {
    final slow = _SlowPrepareEngine();
    final c = DictationController(engine: slow, text: TextEditingController());
    final first = c.toggle();
    expect(c.state, DictationState.starting);
    await c.toggle(); // ignored
    slow.release();
    await first;
    expect(slow.starts, 1);
    c.dispose();
  });
}

class _StuckEngine extends FakeDictationEngine {
  @override
  Future<void> stop() async => stops++; // never ends the session
}

class _SlowPrepareEngine extends FakeDictationEngine {
  final _gate = Completer0();
  void release() => _gate.complete();

  @override
  Future<DictationAvailability> prepare() async {
    await _gate.future;
    return DictationAvailability.ready;
  }
}

class Completer0 {
  final _c = <void Function()>[];
  bool _done = false;
  Future<void> get future async {
    if (_done) return;
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return future;
  }

  void complete() => _done = true;
}
