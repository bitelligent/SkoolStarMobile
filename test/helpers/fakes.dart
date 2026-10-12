import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_response.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

import '../fixtures/fixtures.dart' as fx;

http.Response jsonResponse(Object? body, [int status = 200]) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository() : _signedIn = ValueNotifier(true);

  final ValueNotifier<bool> _signedIn;

  @override
  AuthContext get currentContext => AuthContext.fromJson(fx.teacherContext);

  @override
  Future<AuthContext> requireContext() async => currentContext;

  @override
  bool get isSignedIn => _signedIn.value;

  @override
  ValueListenable<bool> get signedIn => _signedIn;

  @override
  Future<void> logout() async => _signedIn.value = false;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? contextKey,
  }) => throw UnimplementedError();
}
