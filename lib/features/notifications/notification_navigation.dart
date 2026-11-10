import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/network/error_message.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/features/chat/chat_perspective.dart';

/// Opens what a notification is about: the 1-to-1 chat or the feedback thread,
/// in the module of the signed-in role. Unknown kinds do nothing.
Future<void> openNotification(
  BuildContext context,
  AppNotification n,
) async {
  final perspective = ChatPerspectiveScope.of(context);
  if (n.type == NotificationType.leave) {
    // Leave is a parent feature; the list itself shows the updated request.
    if (perspective.isParent) await context.pushNamed(AppRoutes.parentLeave);
    return;
  }
  final refId = n.referenceId;
  if (refId == null || refId.isEmpty) return;

  switch (n.type) {
    case NotificationType.chat:
      final serverId = int.tryParse(refId);
      if (serverId == null) return;
      await context.pushNamed(
        perspective.directRouteName,
        pathParameters: {'id': directThreadId(serverId)},
      );
    case NotificationType.feedback:
      final repo = context.read<ChatRepository>();
      final messenger = ScaffoldMessenger.maybeOf(context);
      final String? threadId;
      try {
        threadId = await repo.feedbackThreadIdFor(refId);
      } on Object catch (e, st) {
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage(e, st))));
        return;
      }
      if (!context.mounted) return;
      if (threadId == null) {
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('This feedback is no longer available.'),
            ),
          );
        return;
      }
      await context.pushNamed(
        perspective.feedbackRouteName,
        pathParameters: {'id': threadId},
      );
    case NotificationType.leave:
    case NotificationType.other:
      return;
  }
}
