import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/utils/keyboard.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_dropdown.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/parent/leave_request.dart';

/// Sends the request; resolves the reason it was refused, or `null` on
/// success.
typedef LeaveSubmit =
    Future<String?> Function(DateTime start, DateTime end, String reason);

/// Opens the "Request leave" form. Resolves `true` once a request was sent.
Future<bool> showLeaveRequestSheet(
  BuildContext context, {
  required String childName,
  required LeaveSubmit onSubmit,
}) async {
  final sent = await showAppSheet<bool>(
    context,
    title: 'Request leave  ·  $childName',
    isScrollControlled: true,
    builder: (_) => _LeaveForm(onSubmit: onSubmit),
  );
  return sent ?? false;
}

class _LeaveForm extends StatefulWidget {
  const _LeaveForm({required this.onSubmit});

  final LeaveSubmit onSubmit;

  @override
  State<_LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends State<_LeaveForm> {
  final _reason = TextEditingController();
  late DateTime _start = DateUtils.dateOnly(DateTime.now());
  late DateTime _end = _start;
  bool _submitting = false;

  /// Why the server refused the last attempt (overlap, …).
  String? _serverError;

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  String? get _dateError => LeaveRules.validateDates(_start, _end);

  bool get _canSubmit =>
      !_submitting && _reason.text.trim().isNotEmpty && _dateError == null;

  void _setStart(DateTime d) => setState(() {
    _start = d;
    if (_end.isBefore(d)) _end = d;
    _serverError = null;
  });

  void _setEnd(DateTime d) => setState(() {
    _end = d;
    _serverError = null;
  });

  Future<void> _submit() async {
    context.dismissKeyboard();
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    final error = await widget.onSubmit(_start, _end, _reason.text.trim());
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _submitting = false;
        _serverError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _dateError ?? _serverError;
    final days = LeaveRules.daysBetween(_start, _end);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AppFormField(
                  label: 'From',
                  required: true,
                  child: AppDateField(
                    value: _start,
                    firstDate: LeaveRules.firstStart(),
                    lastDate: LeaveRules.lastEnd(),
                    onChanged: _setStart,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppFormField(
                  label: 'To',
                  required: true,
                  child: AppDateField(
                    value: _end,
                    firstDate: _start,
                    lastDate: LeaveRules.lastEnd(),
                    onChanged: _setEnd,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            error ?? '$days ${days == 1 ? 'day' : 'days'}',
            style: AppTextStyles.labelMedium.copyWith(
              color: error == null ? AppColors.textSecondary : AppColors.danger,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppFormField(
            label: 'Reason',
            required: true,
            child: AppTextField(
              controller: _reason,
              hint: 'eg. Family travel',
              maxLines: 4,
              inputFormatters: [
                LengthLimitingTextInputFormatter(LeaveRules.maxReasonLength),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Submit request',
            icon: Icons.send_rounded,
            isLoading: _submitting,
            onPressed: _canSubmit ? _submit : null,
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              'The school is notified. You can cancel while it is pending.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
