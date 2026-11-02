import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';

extension NotificationsContext on BuildContext {
  /// The app's notifications cubit, or `null` where there is none (widgets
  /// used in isolation, tests). Does not subscribe to changes.
  NotificationsCubit? get notificationsOrNull {
    try {
      return read<NotificationsCubit>();
    } on Object {
      return null;
    }
  }
}
