import 'package:skoolstar_teacher_module/core/speech/dictation_engine.dart';

/// Scriptable recogniser: tests push words / errors as if the user spoke.
class FakeDictationEngine implements DictationEngine {
  DictationAvailability availability = DictationAvailability.ready;
  DictationSession? session;
  int prepares = 0;
  int starts = 0;
  int stops = 0;
  int cancels = 0;
  bool _listening = false;

  /// What `stop()` delivers as the final transcript before ending.
  String? finalOnStop;

  @override
  bool get isListening => _listening;

  @override
  Future<DictationAvailability> prepare() async {
    prepares++;
    return availability;
  }

  @override
  Future<void> start(DictationSession s) async {
    starts++;
    session = s;
    _listening = true;
  }

  @override
  Future<void> stop() async {
    stops++;
    final s = session;
    if (finalOnStop != null) s?.onWords(finalOnStop!, isFinal: true);
    end();
  }

  @override
  Future<void> cancel() async {
    cancels++;
    final s = session;
    session = null;
    _listening = false;
    s?.onEnded();
  }

  // ── test controls ──
  void say(String words, {bool isFinal = false}) =>
      session?.onWords(words, isFinal: isFinal);

  void end() {
    final s = session;
    session = null;
    _listening = false;
    s?.onEnded();
  }

  void fail(DictationError e) => session?.onError(e);
}
