import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/features/branding/brand_context.dart';

/// The institute logo on a white tile, or the default school mark when the
/// institute has no logo / it cannot be loaded (offline, unsupported format).
class BrandLogo extends StatelessWidget {
  const BrandLogo({this.size = 72, this.elevated = true, super.key});

  final double size;

  /// Soft shadow, for use over the gradient headers.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final uri = context.brandState.logoUri;
    final fallback = Icon(
      Icons.school_rounded,
      size: size * 0.55,
      color: context.brand.primary,
    );

    // Flutter cannot decode SVG without an extra package; use the default mark
    // rather than a broken image.
    final renderable = uri != null && !uri.path.toLowerCase().endsWith('.svg');

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(renderable ? size * 0.12 : 0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: renderable
          ? Image.network(
              uri.toString(),
              fit: BoxFit.contain,
              // Decode near display size, not the full upload (up to 5 MB).
              cacheWidth: (size * 3).round(),
              gaplessPlayback: true,
              semanticLabel: 'Logo',
              errorBuilder: (_, _, _) => fallback,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : fallback,
            )
          : fallback,
    );
  }
}
