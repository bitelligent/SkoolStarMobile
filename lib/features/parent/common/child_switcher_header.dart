import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child.dart';
import 'package:skoolstar_teacher_module/features/parent/common/children_cubit.dart';

/// Always-visible "which child am I looking at" control at the top of every
/// parent screen. Tapping opens the list of children; choosing one makes
/// every screen reload for that child.
class ChildSwitcherHeader extends StatelessWidget {
  const ChildSwitcherHeader({this.trailing, super.key});

  /// Extra action on the right (the notifications bell).
  final Widget? trailing;

  Future<void> _pick(BuildContext context, ChildrenLoaded s) async {
    final cubit = context.read<ChildrenCubit>();
    final picked = await showAppOptionsSheet<String>(
      context,
      title: 'Switch child',
      selectedId: s.selected?.id,
      options: [
        for (final c in s.children)
          AppOption(
            id: c.id,
            label: c.name,
            subtitle: c.classLabel.isEmpty ? null : c.classLabel,
            icon: Icons.child_care_rounded,
            color: AppColors.accentTeal,
          ),
      ],
    );
    if (picked == null) return;
    final child = s.children.where((c) => c.id == picked).firstOrNull;
    if (child != null) await cubit.select(child);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: BlocBuilder<ChildrenCubit, ChildrenState>(
                  builder: (context, state) => switch (state) {
                    ChildrenLoaded(:final selected, :final children)
                        when selected != null =>
                      _Pill(
                        child: selected,
                        onTap: children.length > 1
                            ? () => _pick(context, state)
                            : null,
                      ),
                    ChildrenLoaded() => const _InfoPill(
                      icon: Icons.child_care_rounded,
                      text: 'No children linked',
                    ),
                    ChildrenError() => _InfoPill(
                      icon: Icons.error_outline_rounded,
                      text: 'Could not load children',
                      actionLabel: 'Retry',
                      onAction: () => context.read<ChildrenCubit>().load(),
                    ),
                    _ => const _InfoPill(
                      icon: Icons.hourglass_empty_rounded,
                      text: 'Loading…',
                    ),
                  },
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child, required this.onTap});

  final Child child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: 'Child: ${child.name}. ${onTap != null ? 'Tap to switch' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.cardSoft,
          ),
          child: Row(
            children: [
              AvatarCircle(name: child.name, size: 32),
              const SizedBox(width: AppSpacing.sm),
              // The name takes all the free width, so the chip and chevron
              // sit at the right edge on any screen size.
              Expanded(
                child: Text(
                  child.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (child.classShort.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: AppChip(
                    label: child.classShort,
                    color: context.brand.primary,
                    dense: true,
                  ),
                ),
              ],
              if (onTap != null) ...[
                const SizedBox(width: 2),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.iconSubtle,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.iconSubtle),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
