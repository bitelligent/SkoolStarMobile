/// The signed-in parent's own details.
class GuardianProfile {
  const GuardianProfile({
    required this.name,
    required this.email,
    this.relationship = '',
    this.phone = '',
  });

  final String name;
  final String email;

  /// "Father", "Mother", … when the school recorded it.
  final String relationship;
  final String phone;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return email.isEmpty ? '?' : email[0].toUpperCase();
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
