import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/router/app_router.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_session.dart';

import '../fixtures/fixtures.dart' as fx;

AuthContext _c(Map<String, dynamic> j) => AuthContext.fromJson(j);

void main() {
  final teacher = AuthSession(
    signedIn: true,
    context: _c(fx.teacherContext),
    contexts: [_c(fx.teacherContext)],
  );
  final parent = AuthSession(
    signedIn: true,
    context: _c(fx.parentContext),
    contexts: [_c(fx.adminContext), _c(fx.parentContext)],
  );
  final noRoleYet = AuthSession(
    signedIn: true,
    contexts: [_c(fx.adminContext), _c(fx.parentContext)],
  );
  final adminOnly = AuthSession(
    signedIn: true,
    context: _c(fx.adminContext),
    contexts: [_c(fx.adminContext)],
  );

  group('signed out', () {
    test('everything goes to login', () {
      for (final path in ['/dashboard', '/parent/home', '/select-role', '/']) {
        final expected = path == '/' ? null : AppRoutes.loginPath;
        expect(
          authRedirect(AuthSession.signedOut, path),
          expected,
          reason: path,
        );
      }
      expect(authRedirect(AuthSession.signedOut, AppRoutes.loginPath), isNull);
    });
  });

  group('signed in without a usable role', () {
    test('multi-role account must pick a role first', () {
      expect(authRedirect(noRoleYet, '/dashboard'), AppRoutes.selectRolePath);
      expect(authRedirect(noRoleYet, '/parent/home'), AppRoutes.selectRolePath);
      expect(
        authRedirect(noRoleYet, AppRoutes.loginPath),
        AppRoutes.selectRolePath,
      );
      expect(authRedirect(noRoleYet, AppRoutes.selectRolePath), isNull);
    });

    test('an unsupported-only account lands on the web-app message', () {
      expect(authRedirect(adminOnly, '/dashboard'), AppRoutes.selectRolePath);
      expect(authRedirect(adminOnly, AppRoutes.selectRolePath), isNull);
    });
  });

  group('teacher', () {
    test('login and parent URLs go to the teacher dashboard', () {
      expect(
        authRedirect(teacher, AppRoutes.loginPath),
        AppRoutes.dashboardPath,
      );
      expect(authRedirect(teacher, '/parent/home'), AppRoutes.dashboardPath);
      expect(
        authRedirect(teacher, '/parent/session/abc'),
        AppRoutes.dashboardPath,
      );
    });

    test('own routes and Switch role are untouched', () {
      for (final p in [
        '/dashboard',
        '/schedule',
        '/chat',
        '/session/1',
        '/select-role',
      ]) {
        expect(authRedirect(teacher, p), isNull, reason: p);
      }
    });
  });

  group('parent', () {
    test('login and teacher URLs go to the parent home', () {
      expect(
        authRedirect(parent, AppRoutes.loginPath),
        AppRoutes.parentHomePath,
      );
      expect(authRedirect(parent, '/dashboard'), AppRoutes.parentHomePath);
      expect(authRedirect(parent, '/session/1'), AppRoutes.parentHomePath);
    });

    test('own routes and Switch role are untouched', () {
      for (final p in [
        '/parent/home',
        '/parent/attendance',
        '/parent/assignments',
        '/parent/chat/feedback/pfb_01',
        '/select-role',
      ]) {
        expect(authRedirect(parent, p), isNull, reason: p);
      }
    });
  });

  test('splash is never redirected (it decides after its animation)', () {
    expect(authRedirect(parent, AppRoutes.splashPath), isNull);
    expect(authRedirect(AuthSession.signedOut, AppRoutes.splashPath), isNull);
  });

  test('parent path detection does not match look-alikes', () {
    expect(AppRoutes.isParentPath('/parent'), isTrue);
    expect(AppRoutes.isParentPath('/parent/home'), isTrue);
    expect(AppRoutes.isParentPath('/parents'), isFalse);
    expect(AppRoutes.isParentPath('/dashboard'), isFalse);
  });
}
