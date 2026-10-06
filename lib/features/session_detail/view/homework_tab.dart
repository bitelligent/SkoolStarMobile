import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:skoolstar_teacher_module/core/theme/app_colors.dart';
import 'package:skoolstar_teacher_module/core/theme/app_spacing.dart';
import 'package:skoolstar_teacher_module/core/theme/app_text_styles.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_card.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_chip.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_dropdown.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_empty_state.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_form_field.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_selectable_tile.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_sheet.dart';
import 'package:skoolstar_teacher_module/core/widgets/app_upload_box.dart';
import 'package:skoolstar_teacher_module/core/widgets/primary_button.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_cubit.dart';
import 'package:skoolstar_teacher_module/features/session_detail/cubit/session_detail_state.dart';
import 'package:skoolstar_teacher_module/features/session_detail/widgets/session_header_card.dart';

/// Third tab — Create Homework form plus a list of previously assigned
/// homework. Uses the shared [AppFormField], [AppTextField], [AppDropdown]
/// and [AppUploadBox] widgets so there's no inline boilerplate.
class HomeworkTab extends StatefulWidget {
  const HomeworkTab({required this.state, super.key});

  final SessionDetailLoaded state;

  @override
  State<HomeworkTab> createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _maxMarks = TextEditingController(text: '100');

  String? _classId;
  String? _subjectId;
  DateTime? _deadlineDate;
  TimeOfDay? _deadlineTime;
  final Set<String> _selectedStudents = {};
  final List<HomeworkAttachment> _attachments = [];

  @override
  void initState() {
    super.initState();
    _classId = widget.state.session.classIds.firstOrNull;
    _subjectId = widget.state.session.subjectIds.firstOrNull;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _maxMarks.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }

  List<Student> get _studentsForClass => widget.state.students
      .where((s) => _classId == null || s.classGroupId == _classId)
      .toList();

  bool get _canSubmit =>
      _title.text.trim().isNotEmpty &&
      _classId != null &&
      _subjectId != null &&
      _selectedStudents.isNotEmpty;

  Future<void> _assign() async {
    final deadline = _deadlineDate == null
        ? DateTime.now().add(const Duration(days: 1))
        : DateTime(
            _deadlineDate!.year,
            _deadlineDate!.month,
            _deadlineDate!.day,
            _deadlineTime?.hour ?? 23,
            _deadlineTime?.minute ?? 59,
          );
    final maxMarks = int.tryParse(_maxMarks.text) ?? 100;
    final draft = Homework(
      id: '',
      sessionId: widget.state.session.id,
      classId: _classId!,
      subjectId: _subjectId!,
      title: _title.text.trim(),
      description: _description.text.trim(),
      deadline: deadline,
      maxMarks: maxMarks.clamp(0, 100),
      assignedStudentIds: _selectedStudents.toList(),
      attachments: _attachments,
    );
    final ok =
        await context.read<SessionDetailCubit>().createHomework(draft);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Homework assigned' : 'Failed')),
    );
    if (ok) {
      setState(() {
        _title.clear();
        _description.clear();
        _maxMarks.text = '100';
        _deadlineDate = null;
        _deadlineTime = null;
        _selectedStudents.clear();
        _attachments.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final classOptions = state.classes
        .where((c) => state.session.classIds.contains(c.id))
        .map(
          (c) => AppOption<String>(
            id: c.id,
            label: c.name,
            icon: Icons.groups_rounded,
            color: _parseHex(c.colorHex),
          ),
        )
        .toList();

    final subjectOptions = state.subjects
        .where((s) => state.session.subjectIds.contains(s.id))
        .map(
          (s) => AppOption<String>(
            id: s.id,
            label: s.name,
            icon: Icons.menu_book_rounded,
            color: _parseHex(s.colorHex),
          ),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SessionHeaderCard(
          session: state.session,
          classes: state.classes,
          subjects: state.subjects,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionTitle(
                title: 'Create Homework',
                icon: Icons.assignment_rounded,
                iconColor: AppColors.accentPurple,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppFormField(
                      label: 'Class',
                      required: true,
                      child: AppDropdown<String>(
                        sheetTitle: 'Pick a class',
                        value: _classId,
                        options: classOptions,
                        onChanged: (v) => setState(() {
                          _classId = v;
                          _selectedStudents.clear();
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppFormField(
                      label: 'Subject',
                      required: true,
                      child: AppDropdown<String>(
                        sheetTitle: 'Pick a subject',
                        value: _subjectId,
                        options: subjectOptions,
                        onChanged: (v) => setState(() => _subjectId = v),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Title',
                required: true,
                child: AppTextField(
                  controller: _title,
                  hint: 'eg. Chapter 3 — practice problems',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Description',
                child: AppTextField(
                  controller: _description,
                  hint: 'Instructions for students...',
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppFormField(
                      label: 'Deadline',
                      child: AppDateField(
                        value: _deadlineDate,
                        onChanged: (d) => setState(() => _deadlineDate = d),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppFormField(
                      label: 'Time',
                      child: AppTimeField(
                        value: _deadlineTime,
                        onChanged: (t) => setState(() => _deadlineTime = t),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Maximum marks',
                hint: 'Total score for this assignment (0-100).',
                required: true,
                child: AppTextField(
                  controller: _maxMarks,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Attachments',
                hint:
                    'PDF, DOC, XLS, PPT, TXT, JPG, PNG, ZIP · max 15MB · up to 5 files',
                child: Column(
                  children: [
                    AppUploadBox(
                      title: 'Tap to upload files',
                      subtitle: 'From your device',
                      onTap: _attachments.length >= 5
                          ? () {}
                          : () => setState(() => _attachments.add(
                                HomeworkAttachment(
                                  fileName:
                                      'file_${_attachments.length + 1}.pdf',
                                  sizeKb: 128,
                                  type: 'pdf',
                                ),
                              )),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._attachments.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: AppFileTile(
                          fileName: a.fileName,
                          sizeKb: a.sizeKb,
                          onRemove: () =>
                              setState(() => _attachments.remove(a)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                label: 'Students',
                required: true,
                hint: 'Homework is assigned only to selected students.',
                trailing: TextButton.icon(
                  onPressed: _studentsForClass.isEmpty
                      ? null
                      : () => setState(() {
                            if (_selectedStudents.length ==
                                _studentsForClass.length) {
                              _selectedStudents.clear();
                            } else {
                              _selectedStudents
                                ..clear()
                                ..addAll(_studentsForClass.map((s) => s.id));
                            }
                          }),
                  icon: const Icon(Icons.select_all_rounded, size: 14),
                  label: Text(
                    _selectedStudents.length == _studentsForClass.length &&
                            _studentsForClass.isNotEmpty
                        ? 'Clear all'
                        : 'Select all',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    for (final s in _studentsForClass)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: AppSelectableTile(
                          title: '${s.firstName} ${s.lastName}',
                          subtitle: 'Roll ${s.rollNo}',
                          avatarName: '${s.firstName} ${s.lastName}',
                          selected: _selectedStudents.contains(s.id),
                          onToggle: () => setState(() {
                            if (_selectedStudents.contains(s.id)) {
                              _selectedStudents.remove(s.id);
                            } else {
                              _selectedStudents.add(s.id);
                            }
                          }),
                        ),
                      ),
                    if (_studentsForClass.isEmpty)
                      const AppEmptyState(
                        icon: Icons.person_off_outlined,
                        title: 'Pick a class first',
                        compact: true,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Assign Task',
                icon: Icons.rocket_launch_rounded,
                onPressed: _canSubmit ? _assign : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSectionTitle(
                title: 'Assigned homework',
                icon: Icons.assignment_turned_in_rounded,
                iconColor: AppColors.success,
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${state.homeworks.length}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (state.homeworks.isEmpty)
                const AppEmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No homework yet',
                  subtitle: 'Tasks you assign will appear here.',
                  compact: true,
                )
              else
                ...state.homeworks.map(
                  (hw) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HomeworkTile(homework: hw),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeworkTile extends StatelessWidget {
  const _HomeworkTile({required this.homework});

  final Homework homework;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(homework.title, style: AppTextStyles.titleSmall),
              ),
              AppChip(
                label: '${homework.maxMarks} marks',
                color: AppColors.accentPurple,
                dense: true,
              ),
            ],
          ),
          if (homework.description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              homework.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: AppColors.iconSubtle,
              ),
              const SizedBox(width: 4),
              Text(
                'Due ${DateFormat('MMM d, h:mm a').format(homework.deadline)}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.people_outline_rounded,
                size: 12,
                color: AppColors.iconSubtle,
              ),
              const SizedBox(width: 4),
              Text(
                '${homework.assignedStudentIds.length} students',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
