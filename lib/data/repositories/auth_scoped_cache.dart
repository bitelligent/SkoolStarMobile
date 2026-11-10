import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

/// Base for repositories that cache per-user data. The cache is dropped when
/// the user signs out, the session expires, or the active role changes, so
/// the next account/role never sees the previous one's data.
abstract class AuthScopedCache {
  AuthScopedCache(AuthRepository auth) : _auth = auth {
    _lastKey = _keyOf(auth);
    auth.session.addListener(_onSessionChanged);
  }

  final AuthRepository _auth;
  String? _lastKey;

  /// Drop everything cached for the current user.
  void clearCache();

  static String? _keyOf(AuthRepository auth) {
    final s = auth.session.value;
    return s.signedIn ? s.contextKey ?? 'no-context' : null;
  }

  void _onSessionChanged() {
    final key = _keyOf(_auth);
    if (key != _lastKey) {
      _lastKey = key;
      clearCache();
    }
  }

  /// Staff id of the signed-in teacher.
  Future<int> requireStaffId() async {
    final context = await _auth.requireContext();
    final id = context.staffId;
    if (id == null) {
      throw const ForbiddenException(
        'This section is only available to teachers.',
      );
    }
    return id;
  }
}
