import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';

/// Centralised typography. We use Inter (Google Fonts) as a clean,
/// generic sans-serif so the look is consistent on Android and iOS.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base(double size, FontWeight weight, {Color? color}) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      height: 1.3,
    );
  }

  // Display / heading
  static TextStyle displayLarge = _base(28, FontWeight.w700);
  static TextStyle displayMedium = _base(24, FontWeight.w700);
  static TextStyle headingLarge = _base(22, FontWeight.w700);
  static TextStyle headingMedium = _base(20, FontWeight.w700);
  static TextStyle headingSmall = _base(18, FontWeight.w700);

  // Title
  static TextStyle titleLarge = _base(17, FontWeight.w700);
  static TextStyle titleMedium = _base(16, FontWeight.w600);
  static TextStyle titleSmall = _base(15, FontWeight.w600);

  // Body
  static TextStyle bodyLarge = _base(16, FontWeight.w400);
  static TextStyle bodyMedium = _base(14, FontWeight.w400);
  static TextStyle bodySmall = _base(13, FontWeight.w400);

  // Label / caption
  static TextStyle labelLarge = _base(14, FontWeight.w600);
  static TextStyle labelMedium = _base(13, FontWeight.w500);
  static TextStyle labelSmall = _base(12, FontWeight.w500);
  static TextStyle caption = _base(11, FontWeight.w400, color: AppColors.textSecondary);
}
