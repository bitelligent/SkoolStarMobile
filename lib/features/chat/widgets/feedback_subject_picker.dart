import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_dropdown.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/data/repositories/feedback_subjects_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_subjects_cubit.dart';

/// Optional "Subject" field of a feedback. Offers the subjects the teacher
/// teaches *every* selected student, plus a "none" choice, and clears the
/// pick when the recipients change and it no longer applies.
class FeedbackSubjectPicker extends StatefulWidget {
  const FeedbackSubjectPicker({
    required this.studentIds,
    required this.value,
    required this.onChanged,
    this.noneLabel = 'No subject',
    super.key,
  });

  final List<String> studentIds;

  /// Chosen subject name, or `null` for none.
  final String? value;
  final ValueChanged<String?> onChanged;

  /// What "none" means here, e.g. "Use the lesson's subject".
  final String noneLabel;

  @override
  State<FeedbackSubjectPicker> createState() => _FeedbackSubjectPickerState();
}

class _FeedbackSubjectPickerState extends State<FeedbackSubjectPicker> {
  late final FeedbackSubjectsCubit _cubit = FeedbackSubjectsCubit(
    context.read<FeedbackSubjectsRepository>(),
  )..load(widget.studentIds);

  @override
  void didUpdateWidget(covariant FeedbackSubjectPicker old) {
    super.didUpdateWidget(old);
    if (!setEquals(old.studentIds.toSet(), widget.studentIds.toSet())) {
      _cubit.load(widget.studentIds);
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FeedbackSubjectsCubit, FeedbackSubjectsState>(
        listener: (context, state) {
          final v = widget.value;
          if (v != null &&
              !state.loading &&
              !state.failed &&
              !state.subjects.any((s) => s.name == v)) {
            widget.onChanged(null);
          }
        },
        builder: (context, state) => AppFormField(
          label: 'Subject (optional)',
          child: _field(context, state),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, FeedbackSubjectsState state) {
    if (widget.studentIds.isEmpty) {
      return const _Note('Select a recipient to choose a subject.');
    }
    if (state.loading) {
      return const _Note('Loading subjects…');
    }
    if (state.failed) {
      return _Note(
        'Could not load subjects.',
        action: TextButton(
          onPressed: _cubit.retry,
          child: const Text('Retry'),
        ),
      );
    }
    if (state.subjects.isEmpty) {
      return const _Note('No common subject for the selected students.');
    }
    return AppDropdown<String>(
      sheetTitle: 'Subject',
      value: widget.value,
      hint: widget.noneLabel,
      options: [
        AppOption(id: '', label: widget.noneLabel),
        for (final s in state.subjects) AppOption(id: s.name, label: s.name),
      ],
      onChanged: (name) => widget.onChanged(name.isEmpty ? null : name),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text, {this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.menu_book_rounded, size: 16, color: context.brand.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ),
      ?action,
    ],
  );
}
