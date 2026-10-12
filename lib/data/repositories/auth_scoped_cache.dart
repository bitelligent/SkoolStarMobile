import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

/// Base for repositories that cache per-user data. The cache is dropped when
/// the user signs out (or the session expires) so the next account never sees
/// the previous account's data.
abstract class AuthScopedCache {
  AuthScopedCache(AuthRepository auth) : _auth = auth {
    auth.signedIn.addListener(_onAuthChanged);
  }

  final AuthRepository _auth;

  /// Drop everything cached for the current user.
  void clearCache();

  void _onAuthChanged() {
    if (!_auth.signedIn.value) clearCache();
  }

  /// Staff id of the signed-in teacher.
  Future<int> requireStaffId() async {
    final context = await _auth.requireContext();
    return context.staffId!;
  }
}
