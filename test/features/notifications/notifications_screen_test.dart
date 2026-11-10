import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/router/app_routes.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/chat_perspective.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';
import 'package:skoolstar_teacher_module/features/notifications/view/notifications_screen.dart';
import 'package:skoolstar_teacher_module/features/notifications/widgets/notification_bell.dart';

import '../../helpers/fakes.dart';
import '../../helpers/repo_fakes.dart';
import '../chat/chat_fakes.dart';

AppNotification _n(
  int id, {
  NotificationType type = NotificationType.chat,
  String? ref,
  bool read = false,
  Duration ago = Duration.zero,
  String body = 'hello there',
}) => AppNotification(
  id: '$id',
  title: type == NotificationType.chat ? 'New message' : 'New feedback',
  body: body,
  type: type,
  referenceType: 'x',
  referenceId: ref,
  isRead: read,
  createdAt: DateTime.now().subtract(ago),
);

class _Harness {
  _Harness(this.repo, this.chat, {this.perspective = ChatPerspective.teacher});

  final FakeNotificationsRepo repo;
  final FakeChatRepository chat;
  final ChatPerspective perspective;
  final List<String> pushed = [];
  late NotificationsCubit cubit;

  Future<void> pump(WidgetTester tester, {Size? size}) async {
    if (size != null) {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }
    cubit = NotificationsCubit(
      repository: repo,
      auth: FakeAuthRepository(),
      pollInterval: Duration.zero,
    );
    addTearDown(cubit.close);

    GoRoute dest(String name, String path) => GoRoute(
      path: path,
      name: name,
      builder: (_, state) {
        pushed.add('$name:${state.pathParameters['id']}');
        return Scaffold(
          body: Text('opened $name ${state.pathParameters['id']}'),
        );
      },
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => ChatPerspectiveScope(
            perspective: perspective,
            child: RepositoryProvider<ChatRepository>.value(
              value: chat,
              child: BlocProvider.value(
                value: cubit,
                child: const NotificationsScreen(),
              ),
            ),
          ),
        ),
        dest(AppRoutes.directChat, '/chat/direct/:id'),
        dest(AppRoutes.feedbackChat, '/chat/feedback/:id'),
        dest(AppRoutes.parentDirectChat, '/parent/chat/direct/:id'),
        dest(AppRoutes.parentFeedbackChat, '/parent/chat/feedback/:id'),
        dest(AppRoutes.parentLeave, '/parent/leave'),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('shows grouped notifications with unread styling', (
    tester,
  ) async {
    final repo = FakeNotificationsRepo([
      _n(3, ref: '3', body: 'newest'),
      _n(
        2,
        type: NotificationType.feedback,
        ref: '1022',
        ago: const Duration(days: 1),
      ),
      _n(1, ref: '1', read: true, ago: const Duration(days: 20)),
    ]);
    await _Harness(repo, FakeChatRepository()).pump(tester);

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('2 new notifications'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Yesterday'), findsWidgets); // section + card time
    expect(find.text('Earlier'), findsOneWidget);
    expect(find.text('newest'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
    expect(find.text("You're up to date"), findsOneWidget);
  });

  testWidgets('empty state', (tester) async {
    await _Harness(FakeNotificationsRepo(), FakeChatRepository()).pump(tester);
    expect(find.text('All caught up'), findsOneWidget);
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('load failure offers retry', (tester) async {
    final repo = FakeNotificationsRepo()..error = const NetworkException();
    final h = _Harness(repo, FakeChatRepository());
    await h.pump(tester);
    expect(find.textContaining('connection'), findsWidgets);

    repo
      ..error = null
      ..items = [_n(1, ref: '1')];
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('New message'), findsOneWidget);
  });

  testWidgets('mark all read hides the summary and says so', (tester) async {
    final repo = FakeNotificationsRepo([_n(1, ref: '1'), _n(2, ref: '1')]);
    await _Harness(repo, FakeChatRepository()).pump(tester);
    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('new notification'), findsNothing);
    expect(find.text('All notifications marked as read.'), findsOneWidget);
    expect(find.text('Mark all read'), findsNothing);
    expect(repo.allMarked, 1);
  });

  testWidgets(
    'tapping a chat notification marks it read and opens the thread',
    (
      tester,
    ) async {
      final repo = FakeNotificationsRepo([_n(7, ref: '3')]);
      final h = _Harness(repo, FakeChatRepository());
      await h.pump(tester);
      await tester.tap(find.text('New message'));
      await tester.pumpAndSettle();
      expect(repo.marked, ['7']);
      expect(h.pushed, ['${AppRoutes.directChat}:dm_3']);
      expect(find.text('opened ${AppRoutes.directChat} dm_3'), findsOneWidget);
    },
  );

  testWidgets('parents are taken to the parent routes', (tester) async {
    final repo = FakeNotificationsRepo([_n(7, ref: '3')]);
    final h = _Harness(
      repo,
      FakeChatRepository(),
      perspective: ChatPerspective.parent,
    );
    await h.pump(tester);
    await tester.tap(find.text('New message'));
    await tester.pumpAndSettle();
    expect(h.pushed, ['${AppRoutes.parentDirectChat}:dm_3']);
  });

  testWidgets('a leave notification opens the leave requests, even without a '
      'reference', (tester) async {
    final repo = FakeNotificationsRepo([
      _n(9, type: NotificationType.leave),
    ]);
    final h = _Harness(
      repo,
      FakeChatRepository(),
      perspective: ChatPerspective.parent,
    );
    await h.pump(tester);
    await tester.tap(find.text('New feedback'));
    await tester.pumpAndSettle();
    expect(h.pushed, ['${AppRoutes.parentLeave}:null']);
    expect(repo.marked, ['9']);
  });

  testWidgets('a feedback notification resolves its thread first', (
    tester,
  ) async {
    final repo = FakeNotificationsRepo([
      _n(8, type: NotificationType.feedback, ref: '1022'),
    ]);
    final chat = FakeChatRepository()..topicThreads['1022'] = 'fb_2_Tahir';
    final h = _Harness(repo, chat, perspective: ChatPerspective.parent);
    await h.pump(tester);
    await tester.tap(find.text('New feedback'));
    await tester.pumpAndSettle();
    expect(h.pushed, ['${AppRoutes.parentFeedbackChat}:fb_2_Tahir']);
  });

  testWidgets('a deleted feedback explains instead of failing', (tester) async {
    final repo = FakeNotificationsRepo([
      _n(8, type: NotificationType.feedback, ref: '999'),
    ]);
    final h = _Harness(repo, FakeChatRepository());
    await h.pump(tester);
    await tester.tap(find.text('New feedback'));
    await tester.pumpAndSettle();
    expect(h.pushed, isEmpty);
    expect(find.text('This feedback is no longer available.'), findsOneWidget);
    expect(repo.marked, ['8']); // still counted as seen
  });

  testWidgets('a lookup error is shown, not thrown', (tester) async {
    final repo = FakeNotificationsRepo([
      _n(8, type: NotificationType.feedback, ref: '5'),
    ]);
    final chat = FakeChatRepository()
      ..failTopicLookup = const NetworkException();
    final h = _Harness(repo, chat);
    await h.pump(tester);
    await tester.tap(find.text('New feedback'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(h.pushed, isEmpty);
  });

  testWidgets('unknown kinds and missing references are harmless', (
    tester,
  ) async {
    final repo = FakeNotificationsRepo([
      _n(1, type: NotificationType.other, ref: '5'),
      _n(2),
    ]);
    final h = _Harness(repo, FakeChatRepository());
    await h.pump(tester);
    await tester.tap(find.text('New message'));
    await tester.pumpAndSettle();
    expect(h.pushed, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed mark-read tells the user and still opens', (
    tester,
  ) async {
    final repo = FakeNotificationsRepo([_n(7, ref: '3')]);
    final h = _Harness(repo, FakeChatRepository());
    await h.pump(tester);
    repo.error = const ServerException();
    await tester.tap(find.text('New message'));
    await tester.pumpAndSettle();
    expect(h.pushed, ['${AppRoutes.directChat}:dm_3']);
  });

  testWidgets('show older appears when more may exist', (tester) async {
    final repo = FakeNotificationsRepo([
      for (var i = 1; i <= 60; i++) _n(i, ref: '1'),
    ]);
    await _Harness(repo, FakeChatRepository()).pump(tester);
    await tester.scrollUntilVisible(
      find.text('Show older'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Show older'));
    await tester.pumpAndSettle();
    expect(find.text("You're up to date"), findsNothing);
  });

  for (final size in const [Size(320, 568), Size(768, 1024)]) {
    testWidgets('no layout errors at ${size.width.toInt()}', (tester) async {
      final repo = FakeNotificationsRepo([
        for (var i = 1; i <= 12; i++)
          _n(
            i,
            ref: '1',
            read: i.isEven,
            ago: Duration(hours: i * 7),
            body:
                'A long message body that must wrap and be cut off '
                'after two lines because notifications stay compact. $i',
          ),
      ]);
      await _Harness(repo, FakeChatRepository()).pump(tester, size: size);
      expect(tester.takeException(), isNull);
      for (var i = 0; i < 4; i++) {
        await tester.drag(find.byType(ListView).first, const Offset(0, -400));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });
  }

  group('bell', () {
    Future<NotificationsCubit> pumpBell(
      WidgetTester tester,
      FakeNotificationsRepo repo,
    ) async {
      final cubit = NotificationsCubit(
        repository: repo,
        auth: FakeAuthRepository(),
        pollInterval: Duration.zero,
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: Scaffold(
              body: Center(child: NotificationBell(onTap: () {})),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      return cubit;
    }

    testWidgets('shows the unread count and updates live', (tester) async {
      final repo = FakeNotificationsRepo([_n(1), _n(2), _n(3)]);
      final cubit = await pumpBell(tester, repo);
      expect(find.text('3'), findsOneWidget);

      await cubit.markRead('1');
      await tester.pump();
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('no badge at zero; 99+ when large', (tester) async {
      final none = FakeNotificationsRepo([_n(1, read: true)]);
      await pumpBell(tester, none);
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('caps at 99+', (tester) async {
      final many = FakeNotificationsRepo([for (var i = 0; i < 120; i++) _n(i)]);
      await pumpBell(tester, many);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('works without any cubit (isolated use)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NotificationBell(onTap: () {})),
        ),
      );
      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    });
  });
}
