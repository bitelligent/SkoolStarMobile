import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_action_row.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_gradient_hero.dart';
import 'package:skoolstar_teacher_module/core/widgets/avatar_circle.dart';
import 'package:skoolstar_teacher_module/core/widgets/loading_view.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/repositories/user_repository.dart';
import 'package:skoolstar_teacher_module/features/profile/cubit/profile_cubit.dart';
import 'package:skoolstar_teacher_module/features/profile/cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileCubit(context.read<UserRepository>())..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            return switch (state) {
              ProfileInitial() || ProfileLoading() => const LoadingView(),
              ProfileError(:final message) => ErrorView(
                  message: message,
                  onRetry: () => context.read<ProfileCubit>().load(),
                ),
              ProfileLoaded() => _Loaded(state: state),
            };
          },
        ),
      ),
    );
  }
}

class _Loaded extends StatefulWidget {
  const _Loaded({required this.state});

  final ProfileLoaded state;

  @override
  State<_Loaded> createState() => _LoadedState();
}

class _LoadedState extends State<_Loaded> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _currentPassword;
  late final TextEditingController _newPassword;
  late final TextEditingController _confirmPassword;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  /// Whether the Personal information + Change password sections are
  /// visible. Toggled by the pencil icon in the hero card. Resets to
  /// `false` after a successful save or when the user cancels.
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.state.firstNameDraft);
    _lastName = TextEditingController(text: widget.state.lastNameDraft);
    _email = TextEditingController(text: widget.state.user.email);
    _currentPassword = TextEditingController();
    _newPassword = TextEditingController();
    _confirmPassword = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _enterEdit() {
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    final cubit = context.read<ProfileCubit>();
    final user = widget.state.user;
    _firstName.text = user.firstName;
    _lastName.text = user.lastName;
    cubit
      ..setFirstName(user.firstName)
      ..setLastName(user.lastName)
      ..toggleChangePassword(false);
    _currentPassword.clear();
    _newPassword.clear();
    _confirmPassword.clear();
    setState(() {
      _isEditing = false;
      _showCurrent = false;
      _showNew = false;
      _showConfirm = false;
    });
  }

  Future<void> _save() async {
    final cubit = context.read<ProfileCubit>();
    final ok = await cubit.save();
    if (!mounted) return;
    if (ok) {
      _snack(context, 'Profile updated');
      _currentPassword.clear();
      _newPassword.clear();
      _confirmPassword.clear();
      setState(() {
        _isEditing = false;
        _showCurrent = false;
        _showNew = false;
        _showConfirm = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final s = widget.state;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text('My Profile', style: AppTextStyles.displayMedium),
        ),

        // ── Hero + edit toggle ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Stack(
            children: [
              AppGradientHero(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: AvatarCircle(
                        imageUrl: s.user.avatarUrl,
                        name: '${s.user.firstName} ${s.user.lastName}',
                        size: 60,
                        background: Colors.white,
                        foreground: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 40),
                            child: Text(
                              '${s.user.firstName} ${s.user.lastName}',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.user.email,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Teacher',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: _HeroEditButton(
                  isEditing: _isEditing,
                  onTap: _isEditing ? _cancelEdit : _enterEdit,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Edit mode: Personal info + Change password + Save/Cancel ───
        AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _isEditing
              ? _EditSection(
                  state: s,
                  firstName: _firstName,
                  lastName: _lastName,
                  email: _email,
                  currentPassword: _currentPassword,
                  newPassword: _newPassword,
                  confirmPassword: _confirmPassword,
                  showCurrent: _showCurrent,
                  showNew: _showNew,
                  showConfirm: _showConfirm,
                  onToggleShowCurrent: () =>
                      setState(() => _showCurrent = !_showCurrent),
                  onToggleShowNew: () => setState(() => _showNew = !_showNew),
                  onToggleShowConfirm: () =>
                      setState(() => _showConfirm = !_showConfirm),
                  cubit: cubit,
                  onSave: _save,
                  onCancel: _cancelEdit,
                )
              : _ViewSection(onNotice: (msg) => _snack(context, msg)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// View-mode section (preferences list + log out)
// ─────────────────────────────────────────────────────────────────────────
class _ViewSection extends StatelessWidget {
  const _ViewSection({required this.onNotice});

  final ValueChanged<String> onNotice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              children: [
                AppActionRow(
                  icon: Icons.notifications_rounded,
                  iconColor: AppColors.warning,
                  label: 'Notifications',
                  subtitle: 'Manage push alerts',
                  onTap: () => onNotice('Notifications'),
                ),
                const Divider(height: 1),
                AppActionRow(
                  icon: Icons.help_outline_rounded,
                  iconColor: AppColors.accentTeal,
                  label: 'Help centre',
                  subtitle: 'Guides and support',
                  onTap: () => onNotice('Help centre'),
                ),
                const Divider(height: 1),
                AppActionRow(
                  icon: Icons.info_outline_rounded,
                  iconColor: AppColors.accentIndigo,
                  label: 'About',
                  subtitle: 'App version & legal',
                  onTap: () => onNotice('About'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => onNotice('Logged out'),
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: Text(
                'Log out',
                style:
                    AppTextStyles.titleSmall.copyWith(color: AppColors.danger),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Edit-mode section (personal info + change password + save/cancel)
// ─────────────────────────────────────────────────────────────────────────
class _EditSection extends StatelessWidget {
  const _EditSection({
    required this.state,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
    required this.showCurrent,
    required this.showNew,
    required this.showConfirm,
    required this.onToggleShowCurrent,
    required this.onToggleShowNew,
    required this.onToggleShowConfirm,
    required this.cubit,
    required this.onSave,
    required this.onCancel,
  });

  final ProfileLoaded state;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController currentPassword;
  final TextEditingController newPassword;
  final TextEditingController confirmPassword;
  final bool showCurrent;
  final bool showNew;
  final bool showConfirm;
  final VoidCallback onToggleShowCurrent;
  final VoidCallback onToggleShowNew;
  final VoidCallback onToggleShowConfirm;
  final ProfileCubit cubit;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Personal information ----------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSectionTitle(
                  title: 'Personal information',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppFormField(
                        label: 'First name',
                        required: true,
                        child: AppTextField(
                          controller: firstName,
                          onChanged: cubit.setFirstName,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppFormField(
                        label: 'Last name',
                        required: true,
                        child: AppTextField(
                          controller: lastName,
                          onChanged: cubit.setLastName,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppFormField(
                  label: 'Email',
                  hint: 'Email cannot be changed here.',
                  child: AppTextField(
                    controller: email,
                    enabled: false,
                    suffix: const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: AppColors.iconSubtle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Change password ---------------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accentPurpleSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        color: AppColors.accentPurple,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Change password',
                              style: AppTextStyles.titleSmall),
                          Text(
                            'Set a new password for your account.',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.changePasswordEnabled,
                      onChanged: cubit.toggleChangePassword,
                      activeColor: AppColors.accentPurple,
                    ),
                  ],
                ),
                if (state.changePasswordEnabled) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppFormField(
                    label: 'Current password',
                    child: AppTextField(
                      controller: currentPassword,
                      obscure: !showCurrent,
                      onChanged: cubit.setCurrentPassword,
                      suffix: IconButton(
                        icon: Icon(
                          showCurrent
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.iconSubtle,
                          size: 18,
                        ),
                        onPressed: onToggleShowCurrent,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppFormField(
                    label: 'New password',
                    child: AppTextField(
                      controller: newPassword,
                      obscure: !showNew,
                      onChanged: cubit.setNewPassword,
                      suffix: IconButton(
                        icon: Icon(
                          showNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.iconSubtle,
                          size: 18,
                        ),
                        onPressed: onToggleShowNew,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppFormField(
                    label: 'Confirm new password',
                    child: AppTextField(
                      controller: confirmPassword,
                      obscure: !showConfirm,
                      onChanged: cubit.setConfirmPassword,
                      suffix: IconButton(
                        icon: Icon(
                          showConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.iconSubtle,
                          size: 18,
                        ),
                        onPressed: onToggleShowConfirm,
                      ),
                    ),
                  ),
                ],
                if (state.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.danger,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Save / Cancel buttons ---------------------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: state.isSaving ? null : onCancel,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                    ),
                    label: Text(
                      'Cancel',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: 'Save',
                  icon: Icons.check_rounded,
                  isLoading: state.isSaving,
                  onPressed: onSave,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Edit button in the top-right of the hero card
// ─────────────────────────────────────────────────────────────────────────
class _HeroEditButton extends StatelessWidget {
  const _HeroEditButton({required this.isEditing, required this.onTap});

  final bool isEditing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isEditing ? 0.95 : 0.22),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(isEditing ? 0 : 0.4),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => RotationTransition(
              turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: Icon(
              isEditing ? Icons.close_rounded : Icons.edit_rounded,
              key: ValueKey(isEditing),
              size: 18,
              color: isEditing ? AppColors.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
