import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';

/// Overlapping avatar stack with an optional "+N" counter at the end.
/// Used in session cards, class rows, and the Classes screen.
class AppAvatarGroup extends StatelessWidget {
  const AppAvatarGroup({
    required this.names,
    this.max = 3,
    this.size = 28,
    this.overlap = 10,
    super.key,
  });

  final List<String> names;
  final int max;
  final double size;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final visible = names.take(max).toList();
    final extra = names.length - visible.length;

    return SizedBox(
      height: size,
      width: visible.length * (size - overlap) + overlap + (extra > 0 ? size : 0),
      child: Stack(
        children: [
          ...visible.asMap().entries.map(
                (e) => Positioned(
                  left: e.key * (size - overlap),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: AvatarCircle(name: e.value, size: size - 4),
                  ),
                ),
              ),
          if (extra > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
                child: Text(
                  '+$extra',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
