import 'dart:developer' as developer;

import 'package:skoolstar_teacher_module/core/network/api_exception.dart';

/// User-safe text for any failure. Typed API errors carry their own message;
/// anything unexpected gets a generic one and is logged, so a bug never
/// leaves a screen stuck on a spinner.
String errorMessage(Object error, [StackTrace? stackTrace]) {
  if (error is ApiException) return error.message;
  developer.log(
    'Unexpected error',
    name: 'App',
    error: error,
    stackTrace: stackTrace,
  );
  return 'Something went wrong. Please try again.';
}
