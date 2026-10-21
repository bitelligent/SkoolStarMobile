import 'package:flutter/widgets.dart';
import 'package:skoolstar_teacher_module/core/speech/dictation_engine.dart';

/// Makes the app's [DictationEngine] available to text inputs. Inputs show
/// no microphone when no scope is present (tests, unsupported platforms).
class DictationScope extends InheritedWidget {
  const DictationScope({
    required this.engine,
    required super.child,
    super.key,
  });

  final DictationEngine? engine;

  static DictationEngine? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<DictationScope>()?.engine;

  @override
  bool updateShouldNotify(DictationScope old) => old.engine != engine;
}
