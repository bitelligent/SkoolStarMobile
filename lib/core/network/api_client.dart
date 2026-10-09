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

/// A file sent as a multipart form field.
class UploadFile {
  const UploadFile({
    required this.field,
    required this.filename,
    required this.bytes,
  });

  final String field;
  final String filename;
  final List<int> bytes;
}

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

  /// `multipart/form-data` upload (files are held in memory so the request
  /// can be rebuilt for the 401 retry).
  Future<Object?> postMultipart(
    String path, {
    required List<UploadFile> files,
    Map<String, String>? fields,
  }) => _send(
    'POST',
    path,
    authenticated: true,
    files: files,
    fields: fields,
  );

  /// Resolves a server-side file reference to a full URL. Accepts absolute
  /// URLs and server-relative paths (`/uploads/a.pdf` or `uploads/a.pdf`).
  /// Returns `null` for an empty/unparseable reference.
  Uri? resolveFileUrl(String reference) {
    final ref = reference.trim().replaceAll(r'\', '/');
    if (ref.isEmpty) return null;
    final lower = ref.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return Uri.tryParse(ref);
    }
    final base = _baseUrl.endsWith('/')
        ? _baseUrl.substring(0, _baseUrl.length - 1)
        : _baseUrl;
    return Uri.tryParse(ref.startsWith('/') ? '$base$ref' : '$base/$ref');
  }

  /// Headers for fetching protected files outside [ApiClient] (e.g. images).
  Future<Map<String, String>> authHeaders() async {
    final token = await accessToken?.call();
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void close() => _client.close();

  Future<Object?> _send(
    String method,
    String path, {
    required bool authenticated,
    Object? body,
    Map<String, Object?>? query,
    List<UploadFile>? files,
    Map<String, String>? fields,
  }) async {
    final url = _buildUri(path, query);
    logger.request(method, url, files == null ? body : {'files': files.length});

    try {
      var response = await _execute(
        method,
        url,
        body,
        authenticated,
        files,
        fields,
      );

      if (response.statusCode == 401 &&
          authenticated &&
          onUnauthorized != null &&
          await onUnauthorized!()) {
        response = await _execute(
          method,
          url,
          body,
          authenticated,
          files,
          fields,
        );
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
    List<UploadFile>? files,
    Map<String, String>? fields,
  ) async {
    final http.BaseRequest request;
    if (files != null) {
      request = http.MultipartRequest(method, url)
        ..fields.addAll(fields ?? const {})
        ..files.addAll([
          for (final f in files)
            http.MultipartFile.fromBytes(
              f.field,
              f.bytes,
              filename: f.filename,
            ),
        ]);
    } else {
      final r = http.Request(method, url);
      if (body != null) {
        r
          ..headers['Content-Type'] = 'application/json'
          ..body = jsonEncode(body);
      }
      request = r;
    }
    request.headers['Accept'] = 'application/json';

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
