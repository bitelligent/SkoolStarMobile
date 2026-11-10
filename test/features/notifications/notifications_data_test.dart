import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/utils/time_ago.dart';
import 'package:skoolstar_teacher_module/data/models/app_notification.dart';
import 'package:skoolstar_teacher_module/data/repositories/notifications_repository.dart';

import '../../helpers/fakes.dart';

// Payloads as returned by the live API.
const _chat = {
  'id': 77,
  'title': 'New message',
  'body': 'how are you doing',
  'type': 'chat',
  'referenceType': 'ChatThread',
  'referenceId': '3',
  'isRead': false,
  'createdAt': '2026-10-21T11:34:23.5785489',
};

void main() {
  group('AppNotification.fromJson', () {
    test('maps the documented payload', () {
      final n = AppNotification.fromJson(_chat)!;
      expect(n.id, '77');
      expect(n.title, 'New message');
      expect(n.type, NotificationType.chat);
      expect(n.referenceId, '3');
      expect(n.isRead, isFalse);
      // A time without a zone is UTC, like the other API timestamps.
      expect(n.createdAt.toUtc().hour, 11);
    });

    test('feedback and unknown types', () {
      expect(
        AppNotification.fromJson({
          ..._chat,
          'type': 'feedback',
          'referenceType': 'TeacherObservation',
        })!.type,
        NotificationType.feedback,
      );
      expect(
        AppNotification.fromJson({..._chat, 'type': 'billing'})!.type,
        NotificationType.other,
      );
      for (final json in [
        {..._chat, 'type': 'LeaveApplication'},
        {..._chat, 'type': 'General', 'referenceType': 'LeaveApplication'},
      ]) {
        expect(AppNotification.fromJson(json)!.type, NotificationType.leave);
      }
      expect(
        AppNotification.fromJson({..._chat, 'type': 'CHAT'})!.type,
        NotificationType.chat,
      );
    });

    test('missing fields degrade gracefully; no id means unusable', () {
      final n = AppNotification.fromJson({'id': 1})!;
      expect(n.title, 'Notification');
      expect(n.body, '');
      expect(n.referenceId, isNull);
      expect(AppNotification.fromJson({'title': 'x'}), isNull);
    });

    test('emoji and newlines survive', () {
      final n = AppNotification.fromJson({..._chat, 'body': 'a\nb 😃'})!;
      expect(n.body, 'a\nb 😃');
    });
  });

  group('NotificationsRepositoryImpl', () {
    late List<http.Request> requests;

    NotificationsRepositoryImpl build(
      http.Response Function(http.Request) handler,
    ) {
      requests = [];
      return NotificationsRepositoryImpl(
        ApiClient(
          baseUrl: 'https://api.test',
          httpClient: MockClient((r) async {
            requests.add(r);
            return handler(r);
          }),
        ),
      );
    }

    test('list sends take (and unreadOnly only when asked)', () async {
      final repo = build((_) => jsonResponse([_chat]));
      final all = await repo.getNotifications(take: 20);
      expect(all.single.id, '77');
      expect(requests.last.url.path, '/api/Notifications');
      expect(requests.last.url.queryParameters, {'take': '20'});

      await repo.getNotifications(unreadOnly: true, take: 5);
      expect(requests.last.url.queryParameters, {
        'unreadOnly': 'true',
        'take': '5',
      });
    });

    test('take is clamped to the server maximum', () async {
      final repo = build((_) => jsonResponse([]));
      await repo.getNotifications(take: 5000);
      expect(requests.last.url.queryParameters['take'], '200');
      await repo.getNotifications(take: 0);
      expect(requests.last.url.queryParameters['take'], '1');
    });

    test('rows without an id are skipped', () async {
      final repo = build(
        (_) => jsonResponse([
          _chat,
          {'title': 'broken'},
        ]),
      );
      expect((await repo.getNotifications()).length, 1);
    });

    test('unread count', () async {
      final repo = build((_) => jsonResponse({'count': 36}));
      expect(await repo.unreadCount(), 36);
      expect(requests.last.url.path, '/api/Notifications/unread-count');
    });

    test('unexpected body counts as zero', () async {
      final repo = build((_) => jsonResponse('nope'));
      expect(await repo.unreadCount(), 0);
    });

    test('mark one and mark all use POST', () async {
      final repo = build(
        (r) => r.url.path.endsWith('read-all')
            ? jsonResponse({
                'message': 'All notifications marked as read.',
                'count': 5,
              })
            : jsonResponse({'message': 'Marked as read.'}),
      );
      await repo.markRead('77');
      expect(requests.last.method, 'POST');
      expect(requests.last.url.path, '/api/Notifications/77/read');
      expect(await repo.markAllRead(), 5);
      expect(requests.last.url.path, '/api/Notifications/read-all');
    });

    test('errors propagate as typed exceptions', () async {
      final repo = build((_) => jsonResponse({'message': 'x'}, 401));
      await expectLater(
        repo.unreadCount(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('timeAgo / dayBucket', () {
    final now = DateTime(2026, 10, 26, 15, 30);

    test('relative wording', () {
      expect(
        timeAgo(now.subtract(const Duration(seconds: 20)), now),
        'Just now',
      );
      expect(
        timeAgo(now.add(const Duration(minutes: 3)), now),
        'Just now',
      ); // clock skew
      expect(
        timeAgo(now.subtract(const Duration(minutes: 5)), now),
        '5 min ago',
      );
      expect(timeAgo(now.subtract(const Duration(hours: 3)), now), '3 h ago');
      expect(timeAgo(DateTime(2026, 10, 25, 23), now), 'Yesterday');
      expect(timeAgo(DateTime(2026, 10, 22, 9), now), 'Thursday');
      expect(timeAgo(DateTime(2026, 10, 1, 9), now), 'Oct 1');
      expect(timeAgo(DateTime(2025, 3, 4), now), 'Mar 4, 2025');
    });

    test('buckets', () {
      expect(dayBucket(DateTime(2026, 10, 26, 1), now), 'Today');
      expect(dayBucket(DateTime(2026, 10, 25, 23), now), 'Yesterday');
      expect(dayBucket(DateTime(2026, 10, 22), now), 'Earlier this week');
      expect(dayBucket(DateTime(2026, 10, 1), now), 'Earlier');
    });
  });
}
