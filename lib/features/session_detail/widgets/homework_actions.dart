import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/homework_edit_sheet.dart';

/// Edit / delete flows shared by the homework card and the detail sheet, so
/// both behave (and word their messages) identically.
///
/// [context] must be below the screen's `SessionDetailCubit`.

void _snack(ScaffoldMessengerState messenger, String text) => messenger
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(text)));

/// Opens the edit form and reports the outcome in a snackbar.
Future<void> runEditHomework(BuildContext context, Homework homework) async {
  // Captured first: the originating widget may be gone when this returns
  // (for example the homework was deleted elsewhere).
  final messenger = ScaffoldMessenger.of(context);
  final result = await showHomeworkEditSheet(context, homework: homework);
  final text = switch (result) {
    HomeworkEditResult.saved => 'Homework updated',
    HomeworkEditResult.gone => 'This homework no longer exists.',
    HomeworkEditResult.locked =>
      'Homework can only be edited on the day it was assigned.',
    HomeworkEditResult.none => null,
  };
  if (text != null) _snack(messenger, text);
}

/// Asks for confirmation, then deletes. Returns `true` when a request was
/// actually sent (so callers can show a busy state around it).
///
/// [onBusy] is called with `true` just before the request and `false` after.
Future<void> runDeleteHomework(
  BuildContext context,
  Homework homework, {
  void Function({required bool busy})? onBusy,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: const Text('Delete homework?'),
      content: Text(
        '"${homework.title}" and all student submissions for it will be '
        'removed. Students will no longer see it. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text(
            'Delete',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  final cubit = context.read<SessionDetailCubit>();
  final messenger = ScaffoldMessenger.of(context);
  onBusy?.call(busy: true);
  final outcome = await cubit.deleteHomework(homework.id);
  onBusy?.call(busy: false);

  if (outcome.ok) {
    _snack(messenger, 'Homework deleted');
  } else if (outcome.message != null) {
    _snack(messenger, outcome.message!);
  }
}

/// Compact Edit / Delete row used at the bottom of a homework card.
///
/// Edit is only offered during the edit window; Delete is always available.
class HomeworkCardActions extends StatefulWidget {
  const HomeworkCardActions({required this.homework, super.key});

  final Homework homework;

  @override
  State<HomeworkCardActions> createState() => _HomeworkCardActionsState();
}

class _HomeworkCardActionsState extends State<HomeworkCardActions> {
  bool _deleting = false;

  @override
  Widget build(BuildContext context) {
    final canEdit = widget.homework.canEditAt(DateTime.now());

    // Deliberately compact: a hairline divider and a 32px row, so the card
    // grows by about 40px instead of ~70px.
    final compact = TextButton.styleFrom(
      minimumSize: const Size(0, 32),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      textStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 2),
          Row(
            children: [
              if (canEdit)
                Expanded(
                  child: TextButton.icon(
                    onPressed: _deleting
                        ? null
                        : () => runEditHomework(context, widget.homework),
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: const Text('Edit'),
                    style: compact,
                  ),
                ),
              Expanded(
                child: TextButton.icon(
                  onPressed: _deleting
                      ? null
                      : () => runDeleteHomework(
                          context,
                          widget.homework,
                          onBusy: ({required busy}) {
                            if (mounted) setState(() => _deleting = busy);
                          },
                        ),
                  icon: _deleting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline_rounded, size: 16),
                  label: Text(_deleting ? 'Deleting…' : 'Delete'),
                  style: compact.copyWith(
                    foregroundColor: const WidgetStatePropertyAll(
                      AppColors.danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
