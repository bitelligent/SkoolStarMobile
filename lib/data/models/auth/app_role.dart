import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';

/// How the mobile app treats an account role.
///
/// Teachers and parents have a native module. Every other role (client admin,
/// institute admin, …) is [unsupported] on mobile and is sent to the web app.
enum AppRole { teacher, parent, unsupported }

extension AuthContextRole on AuthContext {
  AppRole get appRole {
    switch (role.trim().toLowerCase()) {
      case 'teacher':
        // The teacher module addresses everything by staff id.
        return staffId != null ? AppRole.teacher : AppRole.unsupported;
      case 'parent':
        return AppRole.parent;
      default:
        return AppRole.unsupported;
    }
  }

  /// True when the app has a native module for this context.
  bool get isSupported => appRole != AppRole.unsupported;

  /// Human readable role: `ClientAdmin` → "Client Admin", `Parent` → "Parent".
  String get roleLabel {
    final spaced = role
        .trim()
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])(?=[A-Z])|[_\-]+'),
          (_) => ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (spaced.isEmpty) return 'Role';
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  /// Where the role applies: the institute, else the organisation.
  String get placeLabel {
    for (final v in [instituteName, clientName]) {
      final t = v?.trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return '';
  }

  /// Text for role lists, e.g. "Parent — ISL AC".
  String get title {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final institute = instituteName?.trim();
    return institute == null || institute.isEmpty ? role : '$role — $institute';
  }
}
