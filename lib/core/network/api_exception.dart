/// Typed failures thrown by `ApiClient`. Repositories let them propagate;
/// cubits `catch (e) on ApiException` and map to UI state via [message].
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Safe-to-display, human readable description.
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// No connectivity / DNS / connection refused.
class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

class ApiTimeoutException extends ApiException {
  const ApiTimeoutException([
    super.message = 'The request timed out. Please try again.',
  ]);
}

/// 400 / 422. [fieldErrors] holds per-field messages when the server sends
/// a ValidationProblemDetails body.
class ValidationException extends ApiException {
  const ValidationException(
    super.message, {
    super.statusCode,
    this.fieldErrors = const {},
  });

  final Map<String, List<String>> fieldErrors;
}

/// 401 – missing/expired credentials (after any refresh attempt failed) or
/// wrong email/password on the login call.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Your session has expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException([
    super.message = 'You do not have permission to do that.',
  ]) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException([super.message = 'Not found.'])
    : super(statusCode: 404);
}

class ServerException extends ApiException {
  const ServerException([
    super.message = 'Something went wrong on our side. Please try later.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// 2xx response whose body was not the JSON shape we expected.
class ParseException extends ApiException {
  const ParseException([
    super.message = 'Received an unexpected response from the server.',
  ]);
}

/// Any other non-2xx status.
class UnknownApiException extends ApiException {
  const UnknownApiException(super.message, {super.statusCode});
}
