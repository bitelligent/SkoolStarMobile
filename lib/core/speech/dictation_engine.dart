import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Whether speech recognition can be used right now.
enum DictationAvailability {
  ready,

  /// The user refused (or has not granted) microphone / speech access.
  permissionDenied,

  /// No recognition service on this device (some Android builds ship none).
  unavailable,
}

enum DictationError { permissionDenied, noSpeech, network, other }

/// Callbacks for one listening session.
class DictationSession {
  const DictationSession({
    required this.onWords,
    required this.onEnded,
    required this.onError,
  });

  /// Transcript so far (replaces the previous partial). [isFinal] marks the
  /// last result of an utterance.
  final void Function(String words, {required bool isFinal}) onWords;

  /// The engine stopped listening (user stop, silence, time limit, error).
  final VoidCallback onEnded;
  final void Function(DictationError error) onError;
}

/// Speech-to-text behind an interface so the UI logic is testable and the
/// plugin can be swapped.
abstract interface class DictationEngine {
  /// Initialises the recogniser; asks for permission the first time.
  Future<DictationAvailability> prepare();

  Future<void> start(DictationSession session);

  /// Ends the session and delivers the final transcript.
  Future<void> stop();

  /// Ends the session and discards pending results.
  Future<void> cancel();

  bool get isListening;
}

/// [DictationEngine] on the `speech_to_text` plugin (Apple Speech /
/// Android SpeechRecognizer): the device does the recognition, nothing is
/// sent to the SkoolStar backend.
class SpeechToTextEngine implements DictationEngine {
  SpeechToTextEngine({SpeechToText? speech})
    : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  DictationSession? _session;
  DictationAvailability? _availability;
  Future<DictationAvailability>? _preparing;

  /// A longer pause than a breath, short enough to stop by itself.
  static const _pauseFor = Duration(seconds: 4);
  static const _listenFor = Duration(minutes: 1);

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<DictationAvailability> prepare() {
    if (_availability == DictationAvailability.ready) {
      return Future.value(DictationAvailability.ready);
    }
    return _preparing ??= _init().whenComplete(() => _preparing = null);
  }

  Future<DictationAvailability> _init() async {
    try {
      final ok = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      if (ok) return _availability = DictationAvailability.ready;
      // initialize() is false for both "no service" and "permission refused".
      return await _speech.hasPermission
          ? DictationAvailability.unavailable
          : DictationAvailability.permissionDenied;
    } on Object catch (e) {
      // e.g. MissingPluginException on platforms without the plugin.
      debugPrint('Speech init failed: $e');
      return DictationAvailability.unavailable;
    }
  }

  @override
  Future<void> start(DictationSession session) async {
    _session = session;
    try {
      await _speech.listen(
        onResult: (r) =>
            _session?.onWords(r.recognizedWords, isFinal: r.finalResult),
        listenFor: _listenFor,
        pauseFor: _pauseFor,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          // Dictation mode: punctuation-friendly, tolerant of pauses.
          listenMode: ListenMode.dictation,
          cancelOnError: true,
        ),
      );
    } on Object catch (e) {
      debugPrint('Speech listen failed: $e');
      _session?.onError(DictationError.other);
      _finish();
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _speech.stop();
    } on Object catch (e) {
      debugPrint('Speech stop failed: $e');
    }
  }

  @override
  Future<void> cancel() async {
    final session = _session;
    _session = null; // no more results reach the UI
    try {
      await _speech.cancel();
    } on Object catch (e) {
      debugPrint('Speech cancel failed: $e');
    }
    session?.onEnded();
  }

  void _onStatus(String status) {
    // "done" / "notListening": the recogniser has finished.
    if (status == SpeechToText.doneStatus ||
        status == SpeechToText.notListeningStatus) {
      _finish();
    }
  }

  void _onError(SpeechRecognitionError e) {
    final msg = e.errorMsg;
    final session = _session;
    if (session == null) return;
    if (msg.contains('permission')) {
      session.onError(DictationError.permissionDenied);
    } else if (msg == 'error_no_match' ||
        msg == 'error_speech_timeout' ||
        msg.contains('no_speech')) {
      session.onError(DictationError.noSpeech);
    } else if (msg.contains('network')) {
      session.onError(DictationError.network);
    } else {
      session.onError(DictationError.other);
    }
  }

  void _finish() {
    final session = _session;
    _session = null;
    session?.onEnded();
  }
}
