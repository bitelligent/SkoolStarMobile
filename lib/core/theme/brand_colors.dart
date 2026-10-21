import 'package:flutter/material.dart';

/// Institute brand colours, resolved at runtime (white-label).
///
/// Read them with `context.brand` so a branding change rebuilds the widgets
/// that depend on it. Every shade the UI needs is derived from the two colours
/// the backend provides (primary + secondary), so a client only ever supplies
/// two hex values.
@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  const BrandColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primarySoft,
    required this.secondary,
    required this.onSecondary,
    required this.gradientStart,
    required this.liveGradientStart,
  });

  /// Derives the whole palette from the institute's colours. A `null` or
  /// unusable colour falls back to the SkoolStar default for that slot.
  factory BrandColors.fromSeeds({Color? primary, Color? secondary}) {
    if (primary == null && secondary == null) return fallback;

    final p = primary == null ? fallback.primary : _legibleOnWhite(primary);
    final s = secondary ?? fallback.secondary;
    final hsl = HSLColor.fromColor(p);

    return BrandColors(
      primary: p,
      primaryDark: _withLightness(hsl, hsl.lightness - 0.08),
      primaryLight: _withLightness(hsl, 0.92, saturation: hsl.saturation),
      primarySoft: _withLightness(hsl, 0.96, saturation: hsl.saturation),
      secondary: s,
      onSecondary: _onColor(s),
      gradientStart: _withLightness(hsl, hsl.lightness + 0.10),
      liveGradientStart: Color.lerp(p, s, 0.5)!,
    );
  }

  /// The SkoolStar look, used before / without institute branding.
  static const BrandColors fallback = BrandColors(
    primary: Color(0xFF2563EB),
    primaryDark: Color(0xFF1D4ED8),
    primaryLight: Color(0xFFDBEAFE),
    primarySoft: Color(0xFFEEF4FF),
    secondary: Color(0xFF8B5CF6),
    onSecondary: Colors.white,
    gradientStart: Color(0xFF4F7FFF),
    liveGradientStart: Color(0xFF6366F1),
  );

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color primarySoft;
  final Color secondary;

  /// Readable foreground on [secondary].
  final Color onSecondary;

  final Color gradientStart;
  final Color liveGradientStart;

  /// Text / icons placed on [primary]. `fromSeeds` guarantees the primary is
  /// dark enough for white.
  Color get onPrimary => Colors.white;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, primary],
  );

  LinearGradient get liveGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [liveGradientStart, secondary],
  );

  static Color _withLightness(
    HSLColor hsl,
    double lightness, {
    double? saturation,
  }) => hsl
      .withLightness(lightness.clamp(0.0, 1.0))
      .withSaturation((saturation ?? hsl.saturation).clamp(0.0, 1.0))
      .toColor();

  /// Darkens [c] until white text on it reaches a 3:1 contrast, so a client
  /// that picks a very light brand colour cannot make buttons unreadable or
  /// invisible on the white surfaces.
  static Color _legibleOnWhite(Color c) {
    var hsl = HSLColor.fromColor(c);
    for (var i = 0; i < 40 && hsl.toColor().computeLuminance() > 0.30; i++) {
      hsl = hsl.withLightness((hsl.lightness - 0.03).clamp(0.0, 1.0));
    }
    return hsl.toColor();
  }

  static Color _onColor(Color c) =>
      c.computeLuminance() > 0.5 ? const Color(0xFF0F172A) : Colors.white;

  @override
  BrandColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? primarySoft,
    Color? secondary,
    Color? onSecondary,
    Color? gradientStart,
    Color? liveGradientStart,
  }) => BrandColors(
    primary: primary ?? this.primary,
    primaryDark: primaryDark ?? this.primaryDark,
    primaryLight: primaryLight ?? this.primaryLight,
    primarySoft: primarySoft ?? this.primarySoft,
    secondary: secondary ?? this.secondary,
    onSecondary: onSecondary ?? this.onSecondary,
    gradientStart: gradientStart ?? this.gradientStart,
    liveGradientStart: liveGradientStart ?? this.liveGradientStart,
  );

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      liveGradientStart: Color.lerp(
        liveGradientStart,
        other.liveGradientStart,
        t,
      )!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrandColors &&
      other.primary == primary &&
      other.primaryDark == primaryDark &&
      other.primaryLight == primaryLight &&
      other.primarySoft == primarySoft &&
      other.secondary == secondary &&
      other.onSecondary == onSecondary &&
      other.gradientStart == gradientStart &&
      other.liveGradientStart == liveGradientStart;

  @override
  int get hashCode => Object.hash(
    primary,
    primaryDark,
    primaryLight,
    primarySoft,
    secondary,
    onSecondary,
    gradientStart,
    liveGradientStart,
  );
}

extension BrandContext on BuildContext {
  /// Institute colours; the SkoolStar defaults when no brand is applied (e.g.
  /// in isolated widget tests).
  BrandColors get brand =>
      Theme.of(this).extension<BrandColors>() ?? BrandColors.fallback;
}

/// `#RRGGBB`, `RRGGBB` or `#RGB` → opaque [Color]; `null` for anything else
/// (including alpha forms, which the backend does not promise).
Color? parseHexColor(String? raw) {
  var hex = raw?.trim() ?? '';
  if (hex.startsWith('#')) hex = hex.substring(1);
  if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
  if (hex.length != 6) return null;
  final value = int.tryParse(hex, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}
