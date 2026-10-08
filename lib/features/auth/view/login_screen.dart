import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/features/auth/cubit/login_cubit.dart';
import 'package:skoolstar_teacher_module/features/auth/cubit/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => LoginCubit(ctx.read<AuthRepository>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit({String? contextKey}) {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().submit(
      email: _email.text,
      password: _password.text,
      contextKey: contextKey,
    );
  }

  Future<void> _pickContext(List<AuthContext> contexts) async {
    final picked = await showModalBottomSheet<AuthContext>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose an account', style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final c in contexts)
              ListTile(
                title: Text(c.displayName ?? c.contextKey),
                subtitle: c.instituteName == null ? null : Text(c.role),
                onTap: () => Navigator.of(context).pop(c),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) _submit(contextKey: picked.contextKey);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;

    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        switch (state) {
          case LoginSuccess():
            context.goNamed(AppRoutes.dashboard);
          case LoginContextSelection(:final contexts):
            _pickContext(contexts);
          case LoginFailure(:final message):
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          case LoginInitial():
          case LoginLoading():
            break;
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              _HeroBackground(height: height * 0.46),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xxl,
                      AppSpacing.xl,
                      AppSpacing.xxl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _Brand(),
                          const SizedBox(height: AppSpacing.xxxl),
                          _buildCard(),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Trouble signing in? Contact your school '
                            'administrator.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Welcome back', style: AppTextStyles.headingLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sign in to manage your classes and sessions.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppFormField(
                label: 'Email',
                child: _field(
                  controller: _email,
                  hint: 'you@school.com',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Enter your email';
                    if (!t.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppFormField(
                label: 'Password',
                child: _field(
                  controller: _password,
                  hint: 'Enter your password',
                  icon: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Enter your password' : null,
                  suffix: IconButton(
                    tooltip: _obscure ? 'Show password' : 'Hide password',
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.iconSubtle,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) => PrimaryButton(
                  label: 'Sign in',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: state is LoginLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// `AppTextField` has no validator/autofill support, so the login form uses
  /// a `TextFormField` styled with the same theme tokens.
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    bool obscure = false,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: c, width: w),
    );
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surfaceSubtle,
        prefixIcon: Icon(icon, size: 20, color: AppColors.iconSubtle),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary, 1.6),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.6),
      ),
    );
  }
}

/// Gradient header with soft decorative circles, clipped into a curved edge.
class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ClipPath(
        clipper: const _CurvedBottomClipper(),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: Stack(
            children: [
              const Positioned(
                top: -60,
                right: -50,
                child: _Bubble(size: 200, alpha: 0.10),
              ),
              Positioned(
                top: height * 0.45,
                left: -70,
                child: const _Bubble(size: 180, alpha: 0.08),
              ),
              const Positioned(
                top: 70,
                left: 40,
                child: _Bubble(size: 36, alpha: 0.14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

class _CurvedBottomClipper extends CustomClipper<Path> {
  const _CurvedBottomClipper();

  @override
  Path getClip(Size size) {
    const curve = 36.0;
    return Path()
      ..lineTo(0, size.height - curve)
      ..quadraticBezierTo(
        size.width / 2,
        size.height + curve,
        size.width,
        size.height - curve,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'SkoolStar',
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 30,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Teacher Module',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
