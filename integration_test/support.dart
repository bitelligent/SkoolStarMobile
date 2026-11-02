import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/secure_token_store.dart';
import 'package:skoolstar_teacher_module/main.dart' as app;

/// Credentials come from `--dart-define` so nothing is stored in the repo.
const parentEmail = String.fromEnvironment('E2E_PARENT_EMAIL');
const teacherEmail = String.fromEnvironment('E2E_TEACHER_EMAIL');
const password = String.fromEnvironment('E2E_PASSWORD');

/// Pumps real time until [finder] matches (live network, so no fake clock).
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 40),
}) async {
  final end = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(end)) {
      fail('Timed out waiting for $finder');
    }
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.pump(const Duration(milliseconds: 300));
}

/// Marks a point for the external screenshot watcher, then lets it capture.
Future<void> checkpoint(WidgetTester tester, String name) async {
  // ignore: avoid_print
  print('CHECKPOINT $name');
  await tester.pump(const Duration(milliseconds: 2500));
}

/// Starts the real app and signs in as [email] with role [roleLabel] when the
/// login / role screens are showing (a saved session is reused).
Future<void> launchAndSignIn(
  WidgetTester tester, {
  required String email,
  required String roleLabel,
  required Finder homeMarker,
}) async {
  // Every test starts signed out: a session saved by an earlier run (maybe
  // another role) must not leak in and make the test pass for the wrong user.
  final store = SecureTokenStore();
  await store.load();
  await store.clear();

  app.main();
  await tester.pump(const Duration(seconds: 3));

  final emailField = find.byType(TextField);
  final deadline = DateTime.now().add(const Duration(seconds: 30));
  while (emailField.evaluate().length < 2 && homeMarker.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) fail('App did not reach login/home');
    await tester.pump(const Duration(milliseconds: 250));
  }

  if (homeMarker.evaluate().isEmpty && emailField.evaluate().length >= 2) {
    await tester.enterText(emailField.at(0), email);
    await tester.enterText(emailField.at(1), password);
    // A software keyboard would cover the button.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Sign in'));
    await tester.pump(const Duration(seconds: 1));
    final role = find.text(roleLabel);
    final end = DateTime.now().add(const Duration(seconds: 30));
    while (homeMarker.evaluate().isEmpty) {
      if (role.evaluate().isNotEmpty) {
        await tester.tap(role.first);
        await tester.pump(const Duration(seconds: 1));
      }
      if (DateTime.now().isAfter(end)) {
        await checkpoint(tester, 'stuck_after_login');
        fail('Never reached home after login');
      }
      await tester.pump(const Duration(milliseconds: 250));
    }
  }
  await tester.pump(const Duration(seconds: 2));
}
