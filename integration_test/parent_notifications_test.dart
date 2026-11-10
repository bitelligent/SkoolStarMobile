import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';
import 'package:skoolstar_teacher_module/features/notifications/widgets/notification_bell.dart';

import 'support.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('parent notifications: badge, list, open feedback + chat, '
      'deleted feedback', (tester) async {
    await launchAndSignIn(
      tester,
      email: parentEmail,
      roleLabel: 'Parent',
      homeMarker: find.text('Progress'),
    );
    final bell = find.byType(NotificationBell);
    await pumpUntil(tester, bell);

    // The app-wide cubit (the bell is not on the later screens).
    final cubit = BlocProvider.of<NotificationsCubit>(tester.element(bell));

    // 1. The badge reflects the real unread count.
    final end = DateTime.now().add(const Duration(seconds: 20));
    while (cubit.state.unreadCount == 0) {
      if (DateTime.now().isAfter(end)) fail('badge never loaded');
      await tester.pump(const Duration(milliseconds: 250));
    }
    final before = cubit.state.unreadCount;
    // ignore: avoid_print
    print('UNREAD BEFORE $before');
    await checkpoint(tester, 'notif_home_badge');

    // 2. The list opens from the bell.
    await tester.tap(bell);
    await pumpUntil(tester, find.text('Mark all read'));
    expect(cubit.state.items, isNotEmpty);
    await checkpoint(tester, 'notif_list');

    Finder card(AppNotification n) =>
        find.byKey(ValueKey('notification_${n.id}'));

    Future<void> openCard(AppNotification n) async {
      // The list keeps its scroll position: start from the top each time.
      for (var i = 0; i < 6; i++) {
        await tester.drag(
          find.byType(Scrollable).first,
          const Offset(0, 1500),
        );
        await tester.pump(const Duration(milliseconds: 200));
      }
      await tester.scrollUntilVisible(
        card(n),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(card(n));
    }

    // 3. A feedback notification whose feedback still exists opens its
    //    thread and the badge drops.
    const existing = {'1017', '1018', '1019', '1020', '1021', '1022'};
    // Unread ones are consumed by earlier runs (they really get marked
    // read), so fall back to an already-read one: opening works either way.
    bool isLiveFeedback(AppNotification n) =>
        n.type == NotificationType.feedback && existing.contains(n.referenceId);
    final live = cubit.state.items.firstWhere(
      (n) => isLiveFeedback(n) && !n.isRead,
      orElse: () => cubit.state.items.firstWhere(isLiveFeedback),
    );
    final liveWasUnread = !live.isRead;
    await openCard(live);
    final left = DateTime.now().add(const Duration(seconds: 30));
    while (find.text('Notifications').evaluate().isNotEmpty) {
      if (DateTime.now().isAfter(left))
        fail('feedback notification did not open');
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pump(const Duration(seconds: 3));
    await checkpoint(tester, 'notif_opened_feedback_thread');

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await pumpUntil(tester, find.text('Notifications'));
    await tester.pump(const Duration(seconds: 3));
    final afterFeedback = cubit.state.unreadCount;
    // ignore: avoid_print
    print('UNREAD AFTER FEEDBACK $afterFeedback');
    expect(
      afterFeedback,
      liveWasUnread ? lessThan(before) : lessThanOrEqualTo(before),
    );
    expect(cubit.state.items.firstWhere((n) => n.id == live.id).isRead, isTrue);

    // 4. A chat notification opens the 1-to-1 thread.
    final chat = cubit.state.items.firstWhere(
      (n) => n.type == NotificationType.chat && !n.isRead,
      orElse: () => cubit.state.items.firstWhere(
        (n) => n.type == NotificationType.chat,
      ),
    );
    final chatWasUnread = !chat.isRead;
    await openCard(chat);
    final left2 = DateTime.now().add(const Duration(seconds: 30));
    while (find.text('Notifications').evaluate().isNotEmpty) {
      if (DateTime.now().isAfter(left2)) fail('chat notification did not open');
      await tester.pump(const Duration(milliseconds: 250));
    }
    await pumpUntil(tester, find.byIcon(Icons.send_rounded));
    await tester.pump(const Duration(seconds: 3));
    await checkpoint(tester, 'notif_opened_chat');
    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await pumpUntil(tester, find.text('Notifications'));
    await tester.pump(const Duration(seconds: 3));
    final afterChat = cubit.state.unreadCount;
    // ignore: avoid_print
    print('UNREAD AFTER CHAT $afterChat');
    expect(
      afterChat,
      chatWasUnread
          ? lessThan(afterFeedback)
          : lessThanOrEqualTo(afterFeedback),
    );

    // 5. Feedback that was deleted since: explains, does not break.
    final gone = cubit.state.items.firstWhere(
      (n) =>
          n.type == NotificationType.feedback &&
          n.referenceId != null &&
          !existing.contains(n.referenceId) &&
          int.parse(n.referenceId!) >= 1030,
    );
    await openCard(gone);
    await tester.pump(const Duration(seconds: 2));
    await checkpoint(tester, 'notif_deleted_feedback');
    expect(find.text('This feedback is no longer available.'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget); // still on the list
  });
}
