import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_session.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_request.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_response.dart';

abstract interface class AuthRepository {
  bool get isSignedIn;

  /// Emits whenever the user signs in or out (including forced sign-outs
  /// after an expired session).
  ValueListenable<bool> get signedIn;

  /// Signed-in state plus the active role and every available role. The
  /// router listens to this; it fires when the role changes too.
  ValueListenable<AuthSession> get session;

  /// Active context (role + institute) restored from storage, or `null`
  /// before login / before a role is chosen.
  AuthContext? get currentContext;

  /// Roles the account can use (empty before login).
  List<AuthContext> get availableContexts;

  /// Returns [currentContext], fetching `my-contexts` if the session predates
  /// context persistence. Throws [ApiException] when the user still has to
  /// choose a role.
  Future<AuthContext> requireContext();

  /// Makes [contextKey] the active role (new tokens are issued and stored).
  /// Works right after login and later from "Switch role".
  Future<AuthContext> selectContext(String contextKey);

  /// Clears stored credentials. The app returns to the login screen via the
  /// router's auth redirect.
  Future<void> logout();

  /// Signs in and stores the issued tokens. When the account has several
  /// roles no role is active yet ([AuthSession.needsRoleSelection]).
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
       _tokens = tokenStore {
    _context = _decodeContext(tokenStore.contextJson);
    _contexts = _decodeContexts(tokenStore.contextsJson);
    final signedIn = tokenStore.accessToken?.isNotEmpty ?? false;
    _signedIn = ValueNotifier(signedIn);
    _session = ValueNotifier(_build(signedIn));
  }

  final ApiClient _api;
  final TokenStore _tokens;
  late final ValueNotifier<bool> _signedIn;
  late final ValueNotifier<AuthSession> _session;
  AuthContext? _context;
  List<AuthContext> _contexts = const [];

  @override
  bool get isSignedIn => _signedIn.value;

  @override
  ValueListenable<bool> get signedIn => _signedIn;

  @override
  ValueListenable<AuthSession> get session => _session;

  @override
  AuthContext? get currentContext => _context;

  @override
  List<AuthContext> get availableContexts => List.unmodifiable(_contexts);

  AuthSession _build(bool signedIn) => signedIn
      ? AuthSession(signedIn: true, context: _context, contexts: _contexts)
      : AuthSession.signedOut;

  void _publish() {
    final signedIn = _tokens.accessToken?.isNotEmpty ?? false;
    _signedIn.value = signedIn;
    _session.value = _build(signedIn);
  }

  static AuthContext? _decodeContext(String? raw) {
    if (raw == null) return null;
    try {
      return AuthContext.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  static List<AuthContext> _decodeContexts(String? raw) {
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(AuthContext.fromJson)
          .toList();
    } on Object {
      return const [];
    }
  }

  Future<void> _store({
    AuthContext? context,
    List<AuthContext>? contexts,
  }) async {
    _context = context;
    if (contexts != null) _contexts = contexts;
    await _tokens.saveContext(
      context == null ? null : jsonEncode(context.toJson()),
    );
    if (contexts != null) {
      await _tokens.saveContexts(
        jsonEncode([for (final c in contexts) c.toJson()]),
      );
    }
  }

  @override
  Future<AuthContext> requireContext() async {
    final cached = _context;
    if (cached != null) return cached;

    final json = await _api.get(ApiEndpoints.myContexts);
    final contexts = json is List
        ? json
              .whereType<Map<String, dynamic>>()
              .map(AuthContext.fromJson)
              .toList()
        : <AuthContext>[];
    // A single role can be used without asking; otherwise the user chooses.
    if (contexts.length == 1) {
      await _store(context: contexts.first, contexts: contexts);
      _publish();
      return contexts.first;
    }
    await _store(contexts: contexts);
    _publish();
    throw const ForbiddenException('Please choose a role to continue.');
  }

  @override
  Future<AuthContext> selectContext(String contextKey) async {
    final json = await _api.post(
      ApiEndpoints.selectContext,
      body: {'contextKey': contextKey},
    );
    final response = _parse(json);
    final token = response.accessToken;
    if (token == null || token.isEmpty) throw const ParseException();

    final contexts = response.availableContexts.isNotEmpty
        ? response.availableContexts
        : _contexts;
    final wanted = response.activeContextKey ?? contextKey;
    final active = contexts.where((c) => c.contextKey == wanted).firstOrNull;
    if (active == null) throw const ParseException();

    await _tokens.save(
      accessToken: token,
      refreshToken: response.refreshToken,
    );
    await _store(context: active, contexts: contexts);
    _publish();
    return active;
  }

  @override
  Future<void> logout() async {
    _context = null;
    _contexts = const [];
    await _tokens.clear();
    _publish();
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
    final response = _parse(json);

    final token = response.accessToken;
    if (token == null || token.isEmpty) throw const ParseException();

    final contexts = response.availableContexts;
    if (contexts.isEmpty) {
      // A valid login with no role cannot be used anywhere.
      throw const ForbiddenException(
        'This account has no role assigned. Please contact your school.',
      );
    }

    // The token is stored even before a role is chosen: it is what
    // `select-context` needs.
    final active = response.requiresContextSelection
        ? null
        : contexts
              .where((c) => c.contextKey == response.activeContextKey)
              .firstOrNull;
    await _tokens.save(
      accessToken: token,
      refreshToken: response.refreshToken,
    );
    await _store(context: active, contexts: contexts);
    _publish();
    return response;
  }

  LoginResponse _parse(Object? json) {
    if (json is! Map<String, dynamic>) throw const ParseException();
    try {
      return LoginResponse.fromJson(json);
    } on Object {
      throw const ParseException();
    }
  }
}
