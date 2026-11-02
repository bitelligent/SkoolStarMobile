import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/notifications/cubit/notifications_cubit.dart';

import '../../fixtures/fixtures.dart' as fx;
import '../../helpers/fakes.dart';
import '../../helpers/repo_fakes.dart';
import '../chat/chat_fakes.dart';

AppNotification _n(
  int id, {
  NotificationType type = NotificationType.chat,
  String? ref,
  bool read = false,
  int minutesAgo = 0,
}) => AppNotification(
  id: '$id',
  title: 'New message',
  body: 'body $id',
  type: type,
  referenceType: type == NotificationType.chat
      ? 'ChatThread'
      : 'TeacherObservation',
  referenceId: ref,
  isRead: read,
  createdAt: DateTime(2026, 10, 26, 12).subtract(Duration(minutes: minutesAgo)),
);

void main() {
  late FakeNotificationsRepo repo;
  late FakeAuthRepository auth;
  late StreamController<ChatEvent> events;
  late NotificationsCubit cubit;

  NotificationsCubit make({
    Duration poll = const Duration(hours: 1),
    FakeAuthRepository? withAuth,
  }) => NotificationsCubit(
    repository: repo,
    auth: withAuth ?? auth,
    events: events.stream,
    pollInterval: poll,
    debounce: const Duration(milliseconds: 20),
  );

  setUp(() {
    repo = FakeNotificationsRepo([
      _n(5, ref: '3'),
      _n(4, ref: '3', minutesAgo: 5),
      _n(3, type: NotificationType.feedback, ref: '1022', minutesAgo: 9),
      _n(2, ref: '1', read: true, minutesAgo: 30),
    ]);
    auth = FakeAuthRepository(); // active teacher
    events = StreamController.broadcast();
  });

  tearDown(() async {
    await cubit.close();
    await events.close();
  });

  group('badge', () {
    test('loads the unread count at start', () async {
      cubit = make();
      await pump();
      expect(cubit.state.unreadCount, 3);
    });

    test('a failing count keeps the last value and never throws', () async {
      cubit = make();
      await pump();
      repo.error = const NetworkException();
      await cubit.refreshCount();
      expect(cubit.state.unreadCount, 3);
    });

    test('chat events refresh the badge (debounced)', () async {
      cubit = make();
      await pump();
      final before = repo.countCalls;
      repo.items = [_n(9, ref: '3'), ...repo.items];
      events
        ..add(const ChatResync())
        ..add(const ChatResync())
        ..add(const FeedbackListChanged());
      await pump(120);
      expect(repo.countCalls, before + 1);
      expect(cubit.state.unreadCount, 4);
    });

    test('the timer polls while active', () async {
      cubit = make(poll: const Duration(milliseconds: 40));
      await pump();
      final before = repo.countCalls;
      await pump(150);
      expect(repo.countCalls, greaterThan(before));
    });

    test('resume refreshes', () async {
      cubit = make();
      await pump();
      repo.items = [_n(9, ref: '3'), ...repo.items];
      cubit.onResumed();
      await pump();
      expect(cubit.state.unreadCount, 4);
    });

    test('signed out: nothing is fetched', () async {
      await auth.logout();
      cubit = make();
      await pump();
      expect(repo.countCalls, 0);
      expect(cubit.state.unreadCount, 0);
    });

    test('switching role clears and reloads for the new role', () async {
      final parent = AuthContext.fromJson(fx.parentContext);
      final teacher = AuthContext.fromJson(fx.teacherContext);
      final multi = FakeAuthRepository(
        context: teacher,
        contexts: [teacher, parent],
      );
      cubit = make(withAuth: multi);
      await pump();
      expect(cubit.state.unreadCount, 3);

      final seen = <NotificationsState>[];
      final sub = cubit.stream.listen(seen.add);
      repo.items = [_n(8, ref: '9')];
      await multi.selectContext(parent.contextKey);
      await pump();
      await sub.cancel();

      // First the previous role's data is dropped, then the new role's count
      // arrives; the old figure is never shown for the new role.
      expect(seen.first, const NotificationsState());
      expect(seen.last.unreadCount, 1);
      expect(seen.any((s) => s.unreadCount == 3), isFalse);
    });

    test('signing out clears the badge', () async {
      cubit = make();
      await pump();
      await auth.logout();
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.status, NotificationsStatus.idle);
    });
  });

  group('list', () {
    test('load shows the list and the server count', () async {
      cubit = make();
      expect(await cubit.load(), isNull);
      expect(cubit.state.status, NotificationsStatus.loaded);
      expect(cubit.state.items.length, 4);
      expect(cubit.state.unreadCount, 3);
    });

    test('first-load failure is an error state; retry works', () async {
      repo.error = const NetworkException();
      cubit = make();
      await cubit.load();
      expect(cubit.state.status, NotificationsStatus.error);
      expect(cubit.state.error, isNotNull);

      repo.error = null;
      await cubit.load();
      expect(cubit.state.status, NotificationsStatus.loaded);
    });

    test('refresh failure keeps the list and returns the message', () async {
      cubit = make();
      await cubit.load();
      repo.error = const NetworkException();
      final message = await cubit.refresh();
      expect(message, isNotNull);
      expect(cubit.state.status, NotificationsStatus.loaded);
      expect(cubit.state.items.length, 4);
    });

    test('a count change while the list is open reloads the list', () async {
      cubit = make();
      await cubit.load();
      repo.items = [_n(10, ref: '3'), ...repo.items];
      await cubit.refreshCount();
      await pump();
      expect(cubit.state.items.first.id, '10');
    });

    test('load more widens the window up to the server limit', () async {
      repo.items = [for (var i = 1; i <= 120; i++) _n(i, ref: '1')];
      cubit = make();
      await cubit.load();
      expect(cubit.state.items.length, 50);
      expect(cubit.state.hasMore, isTrue);
      await cubit.loadMore();
      expect(cubit.state.items.length, 100);
      await cubit.loadMore();
      expect(cubit.state.items.length, 120);
      expect(cubit.state.hasMore, isFalse);
      expect(repo.listCalls.last.take, 150);
    });

    test('no "more" when everything fits', () async {
      cubit = make();
      await cubit.load();
      expect(cubit.state.hasMore, isFalse);
    });
  });

  group('marking read', () {
    test('mark one: optimistic, count drops, server called', () async {
      cubit = make();
      await cubit.load();
      final f = cubit.markRead('5');
      expect(cubit.state.items.first.isRead, isTrue); // before the answer
      expect(cubit.state.unreadCount, 2);
      expect(await f, isTrue);
      expect(repo.marked, ['5']);
    });

    test('already-read items are a no-op', () async {
      cubit = make();
      await cubit.load();
      expect(await cubit.markRead('2'), isTrue);
      expect(repo.marked, isEmpty);
      expect(cubit.state.unreadCount, 3);
    });

    test('double tap does not double count', () async {
      cubit = make();
      await cubit.load();
      unawaited(cubit.markRead('5'));
      unawaited(cubit.markRead('5'));
      await pump();
      expect(cubit.state.unreadCount, 2);
      expect(repo.marked, ['5']);
    });

    test('failure rolls back', () async {
      cubit = make();
      await cubit.load();
      repo.error = const ServerException();
      expect(await cubit.markRead('5'), isFalse);
      expect(cubit.state.items.first.isRead, isFalse);
      expect(cubit.state.unreadCount, 3);
    });

    test('count never goes negative', () async {
      cubit = make();
      await cubit.load();
      repo.items = []; // server says nothing unread any more
      await cubit.refreshCount();
      await pump();
      await cubit.markRead('5');
      expect(cubit.state.unreadCount, greaterThanOrEqualTo(0));
    });

    test('mark all: optimistic, then confirmed', () async {
      cubit = make();
      await cubit.load();
      final f = cubit.markAllRead();
      expect(cubit.state.unreadCount, 0);
      expect(cubit.state.items.every((n) => n.isRead), isTrue);
      expect(await f, isNull);
      expect(repo.allMarked, 1);
    });

    test('mark all failure restores everything', () async {
      cubit = make();
      await cubit.load();
      repo.error = const NetworkException();
      final message = await cubit.markAllRead();
      expect(message, isNotNull);
      expect(cubit.state.unreadCount, 3);
      expect(cubit.state.items.where((n) => !n.isRead).length, 3);
    });

    test('mark all with nothing unread does nothing', () async {
      repo.items = [_n(1, read: true)];
      cubit = make();
      await cubit.load();
      expect(await cubit.markAllRead(), isNull);
      expect(repo.allMarked, 0);
    });
  });

  group('opening a conversation clears its notifications', () {
    test('only the matching chat thread, not others or other types', () async {
      cubit = make();
      await cubit.load();
      await cubit.markRelatedRead(
        type: NotificationType.chat,
        referenceIds: {'3'},
      );
      expect(repo.marked.toSet(), {'5', '4'});
      expect(cubit.state.unreadCount, 1); // the feedback one remains
    });

    test('feedback ids', () async {
      cubit = make();
      await cubit.load();
      await cubit.markRelatedRead(
        type: NotificationType.feedback,
        referenceIds: {'1022', '999'},
      );
      expect(repo.marked, ['3']);
    });

    test('works before the list was ever opened (fetches unread)', () async {
      cubit = make();
      await pump(); // only the badge is known
      await cubit.markRelatedRead(
        type: NotificationType.chat,
        referenceIds: {'3'},
      );
      expect(repo.marked.toSet(), {'5', '4'});
      expect(repo.listCalls.single.unreadOnly, isTrue);
    });

    test('nothing unread means no request at all', () async {
      repo.items = [_n(1, ref: '3', read: true)];
      cubit = make();
      await cubit.load();
      repo.listCalls.clear();
      await cubit.markRelatedRead(
        type: NotificationType.chat,
        referenceIds: {'3'},
      );
      expect(repo.listCalls, isEmpty);
      expect(repo.marked, isEmpty);
    });

    test('a backlog is cleared in small batches without error', () async {
      repo.items = [for (var i = 1; i <= 23; i++) _n(i, ref: '3')];
      cubit = make();
      await cubit.load();
      await cubit.markRelatedRead(
        type: NotificationType.chat,
        referenceIds: {'3'},
      );
      expect(repo.marked.length, 23);
      expect(cubit.state.unreadCount, 0);
    });

    test('server failure is swallowed (cosmetic)', () async {
      cubit = make();
      await cubit.load();
      repo.error = const NetworkException();
      await expectLater(
        cubit.markRelatedRead(
          type: NotificationType.chat,
          referenceIds: {'3'},
        ),
        completes,
      );
    });
  });
}
