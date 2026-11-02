import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';
import 'package:skoolstar_teacher_module/features/notifications/widgets/notification_bell.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('teacher notifications: bell badge, list, open chat', (
    tester,
  ) async {
    await launchAndSignIn(
      tester,
      email: teacherEmail,
      roleLabel: 'Teacher',
      homeMarker: find.byType(NotificationBell),
    );
    final bell = find.byType(NotificationBell);
    await pumpUntil(tester, bell);
    final cubit = BlocProvider.of<NotificationsCubit>(tester.element(bell));

    final end = DateTime.now().add(const Duration(seconds: 20));
    while (cubit.state.unreadCount == 0) {
      if (DateTime.now().isAfter(end)) fail('badge never loaded');
      await tester.pump(const Duration(milliseconds: 250));
    }
    // ignore: avoid_print
    print('TEACHER UNREAD ${cubit.state.unreadCount}');
    await checkpoint(tester, 'teacher_home_bell');

    await tester.tap(bell);
    await pumpUntil(tester, find.text('Mark all read'));
    await checkpoint(tester, 'teacher_notif_list');
    expect(cubit.state.items, isNotEmpty);

    // Opening a chat notification goes to the teacher's 1-to-1 screen.
    final chat = cubit.state.items.first;
    await tester.tap(find.byKey(ValueKey('notification_${chat.id}')));
    await pumpUntil(tester, find.byIcon(Icons.send_rounded));
    await checkpoint(tester, 'teacher_notif_opened_chat');
  });
}
