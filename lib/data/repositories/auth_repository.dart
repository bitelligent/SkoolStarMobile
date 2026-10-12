import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_request.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_response.dart';

// ignore: one_member_abstracts, grows with logout/refresh/select-context.
abstract interface class AuthRepository {
  bool get isSignedIn;

  /// Emits whenever the user signs in or out (including forced sign-outs
  /// after an expired session). The router listens to this.
  ValueListenable<bool> get signedIn;

  /// Active teacher context (staff + institute) restored from storage, or
  /// `null` before login.
  AuthContext? get currentContext;

  /// Returns [currentContext], fetching it from `my-contexts` if the session
  /// predates context persistence. Throws [ApiException] if there is no
  /// teacher context.
  Future<AuthContext> requireContext();

  /// Clears stored credentials. The app returns to the login screen via the
  /// router's auth redirect.
  Future<void> logout();

  /// Signs in and, when a token is issued, stores it for later requests.
  ///
  /// If [LoginResponse.requiresContextSelection] is true no token is stored;
  /// call again with the chosen `contextKey`.
  ///
  /// Throws [ApiException] on failure.
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? contextKey,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenStore tokenStore,
  }) : _api = apiClient,
       _tokens = tokenStore,
       _signedIn = ValueNotifier(tokenStore.accessToken?.isNotEmpty ?? false);

  final ApiClient _api;
  final TokenStore _tokens;
  final ValueNotifier<bool> _signedIn;

  @override
  bool get isSignedIn => _signedIn.value;

  @override
  ValueListenable<bool> get signedIn => _signedIn;

  AuthContext? _context;

  @override
  AuthContext? get currentContext => _context ??= _restoreContext();

  AuthContext? _restoreContext() {
    final raw = _tokens.contextJson;
    if (raw == null) return null;
    try {
      return AuthContext.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<void> _setContext(AuthContext? context) async {
    _context = context;
    await _tokens.saveContext(
      context == null ? null : jsonEncode(context.toJson()),
    );
  }

  @override
  Future<AuthContext> requireContext() async {
    final cached = currentContext;
    if (cached != null) return cached;

    final json = await _api.get(ApiEndpoints.myContexts);
    final contexts = json is List
        ? json
              .whereType<Map<String, dynamic>>()
              .map(AuthContext.fromJson)
              .toList()
        : <AuthContext>[];
    final teacher = contexts.where(_isTeacher).firstOrNull;
    if (teacher == null) throw const ForbiddenException(_notTeacherMessage);
    await _setContext(teacher);
    return teacher;
  }

  static const _notTeacherMessage =
      'This app is for teachers. Please sign in with a teacher account.';

  static bool _isTeacher(AuthContext c) =>
      c.role.toLowerCase() == 'teacher' && c.staffId != null;

  @override
  Future<void> logout() async {
    _context = null;
    await _tokens.clear();
    _signedIn.value = false;
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? contextKey,
  }) async {
    final json = await _api.post(
      ApiEndpoints.enhancedLogin,
      body: LoginRequest(
        email: email.trim(),
        password: password,
        contextKey: contextKey,
      ).toJson(),
      authenticated: false,
    );

    if (json is! Map<String, dynamic>) throw const ParseException();

    final LoginResponse response;
    try {
      response = LoginResponse.fromJson(json);
    } on Object {
      throw const ParseException();
    }

    final token = response.accessToken;
    if (token != null && token.isNotEmpty) {
      final active = response.availableContexts
          .where((c) => c.contextKey == response.activeContextKey)
          .firstOrNull;
      if (active == null || !_isTeacher(active)) {
        // Never keep a session for a non-teacher account.
        throw const ForbiddenException(_notTeacherMessage);
      }
      await _setContext(active);
      await _tokens.save(
        accessToken: token,
        refreshToken: response.refreshToken,
      );
      _signedIn.value = true;
    }
    return response;
  }
}
