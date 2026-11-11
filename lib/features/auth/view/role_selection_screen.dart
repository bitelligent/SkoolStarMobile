import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/config/app_config.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/data/models/auth/app_role.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_session.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/features/auth/cubit/role_selection_cubit.dart';
import 'package:skoolstar_teacher_module/features/branding/brand_context.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app. Injectable so tests don't hit the platform.
typedef UrlOpener = Future<bool> Function(Uri url);

Future<bool> _defaultOpener(Uri url) =>
    launchUrl(url, mode: LaunchMode.externalApplication);

/// Lists every role of the signed-in account. Teacher and Parent open their
/// module; any other role points the user to the web app.
///
/// Shown right after login (accounts with several roles, or only a role the
/// mobile app does not cover) and from Profile → Switch role.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({this.openUrl = _defaultOpener, super.key});

  final UrlOpener openUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => RoleSelectionCubit(ctx.read<AuthRepository>()),
      child: _RoleSelectionView(openUrl: openUrl),
    );
  }
}

class _RoleSelectionView extends StatelessWidget {
  const _RoleSelectionView({required this.openUrl});

  final UrlOpener openUrl;

  Future<void> _openWeb(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    var opened = false;
    try {
      opened = await openUrl(Uri.parse(AppConfig.webAppUrl));
    } on Object {
      opened = false;
    }
    if (!opened) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              "Couldn't open the web app. Visit ${AppConfig.webAppUrl} "
              'in your browser.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthRepository>();

    return ValueListenableBuilder<AuthSession>(
      valueListenable: auth.session,
      builder: (context, session, _) {
        final contexts = session.contexts;
        // Switching from inside a module: a supported role is already active.
        final switching = session.role != null;
        final native = contexts.where((c) => c.isSupported).toList();
        final web = contexts.where((c) => !c.isSupported).toList();

        return BlocListener<RoleSelectionCubit, RoleSelectionState>(
          listener: (context, state) {
            switch (state) {
              case RoleSelectionSelected(:final active):
                // `go` replaces the stack so the old module is gone.
                GoRouter.of(context).go(AppRoutes.homeFor(active.appRole));
              case RoleSelectionFailure(:final message):
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
              case RoleSelectionIdle():
              case RoleSelectionSelecting():
                break;
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              child: Column(
                children: [
                  _Header(
                    switching: switching,
                    onBack: switching
                        ? () => Navigator.of(context).maybePop()
                        : null,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.xxl,
                          ),
                          children: [
                            if (contexts.isEmpty) const _NoRoles(),
                            if (native.isNotEmpty) ...[
                              const _SectionLabel('Available in this app'),
                              for (final c in native)
                                _RoleCard(
                                  role: c,
                                  isCurrent:
                                      switching &&
                                      c.contextKey == session.contextKey,
                                  onTap: () => context
                                      .read<RoleSelectionCubit>()
                                      .select(c),
                                ),
                            ],
                            if (web.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              const _SectionLabel('Use on the web app'),
                              for (final c in web)
                                _RoleCard(
                                  role: c,
                                  isCurrent: false,
                                  onTap: () => _openWeb(context),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.xs,
                                  left: 4,
                                  right: 4,
                                ),
                                child: Text(
                                  'These roles are managed on the ${context.appName} '
                                  'web app. Tapping one opens it in your '
                                  'browser.',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.xl),
                            Center(
                              child: TextButton.icon(
                                onPressed: () =>
                                    context.read<AuthRepository>().logout(),
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  size: 18,
                                ),
                                label: const Text('Sign out'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gradient header with the screen title; doubles as the app bar when the
/// screen is opened from Profile → Switch role.
class _Header extends StatelessWidget {
  const _Header({required this.switching, required this.onBack});

  final bool switching;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: context.brand.gradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xxl + 8),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: onBack == null
                    ? null
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: onBack,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.18,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: context.brand.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                switching ? 'Switch role' : 'Choose how to continue',
                style: AppTextStyles.headingLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                switching
                    ? 'Use ${context.appName} as a different role. Your current '
                          'session stays signed in.'
                    : 'This account has more than one role. Select the one '
                          'to use for this session.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.sm),
    child: Text(
      text.toUpperCase(),
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textTertiary,
        letterSpacing: 0.9,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.role,
    required this.isCurrent,
    required this.onTap,
  });

  final AuthContext role;
  final bool isCurrent;
  final VoidCallback onTap;

  (IconData, Color) _style(BuildContext context, AppRole r) => switch (r) {
    AppRole.teacher => (
      Icons.cast_for_education_rounded,
      context.brand.primary,
    ),
    AppRole.parent => (Icons.family_restroom_rounded, AppColors.accentTeal),
    AppRole.unsupported => (
      Icons.admin_panel_settings_rounded,
      AppColors.accentIndigo,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _style(context, role.appRole);
    final selecting = context.select<RoleSelectionCubit, bool>(
      (c) =>
          c.state is RoleSelectionSelecting &&
          (c.state as RoleSelectionSelecting).contextKey == role.contextKey,
    );
    final busy = context.select<RoleSelectionCubit, bool>(
      (c) => c.state is RoleSelectionSelecting,
    );
    final place = role.placeLabel;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        button: true,
        selected: isCurrent,
        label:
            '${role.roleLabel}${place.isEmpty ? '' : ', $place'}'
            '${role.isSupported ? '' : ', opens the web app'}',
        child: Material(
          color: isCurrent ? context.brand.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: InkWell(
            onTap: busy ? null : onTap,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(
                  color: isCurrent ? context.brand.primary : AppColors.border,
                  width: isCurrent ? 1.6 : 1,
                ),
                boxShadow: isCurrent ? null : AppShadows.cardSoft,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          role.roleLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium,
                        ),
                        if (place.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_outlined,
                                size: 14,
                                color: AppColors.iconSubtle,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (selecting)
                    const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  else if (isCurrent)
                    AppChip(
                      label: 'Current',
                      icon: Icons.check_circle_rounded,
                      color: context.brand.primary,
                      dense: true,
                    )
                  else if (role.isSupported)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.iconSubtle,
                    )
                  else
                    const AppChip(
                      label: 'Web',
                      icon: Icons.open_in_new_rounded,
                      color: AppColors.textSecondary,
                      dense: true,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoRoles extends StatelessWidget {
  const _NoRoles();

  @override
  Widget build(BuildContext context) => const AppEmptyState(
    icon: Icons.lock_person_outlined,
    title: 'No role available',
    subtitle: 'This account has no role yet. Please contact your school.',
  );
}
