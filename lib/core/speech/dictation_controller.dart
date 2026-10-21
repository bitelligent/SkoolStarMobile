import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_engine.dart';

enum DictationState {
  idle,

  /// Asking for permission / starting the recogniser.
  starting,
  listening,
}

/// Drives voice dictation into a text field.
///
/// The transcript is written into [text] as the user speaks (partial results
/// replace each other, never pile up) so they can read and fix it before
/// pressing send. Dictation stops by itself on silence, when the user types,
/// or when the app goes to the background.
class DictationController extends ChangeNotifier with WidgetsBindingObserver {
  DictationController({required this.engine, required this.text}) {
    text.addListener(_onTextChanged);
    _observe();
  }

  final DictationEngine engine;
  final TextEditingController text;

  DictationState _state = DictationState.idle;
  DictationState get state => _state;
  bool get isListening => _state == DictationState.listening;
  bool get isBusy => _state != DictationState.idle;

  /// `false` once the device is known to have no recogniser: hide the mic.
  bool _available = true;
  bool get isAvailable => _available;

  /// One-shot explanation for the UI to show; cleared after [takeMessage].
  String? _message;
  String? takeMessage() {
    final m = _message;
    _message = null;
    return m;
  }

  /// Text that was in the field when this utterance started.
  String _base = '';

  /// Guards against reacting to our own writes into [text].
  bool _writing = false;
  bool _disposed = false;
  int _generation = 0;

  Future<void> toggle() async {
    switch (_state) {
      case DictationState.idle:
        await _begin();
      case DictationState.starting:
        break; // a second tap while permission is pending does nothing
      case DictationState.listening:
        await stop();
    }
  }

  Future<void> _begin() async {
    final generation = ++_generation;
    _setState(DictationState.starting);

    final availability = await engine.prepare();
    if (_disposed || generation != _generation) return;
    switch (availability) {
      case DictationAvailability.ready:
        break;
      case DictationAvailability.permissionDenied:
        _message =
            'Allow microphone and speech access in Settings to use voice input.';
        _setState(DictationState.idle);
        return;
      case DictationAvailability.unavailable:
        _available = false;
        _message = "Voice input isn't available on this device.";
        _setState(DictationState.idle);
        return;
    }

    _base = text.text.trim();
    unawaited(HapticFeedback.selectionClick());
    await engine.start(
      DictationSession(
        onWords: (words, {required isFinal}) =>
            _onWords(generation, words, isFinal: isFinal),
        onEnded: () => _onEnded(generation),
        onError: (e) => _onError(generation, e),
      ),
    );
    if (_disposed || generation != _generation) return;
    // onEnded may already have fired for an instant failure.
    if (_state == DictationState.starting) {
      _setState(DictationState.listening);
    }
  }

  Future<void> stop() async {
    if (_state == DictationState.idle) return;
    await engine.stop();
  }

  /// Stops and waits (briefly) for the recogniser's final words to land in
  /// [text], so a message sent right now includes everything that was said.
  Future<void> stopAndSettle({
    Duration timeout = const Duration(milliseconds: 1500),
  }) async {
    if (_state == DictationState.idle) return;
    final settled = Completer<void>();
    void check() {
      if (_state == DictationState.idle && !settled.isCompleted) {
        settled.complete();
      }
    }

    addListener(check);
    await engine.stop();
    await settled.future.timeout(timeout, onTimeout: () {});
    removeListener(check);
  }

  void _onWords(int generation, String words, {required bool isFinal}) {
    if (_disposed || generation != _generation) return;
    if (_state != DictationState.listening) {
      _setState(DictationState.listening);
    }
    final spoken = words.trim();
    _write(_join(_base, spoken));
    if (isFinal && spoken.isNotEmpty) {
      // The next utterance in this session continues after this one.
      _base = _join(_base, spoken);
    }
  }

  void _onEnded(int generation) {
    if (_disposed || generation != _generation) return;
    _setState(DictationState.idle);
  }

  void _onError(int generation, DictationError error) {
    if (_disposed || generation != _generation) return;
    switch (error) {
      case DictationError.permissionDenied:
        _message =
            'Allow microphone and speech access in Settings to use voice input.';
      case DictationError.noSpeech:
        _message = "Didn't catch that. Try again.";
      case DictationError.network:
        _message = 'Voice input needs an internet connection right now.';
      case DictationError.other:
        _message = 'Voice input stopped. Please try again.';
    }
    _setState(DictationState.idle);
  }

  /// Typing while listening ends dictation so the two never fight over the
  /// field.
  void _onTextChanged() {
    if (_writing || _state != DictationState.listening) return;
    if (_state == DictationState.listening) {
      _base = text.text.trim();
      unawaited(engine.cancel());
    }
  }

  void _write(String value) {
    _writing = true;
    text.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _writing = false;
  }

  static String _join(String base, String spoken) {
    if (spoken.isEmpty) return base;
    if (base.isEmpty) return spoken;
    return '$base $spoken';
  }

  void _setState(DictationState s) {
    if (_state == s) return;
    _state = s;
    if (!_disposed) notifyListeners();
  }

  void _observe() {
    try {
      WidgetsBinding.instance.addObserver(this);
    } on Object {
      // No binding (plain unit test).
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _state != DictationState.idle) {
      unawaited(engine.cancel());
      _generation++;
      _setState(DictationState.idle);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    text.removeListener(_onTextChanged);
    try {
      WidgetsBinding.instance.removeObserver(this);
    } on Object {
      // See _observe.
    }
    if (_state != DictationState.idle) unawaited(engine.cancel());
    super.dispose();
  }
}
