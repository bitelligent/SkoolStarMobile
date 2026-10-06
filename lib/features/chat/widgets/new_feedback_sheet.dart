import 'package:flutter/material.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';

typedef FeedbackSubmit = Future<bool> Function({
  required String subject,
  required FeedbackTone tone,
  required String message,
});

/// Draft returned to the caller — the sheet pops this value when the
/// user hits "Send". Null means the sheet was dismissed.
class NewFeedbackDraft {
  const NewFeedbackDraft({
    required this.subject,
    required this.tone,
    required this.message,
  });

  final String subject;
  final FeedbackTone tone;
  final String message;
}

/// Opens the composer sheet. Returns a [NewFeedbackDraft] or null.
Future<NewFeedbackDraft?> showNewFeedbackSheet(
  BuildContext context, {
  required String parentName,
}) {
  return showAppSheet<NewFeedbackDraft>(
    context,
    title: 'New feedback  ·  $parentName',
    isScrollControlled: true,
    builder: (sheetContext) => _NewFeedbackBody(
      onSubmit: (draft) => Navigator.of(sheetContext).pop(draft),
    ),
  );
}

class _NewFeedbackBody extends StatefulWidget {
  const _NewFeedbackBody({required this.onSubmit});

  final ValueChanged<NewFeedbackDraft> onSubmit;

  @override
  State<_NewFeedbackBody> createState() => _NewFeedbackBodyState();
}

class _NewFeedbackBodyState extends State<_NewFeedbackBody> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  FeedbackTone _tone = FeedbackTone.positive;

  @override
  void initState() {
    super.initState();
    _message.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  bool get _canSend => _message.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _toneRow(),
          const SizedBox(height: AppSpacing.md),
          AppFormField(
            label: 'Subject',
            hint: 'A short title helps the parent find this later.',
            child: AppTextField(
              controller: _subject,
              hint: 'eg. Math homework progress',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppFormField(
            label: 'Message',
            required: true,
            child: AppTextField(
              controller: _message,
              hint: 'Share the feedback you want to send to the parent…',
              maxLines: 5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Send feedback',
            icon: Icons.send_rounded,
            onPressed: _canSend
                ? () => widget.onSubmit(
                      NewFeedbackDraft(
                        subject: _subject.text,
                        tone: _tone,
                        message: _message.text,
                      ),
                    )
                : null,
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              'The parent gets a push notification instantly.',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toneRow() {
    const options = <(FeedbackTone, String, IconData, Color)>[
      (
        FeedbackTone.positive,
        'Positive',
        Icons.thumb_up_rounded,
        AppColors.success,
      ),
      (
        FeedbackTone.needsAttention,
        'Needs attention',
        Icons.priority_high_rounded,
        AppColors.warning,
      ),
      (
        FeedbackTone.neutral,
        'Note',
        Icons.notes_rounded,
        AppColors.accentIndigo,
      ),
    ];

    return AppFormField(
      label: 'Tone',
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: options
            .map(
              (o) => AppChip(
                label: o.$2,
                icon: o.$3,
                color: o.$4,
                selected: _tone == o.$1,
                onTap: () => setState(() => _tone = o.$1),
              ),
            )
            .toList(),
      ),
    );
  }
}
