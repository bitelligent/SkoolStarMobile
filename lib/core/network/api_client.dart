import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:skoolstar_teacher_module/core/config/app_config.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/api_logger.dart';

/// Supplies the current bearer token (or null when signed out).
typedef AccessTokenProvider = FutureOr<String?> Function();

/// Called once when an authenticated request gets a 401. Return `true` if
/// the token was refreshed and the request should be retried, `false` to
/// surface [UnauthorizedException]. Implementations must de-duplicate
/// concurrent refreshes themselves.
typedef UnauthorizedHandler = Future<bool> Function();

/// Thin wrapper around `package:http` that centralises base URL, auth header,
/// JSON encoding, timeouts, 401-refresh-retry, logging and error mapping.
///
/// Methods return the decoded JSON body (`Map`, `List`, or `null` for empty
/// bodies) and throw an [ApiException] on any failure.
class ApiClient {
  ApiClient({
    String baseUrl = AppConfig.apiBaseUrl,
    http.Client? httpClient,
    this.accessToken,
    this.onUnauthorized,
    this.timeout = AppConfig.requestTimeout,
    this.logger = const ApiLogger(),
  }) : _baseUrl = baseUrl,
       _client = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _client;
  final AccessTokenProvider? accessToken;
  final UnauthorizedHandler? onUnauthorized;
  final Duration timeout;
  final ApiLogger logger;

  Future<Object?> get(
    String path, {
    Map<String, Object?>? query,
    bool authenticated = true,
  }) => _send('GET', path, query: query, authenticated: authenticated);

  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    bool authenticated = true,
  }) => _send(
    'POST',
    path,
    body: body,
    query: query,
    authenticated: authenticated,
  );

  Future<Object?> put(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    bool authenticated = true,
  }) => _send(
    'PUT',
    path,
    body: body,
    query: query,
    authenticated: authenticated,
  );

  Future<Object?> delete(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    bool authenticated = true,
  }) => _send(
    'DELETE',
    path,
    body: body,
    query: query,
    authenticated: authenticated,
  );

  void close() => _client.close();

  Future<Object?> _send(
    String method,
    String path, {
    required bool authenticated,
    Object? body,
    Map<String, Object?>? query,
  }) async {
    final url = _buildUri(path, query);
    logger.request(method, url, body);

    try {
      var response = await _execute(method, url, body, authenticated);

      if (response.statusCode == 401 &&
          authenticated &&
          onUnauthorized != null &&
          await onUnauthorized!()) {
        response = await _execute(method, url, body, authenticated);
      }

      logger.response(method, url, response.statusCode, response.body);
      return _handle(response);
    } on ApiException catch (e) {
      logger.error(method, url, e);
      rethrow;
    } on TimeoutException {
      logger.error(method, url, 'timeout');
      throw const ApiTimeoutException();
    } on SocketException catch (e) {
      logger.error(method, url, e);
      throw const NetworkException();
    } on http.ClientException catch (e) {
      logger.error(method, url, e);
      throw const NetworkException();
    }
  }

  Future<http.Response> _execute(
    String method,
    Uri url,
    Object? body,
    bool authenticated,
  ) async {
    final request = http.Request(method, url)
      ..headers['Accept'] = 'application/json';

    if (body != null) {
      request
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode(body);
    }

    if (authenticated) {
      final token = await accessToken?.call();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    final streamed = await _client.send(request).timeout(timeout);
    return http.Response.fromStream(streamed).timeout(timeout);
  }

  Uri _buildUri(String path, Map<String, Object?>? query) {
    final params = <String, Object>{};
    query?.forEach((key, value) {
      if (value == null) return;
      params[key] = value is Iterable
          ? value.map((e) => '$e').toList()
          : value is DateTime
          ? value.toIso8601String()
          : '$value';
    });
    return Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: params.isEmpty ? null : params);
  }

  Object? _handle(http.Response response) {
    final status = response.statusCode;
    // Decode as UTF-8 explicitly: package:http falls back to latin1 when the
    // server omits a charset.
    final text = utf8.decode(response.bodyBytes, allowMalformed: true);

    if (status >= 200 && status < 300) {
      if (text.trim().isEmpty) return null;
      try {
        return jsonDecode(text);
      } on FormatException {
        throw const ParseException();
      }
    }

    throw _toException(status, text);
  }

  ApiException _toException(int status, String text) {
    final problem = _ProblemDetails.tryParse(text);

    switch (status) {
      case 400:
      case 422:
        return ValidationException(
          problem.message ?? 'The request was invalid.',
          statusCode: status,
          fieldErrors: problem.fieldErrors,
        );
      case 401:
        return UnauthorizedException(
          problem.message ?? 'Your session has expired. Please sign in again.',
        );
      case 403:
        return ForbiddenException(
          problem.message ?? 'You do not have permission to do that.',
        );
      case 404:
        return NotFoundException(problem.message ?? 'Not found.');
      case >= 500:
        return ServerException(
          'Something went wrong on our side. Please try later.',
          status,
        );
      default:
        return UnknownApiException(
          problem.message ?? 'Unexpected error ($status).',
          statusCode: status,
        );
    }
  }
}

/// Parses ASP.NET Core `ProblemDetails` / `ValidationProblemDetails`.
class _ProblemDetails {
  const _ProblemDetails({this.message, this.fieldErrors = const {}});

  final String? message;
  final Map<String, List<String>> fieldErrors;

  factory _ProblemDetails.tryParse(String text) {
    if (text.trim().isEmpty) return const _ProblemDetails();
    try {
      final json = jsonDecode(text);
      if (json is! Map<String, dynamic>) {
        return _ProblemDetails(message: json is String ? json : null);
      }

      final errors = <String, List<String>>{};
      final rawErrors = json['errors'];
      if (rawErrors is Map<String, dynamic>) {
        rawErrors.forEach((key, value) {
          if (value is List) errors[key] = value.map((e) => '$e').toList();
        });
      }

      final firstFieldError = errors.values.firstOrNull?.firstOrNull;
      final message =
          _asString(json['detail']) ??
          firstFieldError ??
          _asString(json['message']) ??
          _asString(json['title']);

      return _ProblemDetails(message: message, fieldErrors: errors);
    } on FormatException {
      return const _ProblemDetails();
    }
  }

  static String? _asString(Object? value) =>
      value is String && value.isNotEmpty ? value : null;
}
