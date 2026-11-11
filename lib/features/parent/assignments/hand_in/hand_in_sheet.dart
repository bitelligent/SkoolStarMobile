import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/core/utils/attachment_picker.dart';
import 'package:skoolstar_teacher_module/core/utils/file_size.dart';
import 'package:skoolstar_teacher_module/core/utils/keyboard.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_confirm_dialog.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/parent/assignment_submission.dart';
import 'package:skoolstar_teacher_module/data/models/parent/child_assignment.dart';
import 'package:skoolstar_teacher_module/data/repositories/parent/assignment_submission_repository.dart';
import 'package:skoolstar_teacher_module/features/parent/assignments/hand_in/hand_in_cubit.dart';

const _maxNoteLength = 1000;

/// Opens the "Hand in homework" form. Resolves the time the hand-in was
/// recorded, or `null` when nothing was handed in.
Future<DateTime?> showHandInSheet(
  BuildContext context, {
  required ChildAssignment assignment,
}) {
  final repository = context.read<AssignmentSubmissionRepository>();
  final picker = context.read<AttachmentPicker>();
  return showAppSheet<DateTime>(
    context,
    title: 'Hand in homework',
    isScrollControlled: true,
    builder: (_) => BlocProvider(
      create: (_) => HandInCubit(
        repository: repository,
        picker: picker,
        childId: assignment.childId,
        taskId: assignment.id,
      ),
      child: _HandInForm(assignment: assignment),
    ),
  );
}

class _HandInForm extends StatefulWidget {
  const _HandInForm({required this.assignment});

  final ChildAssignment assignment;

  @override
  State<_HandInForm> createState() => _HandInFormState();
}

class _HandInFormState extends State<_HandInForm> {
  final _note = TextEditingController();
  final _link = TextEditingController();
  String? _linkError;

  @override
  void dispose() {
    _note.dispose();
    _link.dispose();
    super.dispose();
  }

  void _addLink() {
    final error = context.read<HandInCubit>().addLink(_link.text);
    setState(() => _linkError = error);
    if (error == null) _link.clear();
  }

  Future<void> _confirmAndSubmit(HandInState state) async {
    context.dismissKeyboard();
    final cubit = context.read<HandInCubit>();
    final what = state.isBlank
        ? 'You are handing it in without a note, links or files.'
        : 'Your teacher will see what you added.';
    final ok = await showConfirmDialog(
      context,
      title: 'Hand in this homework?',
      message: "$what You can't change it afterwards in the app.",
      confirmLabel: 'Hand in',
      cancelLabel: 'Not yet',
      destructive: false,
    );
    if (ok) await cubit.submit();
  }

  Future<void> _confirmDiscard() async {
    final discard = await showConfirmDialog(
      context,
      title: 'Discard this hand-in?',
      message: 'What you added will be lost.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep editing',
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HandInCubit, HandInState>(
      listenWhen: (a, b) => !a.done && b.done,
      listener: (context, state) =>
          Navigator.of(context).pop(state.completedAt),
      builder: (context, state) {
        final cubit = context.read<HandInCubit>();
        return PopScope(
          // Leaving is free while nothing was added; never while sending.
          canPop: state.isBlank && !state.busy,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && !state.busy) _confirmDiscard();
          },
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                Text(
                  widget.assignment.title,
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: AppSpacing.md),
                AppFormField(
                  label: 'Note (optional)',
                  child: AppTextField(
                    controller: _note,
                    hint: 'Anything the teacher should know',
                    maxLines: 3,
                    enabled: !state.busy,
                    onChanged: cubit.setNote,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(_maxNoteLength),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _LinksField(
                  controller: _link,
                  links: state.links,
                  error: _linkError,
                  enabled: !state.busy,
                  onAdd: _addLink,
                  onRemove: cubit.removeLink,
                  onChanged: (_) {
                    if (_linkError != null) setState(() => _linkError = null);
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _FilesField(state: state, cubit: cubit),
                if (state.error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _ErrorBox(state.error!),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Hand in',
                  icon: Icons.upload_file_rounded,
                  isLoading: state.busy,
                  onPressed: state.busy ? null : () => _confirmAndSubmit(state),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    state.busy
                        ? state.progressLabel
                        : "You can't change it after handing in.",
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LinksField extends StatelessWidget {
  const _LinksField({
    required this.controller,
    required this.links,
    required this.error,
    required this.enabled,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final TextEditingController controller;
  final List<String> links;
  final String? error;
  final bool enabled;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final full = links.length >= SubmissionRules.maxLinks;
    return AppFormField(
      label: 'Links (optional)',
      error: error,
      trailing: Text(
        '${links.length}/${SubmissionRules.maxLinks}',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: controller,
                  hint: 'Paste a web address',
                  enabled: enabled && !full,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  onChanged: onChanged,
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                tooltip: 'Add link',
                onPressed: enabled && !full ? onAdd : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          for (final link in links)
            _ItemTile(
              icon: Icons.link_rounded,
              title: link,
              trailing: IconButton(
                tooltip: 'Remove link',
                onPressed: enabled ? () => onRemove(link) : null,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilesField extends StatelessWidget {
  const _FilesField({required this.state, required this.cubit});

  final HandInState state;
  final HandInCubit cubit;

  @override
  Widget build(BuildContext context) {
    final enabled = !state.busy && state.canAddFile;
    return AppFormField(
      label: 'Files (optional)',
      hint: 'PDF, Word, Excel, PowerPoint, TXT, JPG, PNG or ZIP · up to 15 MB',
      trailing: Text(
        '${state.files.length}/${SubmissionRules.maxFiles}',
        style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_camera_rounded,
                  label: 'Take photo',
                  onPressed: enabled ? cubit.takePhoto : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SourceButton(
                  icon: Icons.photo_library_rounded,
                  label: 'Photos',
                  onPressed: enabled ? cubit.pickPhotos : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SourceButton(
                  icon: Icons.attach_file_rounded,
                  label: 'Files',
                  onPressed: enabled ? cubit.pickFiles : null,
                ),
              ),
            ],
          ),
          for (final file in state.files)
            _FileTile(
              file: file,
              busy: state.busy,
              onRemove: () => cubit.removeFile(file.id),
            ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.brand.primary,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelMedium),
        ],
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.file,
    required this.busy,
    required this.onRemove,
  });

  final HandInFile file;
  final bool busy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = file.source.name;
    final failed = file.status == UploadStatus.failed;
    return _ItemTile(
      icon: SubmissionRules.isImage(name)
          ? Icons.image_rounded
          : SubmissionRules.extensionOf(name) == 'pdf'
          ? Icons.picture_as_pdf_rounded
          : Icons.description_rounded,
      title: name,
      subtitle: failed ? file.error : formatFileSize(file.source.size),
      subtitleColor: failed ? AppColors.danger : null,
      trailing: switch (file.status) {
        UploadStatus.uploading => const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        UploadStatus.uploaded when busy => const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: AppColors.success,
          ),
        ),
        _ => IconButton(
          tooltip: 'Remove file',
          onPressed: busy ? null : onRemove,
          icon: const Icon(Icons.close_rounded),
        ),
      },
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.subtitleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? subtitleColor;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.only(left: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.brand.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: subtitleColor ?? AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_rounded, size: 18, color: AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
