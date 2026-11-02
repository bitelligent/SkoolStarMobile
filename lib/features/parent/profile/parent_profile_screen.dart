import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_action_row.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_gradient_hero.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/features/branding/brand_context.dart';
import 'package:skoolstar_teacher_module/features/parent/profile/parent_profile_cubit.dart';
import 'package:skoolstar_teacher_module/features/profile/view/profile_screen.dart'
    show confirmLogout;

class ParentProfileScreen extends StatelessWidget {
  const ParentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthRepository>();
    final institute = auth.currentContext?.instituteName ?? '';

    return BlocBuilder<ParentProfileCubit, ParentProfileState>(
      builder: (context, state) {
        final profile = state is ParentProfileLoaded ? state.profile : null;
        final name = (profile?.name.isNotEmpty ?? false)
            ? profile!.name
            : (profile?.email ?? 'Parent');

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('My Profile', style: AppTextStyles.displayMedium),
            const SizedBox(height: AppSpacing.md),
            AppGradientHero(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  AvatarCircle(
                    name: name,
                    size: 60,
                    background: Colors.white,
                    foreground: context.brand.primary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (profile != null && profile.email.isNotEmpty)
                          Text(
                            profile.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text(
                          [
                            if (profile?.relationship.isNotEmpty ?? false)
                              profile!.relationship,
                            'Parent',
                            if (institute.isNotEmpty) institute,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state is ParentProfileError) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Could not load your details. ${state.message}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.danger,
                ),
              ),
            ],
            if (auth.session.value.canSwitchRole) ...[
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: AppActionRow(
                  icon: Icons.swap_horiz_rounded,
                  iconColor: context.brand.primary,
                  label: 'Switch role',
                  subtitle:
                      'Use ${context.appName} as a teacher or another role',
                  onTap: () => context.push(AppRoutes.selectRolePath),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => confirmLogout(context),
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: Text(
                'Log out',
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.danger,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
