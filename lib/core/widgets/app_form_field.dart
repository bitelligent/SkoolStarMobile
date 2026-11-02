import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';

/// A label-on-top wrapper for any form input. Keeps spacing + typography
/// consistent across every form in the app.
class AppFormField extends StatelessWidget {
  const AppFormField({
    required this.label,
    required this.child,
    this.hint,
    this.error,
    this.trailing,
    this.required = false,
    super.key,
  });

  final String label;
  final Widget child;
  final String? hint;

  /// Replaces [hint] (in the danger colour) while the value is invalid.
  final String? error;
  final Widget? trailing;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (required)
              Text(
                '  *',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.danger,
                ),
              ),
            if (trailing != null) ...[const Spacer(), trailing!],
          ],
        ),
        const SizedBox(height: 6),
        child,
        if (error != null || hint != null) ...[
          const SizedBox(height: 4),
          Text(
            error ?? hint!,
            style: AppTextStyles.labelSmall.copyWith(
              color: error != null ? AppColors.danger : AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Modern filled text field. Default is a single-line input; set [maxLines]
/// for multiline. Keyboard, formatters and change callbacks all pass through.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.controller,
    this.hint,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.obscure = false,
    this.suffix,
    this.prefix,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String? hint;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscure;
  final Widget? suffix;
  final Widget? prefix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: obscure ? 1 : maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      obscureText: obscure,
      onChanged: onChanged,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        prefixIcon: prefix,
        suffixIcon: suffix,
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(context.brand.primary, width: 1.4),
        disabledBorder: _border(AppColors.border),
      ),
    );
  }

  OutlineInputBorder _border(Color c, {double width = 1}) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: c, width: width),
  );
}

/// Rounded search field (Dashboard filter card, Session learner list, chat
/// list, ...). Shows a clear button while it holds text; works with or without
/// an external [controller].
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.hint,
    required this.onChanged,
    this.controller,
    this.autofocus = false,
    super.key,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final bool autofocus;

  /// Comfortable touch height (the field used to be ~36 px).
  static const double height = 48;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  TextEditingController? _own;

  TextEditingController get _controller =>
      widget.controller ?? (_own ??= TextEditingController());

  void _clear() {
    _controller.clear();
    widget.onChanged('');
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: AppSearchField.height),
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 20,
            color: AppColors.iconSubtle,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: widget.autofocus,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox(width: AppSpacing.md)
                : IconButton(
                    tooltip: 'Clear search',
                    visualDensity: VisualDensity.compact,
                    onPressed: _clear,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: AppColors.iconSubtle,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
