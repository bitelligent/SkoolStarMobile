import 'package:flutter/material.dart';

/// Centralised colour palette for the whole app. Changing a value here
/// re-skins every screen because nothing hard-codes hex values.
class AppColors {
  AppColors._();

  // ---------- Brand ----------
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primarySoft = Color(0xFFEEF4FF);

  // ---------- Category accents (used for subject chips, class pills,
  // category tiles). Each has a hard colour + its soft tinted variant.
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleSoft = Color(0xFFF3EEFF);
  static const Color accentPink = Color(0xFFEC4899);
  static const Color accentPinkSoft = Color(0xFFFCE7F3);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentOrangeSoft = Color(0xFFFFEDD5);
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentTealSoft = Color(0xFFCCFBF1);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentCyanSoft = Color(0xFFCFFAFE);
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentIndigoSoft = Color(0xFFE0E7FF);

  // ---------- Status ----------
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFD1FAE5);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoSoft = Color(0xFFE0F2FE);

  // ---------- Neutrals ----------
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFFD1D5DB);
  static const Color divider = Color(0xFFF1F5F9);

  // ---------- Text ----------
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ---------- Icons / shadow ----------
  static const Color iconSubtle = Color(0xFF64748B);
  static const Color shadow = Color(0x14000000);
  static const Color shadowStrong = Color(0x1F0F172A);
}

/// Reusable linear gradients. Reference these in hero cards, CTAs, and
/// live banners — never hand-roll a gradient inside a screen.
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F7FFF), Color(0xFF2563EB)],
  );

  static const LinearGradient live = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFEC4899)],
  );
}

/// Shadow tokens. Use these on every surface so elevation is consistent.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> card = const [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static List<BoxShadow> cardSoft = const [
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevated = const [
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.28),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
