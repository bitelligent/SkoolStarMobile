import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_dropdown.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_selectable_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_model.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/session_header_card.dart';

/// Fourth tab — two cards: "General Feedback" (parent message with
/// positive-tone toggle) and "Assignment Review and Marks" (grade a
/// student for a specific homework).
class FeedbackTab extends StatefulWidget {
  const FeedbackTab({required this.state, super.key});

  final SessionDetailLoaded state;

  @override
  State<FeedbackTab> createState() => _FeedbackTabState();
}

class _FeedbackTabState extends State<FeedbackTab> {
  final _message = TextEditingController();
  final _review = TextEditingController();
  final _marks = TextEditingController(text: '0');

  final Set<String> _recipientIds = {};
  bool _isPositive = true;
  String? _taskId;
  String? _studentId;

  @override
  void initState() {
    super.initState();
    _taskId = widget.state.homeworks.firstOrNull?.id;
  }

  @override
  void dispose() {
    _message.dispose();
    _review.dispose();
    _marks.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final draft = FeedbackMessage(
      id: '',
      sessionId: widget.state.session.id,
      studentIds: _recipientIds.toList(),
      message: _message.text.trim(),
      isPositive: _isPositive,
    );
    final ok = await context.read<SessionDetailCubit>().sendFeedback(draft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Feedback sent to parent' : 'Failed')),
    );
    if (ok) {
      setState(() {
        _message.clear();
        _recipientIds.clear();
      });
    }
  }

  Future<void> _saveReview() async {
    final marks = int.tryParse(_marks.text) ?? 0;
    final draft = AssignmentReview(
      id: '',
      sessionId: widget.state.session.id,
      homeworkId: _taskId ?? '',
      studentId: _studentId ?? '',
      marks: marks.clamp(0, 100),
      reviewText: _review.text.trim(),
    );
    final ok = await context.read<SessionDetailCubit>().saveReview(draft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Review saved' : 'Failed')),
    );
    if (ok) {
      setState(() {
        _review.clear();
        _marks.text = '0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final homeworks = state.homeworks;
    final students = state.students;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SessionHeaderCard(
          session: state.session,
          classes: state.classes,
          subjects: state.subjects,
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- General Feedback ----------
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionTitle(
                title: 'General Feedback',
                icon: Icons.mail_outline_rounded,
                iconColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Recipients',
                required: true,
                hint: 'Feedback is sent to each selected student\'s parent.',
                child: Column(
                  children: [
                    for (final s in students)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: AppSelectableTile(
                          title: '${s.firstName} ${s.lastName}',
                          subtitle: 'Roll ${s.rollNo}',
                          avatarName: '${s.firstName} ${s.lastName}',
                          selected: _recipientIds.contains(s.id),
                          onToggle: () => setState(() {
                            if (_recipientIds.contains(s.id)) {
                              _recipientIds.remove(s.id);
                            } else {
                              _recipientIds.add(s.id);
                            }
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Message',
                required: true,
                child: AppTextField(
                  controller: _message,
                  hint: 'Write your message to the parent...',
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _isPositive
                      ? AppColors.successSoft
                      : AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPositive
                          ? Icons.thumb_up_rounded
                          : Icons.priority_high_rounded,
                      color: _isPositive
                          ? AppColors.success
                          : AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isPositive ? 'Positive feedback' : 'Needs attention',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: _isPositive
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ),
                          Text(
                            _isPositive
                                ? 'Highlighted as a praise.'
                                : 'Highlighted as an area to improve.',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isPositive,
                      onChanged: (v) => setState(() => _isPositive = v),
                      activeColor: AppColors.success,
                      inactiveTrackColor: AppColors.warningSoft,
                      inactiveThumbColor: AppColors.warning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Send to Parent',
                icon: Icons.send_rounded,
                onPressed:
                    _recipientIds.isEmpty || _message.text.trim().isEmpty
                        ? null
                        : _send,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ---------- Assignment Review and Marks ----------
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionTitle(
                title: 'Assignment Review',
                icon: Icons.grading_rounded,
                iconColor: AppColors.accentPurple,
              ),
              const SizedBox(height: AppSpacing.md),
              if (homeworks.isEmpty)
                const AppEmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No homework yet',
                  subtitle:
                      'Create a homework in the Homework tab first, then grade it here.',
                  compact: true,
                )
              else ...[
                AppFormField(
                  label: 'Task',
                  required: true,
                  child: AppDropdown<String>(
                    sheetTitle: 'Pick a task',
                    value: _taskId,
                    options: homeworks
                        .map(
                          (h) => AppOption<String>(
                            id: h.id,
                            label: h.title,
                            icon: Icons.assignment_rounded,
                            color: AppColors.accentPurple,
                            subtitle: 'Max ${h.maxMarks} marks',
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _taskId = v),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppFormField(
                  label: 'Student',
                  required: true,
                  child: AppDropdown<String>(
                    sheetTitle: 'Pick a student',
                    value: _studentId,
                    options: students
                        .map(
                          (s) => AppOption<String>(
                            id: s.id,
                            label: '${s.firstName} ${s.lastName}',
                            icon: Icons.person_rounded,
                            color: AppColors.primary,
                            subtitle: 'Roll ${s.rollNo}',
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _studentId = v),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppFormField(
                  label: 'Marks (0-100)',
                  required: true,
                  child: AppTextField(
                    controller: _marks,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppFormField(
                  label: 'Review for Parent and Student',
                  child: AppTextField(
                    controller: _review,
                    hint: 'Write your review...',
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Save Review',
                  icon: Icons.save_rounded,
                  onPressed: _taskId == null || _studentId == null
                      ? null
                      : _saveReview,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
