import 'package:flutter/widgets.dart';

extension KeyboardContext on BuildContext {
  /// Closes the on-screen keyboard and drops focus from whatever field has it,
  /// so a submitted form does not leave a caret (or the keyboard) behind.
  void dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
}
