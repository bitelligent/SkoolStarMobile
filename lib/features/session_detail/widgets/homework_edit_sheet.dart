import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/utils/keyboard.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';

/// Result of the edit sheet.
enum HomeworkEditResult {
  /// Nothing changed (cancelled, or saved without changes).
  none,
  saved,

  /// The homework was deleted on the server meanwhile.
  gone,

  /// The server closed the edit window.
  locked,
}

/// Bottom sheet to edit a homework's title, description and max marks.
///
/// Only the three fields the backend accepts are offered; everything else
/// (deadline, files, students) is shown as read-only information.
Future<HomeworkEditResult> showHomeworkEditSheet(
  BuildContext context, {
  required Homework homework,
}) async {
  final cubit = context.read<SessionDetailCubit>();
  final result = await showModalBottomSheet<HomeworkEditResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _EditForm(homework: homework),
    ),
  );
  return result ?? HomeworkEditResult.none;
}

class _EditForm extends StatefulWidget {
  const _EditForm({required this.homework});

  final Homework homework;

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _marks;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final h = widget.homework;
    _title = TextEditingController(text: h.title)..addListener(_changed);
    _description = TextEditingController(text: h.description)
      ..addListener(_changed);
    _marks = TextEditingController(text: '${h.maxMarks}')
      ..addListener(_changed);
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _marks.dispose();
    super.dispose();
  }

  void _changed() {
    if (!mounted) return;
    setState(() => _error = null);
  }

  int? get _marksValue => int.tryParse(_marks.text.trim());

  /// Field-level message, shown while typing.
  String? get _titleError =>
      _title.text.trim().isEmpty ? 'Title is required.' : null;

  String? get _marksError {
    final v = _marksValue;
    if (_marks.text.trim().isEmpty) return 'Enter the maximum marks.';
    if (v == null || v < 1) return 'Marks must be greater than 0.';
    if (v > 1000) return 'Marks cannot exceed 1000.';
    return null;
  }

  bool get _valid => _titleError == null && _marksError == null;

  bool get _dirty {
    final h = widget.homework;
    return _title.text.trim() != h.title.trim() ||
        _description.text.trim() != h.description.trim() ||
        _marksValue != h.maxMarks;
  }

  Future<void> _save() async {
    if (_saving || !_valid) return;
    if (!_dirty) {
      Navigator.of(context).pop(HomeworkEditResult.none);
      return;
    }
    context.dismissKeyboard();
    setState(() {
      _saving = true;
      _error = null;
    });

    final outcome = await context.read<SessionDetailCubit>().updateHomework(
      widget.homework.id,
      title: _title.text,
      description: _description.text,
      maxMarks: _marksValue,
    );
    if (!mounted) return;

    switch (outcome.result) {
      case HomeworkActionResult.success:
        Navigator.of(context).pop(HomeworkEditResult.saved);
      case HomeworkActionResult.notFound:
        Navigator.of(context).pop(HomeworkEditResult.gone);
      case HomeworkActionResult.editWindowClosed:
        Navigator.of(context).pop(HomeworkEditResult.locked);
      case HomeworkActionResult.busy:
      case HomeworkActionResult.failed:
        // Stay open and keep what the teacher typed.
        setState(() {
          _saving = false;
          _error = outcome.message ?? 'Could not save. Please try again.';
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.only(bottom: insets),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit homework', style: AppTextStyles.headingSmall),
              const SizedBox(height: 4),
              Text(
                "You can change the title, description and marks. The "
                "deadline, files and students can't be changed.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppFormField(
                label: 'Title',
                required: true,
                child: _Field(
                  controller: _title,
                  enabled: !_saving,
                  hint: 'Homework title',
                  errorText: _title.text.isEmpty ? null : _titleError,
                  maxLength: 200,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Description',
                child: _Field(
                  controller: _description,
                  enabled: !_saving,
                  hint: 'What should students do?',
                  maxLines: 4,
                  maxLength: 2000,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Maximum marks',
                required: true,
                child: _Field(
                  controller: _marks,
                  enabled: !_saving,
                  hint: 'e.g. 100',
                  errorText: _marks.text.isEmpty ? null : _marksError,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 4,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Save changes',
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _valid && _dirty ? _save : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: _saving
                    ? null
                    : () => Navigator.of(context).pop(HomeworkEditResult.none),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Text field with inline error text, using the app's input styling.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.enabled,
    required this.hint,
    this.errorText,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hint;
  final String? errorText;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: c, width: w),
    );
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      minLines: maxLines > 1 ? 3 : 1,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.sentences,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        errorText: errorText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        enabledBorder: border(AppColors.border),
        disabledBorder: border(AppColors.border),
        focusedBorder: border(context.brand.primary, 1.4),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.4),
      ),
    );
  }
}
