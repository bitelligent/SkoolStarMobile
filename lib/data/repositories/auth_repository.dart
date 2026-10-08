import 'package:flutter/foundation.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/network/token_store.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_request.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_response.dart';

// ignore: one_member_abstracts, grows with logout/refresh/select-context.
abstract interface class AuthRepository {
  bool get isSignedIn;

  /// Emits whenever the user signs in or out (including forced sign-outs
  /// after an expired session). The router listens to this.
  ValueListenable<bool> get signedIn;

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

  @override
  Future<void> logout() async {
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
      await _tokens.save(
        accessToken: token,
        refreshToken: response.refreshToken,
      );
      _signedIn.value = true;
    }
    return response;
  }
}
