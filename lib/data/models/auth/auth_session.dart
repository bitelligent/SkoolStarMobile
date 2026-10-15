import 'package:skoolstar_teacher_module/data/models/auth/app_role.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';

/// Everything the router needs to decide where a user belongs.
class AuthSession {
  const AuthSession({
    required this.signedIn,
    this.context,
    this.contexts = const [],
  });

  static const signedOut = AuthSession(signedIn: false);

  final bool signedIn;

  /// The role the user is acting as, or `null` while none is chosen yet.
  final AuthContext? context;

  /// Every role the account can use (for the role list / Switch role).
  final List<AuthContext> contexts;

  /// Signed in, but no role is active (or the active one has no mobile
  /// module): the user must pick a role / is told to use the web app.
  bool get needsRoleSelection =>
      signedIn && (context == null || !context!.isSupported);

  /// Role of the active context when it is one the app supports.
  AppRole? get role {
    final c = context;
    if (!signedIn || c == null || !c.isSupported) return null;
    return c.appRole;
  }

  /// Only the fields that decide navigation and cached data.
  String? get contextKey => context?.contextKey;

  @override
  bool operator ==(Object other) =>
      other is AuthSession &&
      other.signedIn == signedIn &&
      other.context == context &&
      _sameKeys(other.contexts, contexts);

  @override
  int get hashCode => Object.hash(signedIn, context, contexts.length);

  static bool _sameKeys(List<AuthContext> a, List<AuthContext> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].contextKey != b[i].contextKey) return false;
    }
    return true;
  }
}
