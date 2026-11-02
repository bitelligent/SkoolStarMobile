import 'package:freezed_annotation/freezed_annotation.dart';

part 'child.freezed.dart';

/// A pupil linked to the signed-in parent.
@freezed
abstract class Child with _$Child {
  const Child._();

  const factory Child({
    /// The student id, as a string like every other id in the app.
    required String id,
    required String name,
    @Default('') String className,
    @Default('') String sectionName,
    @Default(false) bool isPrimaryGuardian,
  }) = _Child;

  /// "Jannat Shahzadi" → "JS".
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  /// The class as parents say it: "Class 2" → "2", "Grade 5" and
  /// "Nursery" are kept as they are.
  String get classShort {
    final trimmed = className.trim();
    final stripped = trimmed.replaceFirst(
      RegExp(r'^class\s+', caseSensitive: false),
      '',
    );
    return stripped.isEmpty ? trimmed : stripped;
  }

  /// "Class 1" or "Class 1 · Section A".
  String get classLabel {
    if (className.isEmpty) return '';
    return sectionName.isEmpty ? className : '$className · $sectionName';
  }
}
