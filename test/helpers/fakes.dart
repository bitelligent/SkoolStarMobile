import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_session.dart';
import 'package:skoolstar_teacher_module/data/models/auth/login_response.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

import '../fixtures/fixtures.dart' as fx;

http.Response jsonResponse(Object? body, [int status = 200]) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Auth double with a mutable session so tests can switch role / sign out.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AuthContext? context, List<AuthContext>? contexts})
    : _session = ValueNotifier(
        AuthSession(
          signedIn: true,
          context: context ?? AuthContext.fromJson(fx.teacherContext),
          contexts:
              contexts ?? [context ?? AuthContext.fromJson(fx.teacherContext)],
        ),
      ) {
    _signedIn = ValueNotifier(true);
  }

  final ValueNotifier<AuthSession> _session;
  late final ValueNotifier<bool> _signedIn;

  /// Context keys passed to [selectContext], in order.
  final List<String> selected = [];

  @override
  AuthContext? get currentContext => _session.value.context;

  @override
  List<AuthContext> get availableContexts => _session.value.contexts;

  @override
  Future<AuthContext> requireContext() async => currentContext!;

  @override
  Future<AuthContext> selectContext(String contextKey) async {
    selected.add(contextKey);
    final next = availableContexts.firstWhere(
      (c) => c.contextKey == contextKey,
    );
    _session.value = AuthSession(
      signedIn: true,
      context: next,
      contexts: availableContexts,
    );
    return next;
  }

  @override
  bool get isSignedIn => _signedIn.value;

  @override
  ValueListenable<bool> get signedIn => _signedIn;

  @override
  ValueListenable<AuthSession> get session => _session;

  /// Signed in, several roles, none chosen yet (the post-login role list).
  void signInWithoutRole(List<AuthContext> contexts) {
    _signedIn.value = true;
    _session.value = AuthSession(signedIn: true, contexts: contexts);
  }

  /// Signs back in as [context] (tests that sign out and in again).
  void signInAs(AuthContext context) {
    _signedIn.value = true;
    _session.value = AuthSession(
      signedIn: true,
      context: context,
      contexts: [context],
    );
  }

  @override
  Future<void> logout() async {
    _signedIn.value = false;
    _session.value = AuthSession.signedOut;
  }

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
    String? contextKey,
  }) => throw UnimplementedError();
}
