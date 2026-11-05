import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/widgets/new_feedback_sheet.dart';

/// Opens the teacher ↔ parent conversation for [student].
///
/// Parents are reached through feedback threads (the backend has no free-form
/// teacher → parent chat), so this opens the student's thread when one exists
/// and otherwise starts it with the usual "New feedback" sheet.
Future<void> openStudentChat(BuildContext context, Student student) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final repository = context.read<ChatRepository>();

  void open(String threadId) => router.pushNamed(
    AppRoutes.feedbackChat,
    pathParameters: {'id': threadId},
  );

  final studentId = int.tryParse(student.id);
  if (studentId == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('This student cannot be messaged.')),
    );
    return;
  }
  final threadId = feedbackThreadId(studentId);

  try {
    if (await repository.getThreadById(threadId) != null) {
      open(threadId);
      return;
    }
    if (!context.mounted) return;
    final draft = await showNewFeedbackSheet(
      context,
      parentName: '${student.firstName}’s parent',
      studentId: student.id,
    );
    if (draft == null) return;
    await repository.createFeedbackTopic(
      threadId: threadId,
      subject: draft.subject,
      tone: draft.tone,
      message: draft.message,
    );
    open(threadId);
  } on Object catch (e, st) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(errorMessage(e, st))));
  }
}
