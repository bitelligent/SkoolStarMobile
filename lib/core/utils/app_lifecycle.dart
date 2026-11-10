import 'package:flutter/widgets.dart';

/// Whether the app is in the foreground. Background timers use this to stay
/// quiet. Treats "unknown" (no binding yet, as in plain unit tests) as
/// foreground so work is never silently skipped.
bool get isAppInForeground {
  try {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  } on Object {
    return true;
  }
}
