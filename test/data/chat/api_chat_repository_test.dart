import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/realtime/signalr_connection.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/realtime/chat_realtime.dart';
import 'package:skoolstar_teacher_module/data/repositories/api_chat_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';

import '../../helpers/fakes.dart';

const _threads = [
  {
    'threadId': 1,
    'peerUserId': 'peer-1',
    'peerName': 'Muhammad Amir',
    'peerOnline': false,
    'relationshipTag': 'Irha Shahzadi',
    'studentId': 3,
    'lastMessageSnippet': 'hey',
    'lastMessageAt': '2026-10-12T16:02:58.999Z',
    'unreadCount': 1,
    'lastOutboundRead': false,
  },
];

Map<String, dynamic> _feedback(int id, {int studentId = 2}) => {
  'feedbackId': id,
  'studentId': studentId,
  'studentName': 'Jannat Shahzadi',
  'parentName': 'Muhammad Amir',
  'teacherMessage': 'hello',
  'isPositive': true,
  'subject': 'Subj',
  'isResolved': false,
  'unreadCount': 0,
  'teacherSentAt': '2026-10-13T13:42:52',
  'messages': [
    {
      'id': id * 10,
      'senderRole': 1,
      'body': 'hello',
      'sentAt': '2026-10-13T13:42:52',
      'senderName': 'Tahir Mughal',
    },
  ],
};

void main() {
  late List<http.Request> requests;
  late ChatRealtime realtime;
  late ApiChatRepository repo;

  ApiChatRepository build(
    FutureOr<http.Response> Function(http.Request) handler, {
    bool asParent = false,
  }) {
    requests = [];
    final api = ApiClient(
      baseUrl: 'https://api.test',
      httpClient: MockClient((r) async {
        requests.add(r);
        return handler(r);
      }),
      timeout: const Duration(seconds: 2),
    );
    // Hubs are never started in these tests.
    realtime = ChatRealtime(
      chatHub: SignalRConnection(
        baseUrl: 'http://127.0.0.1:1',
        path: '/hubs/chat',
        accessToken: () => 't',
      ),
      feedbackHub: SignalRConnection(
        baseUrl: 'http://127.0.0.1:1',
        path: '/hubs/feedback-chat',
        accessToken: () => 't',
      ),
    );
    return repo = ApiChatRepository(
      apiClient: api,
      realtime: realtime,
      asParent: asParent,
    );
  }

  tearDown(() async {
    repo.dispose();
    await realtime.dispose();
  });

  http.Response ok(Object? body) => jsonResponse(body);

  group('threads', () {
    test('teacher: direct from /Chat/threads, feedback from history', () async {
      build((r) {
        if (r.url.path == '/api/Chat/threads') return ok(_threads);
        if (r.url.path == '/api/TeacherModule/feedback/history') {
          return ok([_feedback(1022), _feedback(1021, studentId: 3)]);
        }
        return jsonResponse({}, 404);
      });
      final threads = await repo.getThreads();
      expect(
        threads.where((t) => t.category == ChatCategory.oneToOne).single.id,
        'dm_1',
      );
      expect(
        threads
            .where((t) => t.category == ChatCategory.feedback)
            .map((t) => t.id)
            .toSet(),
        {'fb_2', 'fb_3'},
      );
      expect(
        requests.any((r) => r.url.path.endsWith('/feedback/history')),
        isTrue,
      );
    });

    test('parent reads feedback from conversations, not history', () async {
      build((r) {
        if (r.url.path == '/api/Chat/threads') return ok(_threads);
        if (r.url.path == '/api/TeacherModule/feedback/conversations') {
          return ok([_feedback(1022)]);
        }
        return jsonResponse({}, 400);
      }, asParent: true);
      final threads = await repo.getThreads();
      expect(threads.length, 2);
      expect(
        requests.any((r) => r.url.path.endsWith('/feedback/history')),
        isFalse,
      );
      // Parent feedback threads are per student + teacher.
      final fb = threads.firstWhere((t) => t.category == ChatCategory.feedback);
      expect(fb.name, 'Tahir Mughal');
    });

    test('one list failing keeps the other', () async {
      build((r) {
        if (r.url.path == '/api/Chat/threads') return ok(_threads);
        return jsonResponse({'message': 'boom'}, 500);
      });
      final threads = await repo.getThreads();
      expect(threads.single.id, 'dm_1');
    });

    test('both failing surfaces the error', () async {
      build((_) => jsonResponse({'message': 'boom'}, 500));
      await expectLater(repo.getThreads(), throwsA(isA<ServerException>()));
    });

    test('an expired session is not swallowed as a list failure', () async {
      build((_) => jsonResponse({'message': 'no'}, 401));
      await expectLater(
        repo.getThreads(),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('getThreadById loads the list when it is not cached', () async {
      build((r) => r.url.path == '/api/Chat/threads' ? ok(_threads) : ok([]));
      final t = await repo.getThreadById('dm_1');
      expect(t?.peerUserId, 'peer-1');
      expect(await repo.getThreadById('dm_999'), isNull);
    });
  });

  group('direct messages', () {
    test('page request sends both the working and documented params', () async {
      build((r) {
        if (r.url.path == '/api/Chat/threads') return ok(_threads);
        return ok([
          {
            'id': 1,
            'senderUserId': 'peer-1',
            'body': 'a',
            'sentAt': '2026-10-07T14:31:22',
          },
        ]);
      });
      await repo.getThreads();
      final msgs = await repo.getDirectMessagesFor('dm_1');
      expect(msgs.single.content, 'a');

      final q = requests.last.url.queryParameters;
      expect(q['take'], '${ChatRepository.pageSize}');
      expect(q['pageSize'], '${ChatRepository.pageSize}');
      expect(requests.last.url.path, '/api/Chat/threads/1/messages');
    });

    test(
      'an over-long page from the server is trimmed to the newest',
      () async {
        build((r) {
          if (r.url.path == '/api/Chat/threads') return ok(_threads);
          return ok([
            for (var i = 1; i <= 45; i++)
              {
                'id': i,
                'senderUserId': 'peer-1',
                'body': 'm$i',
                'sentAt':
                    '2026-10-07T14:${(i % 60).toString().padLeft(2, '0')}:00',
              },
          ]);
        });
        await repo.getThreads();
        final msgs = await repo.getDirectMessagesFor('dm_1');
        expect(msgs.length, ChatRepository.pageSize);
        expect(msgs.last.id, '45');
      },
    );

    test('older page uses the cursor and ignores anything newer', () async {
      build((r) {
        if (r.url.path == '/api/Chat/threads') return ok(_threads);
        return ok([
          for (var i = 1; i <= 10; i++)
            {
              'id': i,
              'senderUserId': 'peer-1',
              'body': 'm$i',
              'sentAt': '2026-10-07T14:0$i:00',
            },
        ]);
      });
      await repo.getThreads();
      final older = await repo.getOlderDirectMessages(
        'dm_1',
        beforeMessageId: '6',
      );
      expect(requests.last.url.queryParameters['beforeId'], '6');
      expect(requests.last.url.queryParameters['beforeMessageId'], '6');
      // A server that ignores the cursor must not re-add newer messages.
      expect(older.map((m) => m.id), ['1', '2', '3', '4', '5']);
    });

    test('send posts the body and maps messageDto', () async {
      build((r) {
        if (r.method == 'GET') {
          return r.url.path == '/api/Chat/threads' ? ok(_threads) : ok([]);
        }
        expect(jsonDecode(r.body), {'body': 'hello', 'replyToMessageId': null});
        return ok({
          'messageDto': {
            'id': 31,
            'senderUserId': 'me',
            'body': 'hello',
            'sentAt': '2026-10-15T14:55:24.9Z',
          },
        });
      });
      final m = await repo.sendDirectMessage(
        threadId: 'dm_1',
        content: ' hello ',
        fromTeacher: true,
      );
      expect(m.id, '31');
      expect(m.fromTeacher, isTrue);
    });

    test('server validation text reaches the caller', () async {
      build((r) {
        if (r.url.path == '/api/Chat/threads') return ok(_threads);
        return jsonResponse({'message': 'Message body is required.'}, 400);
      });
      await expectLater(
        repo.sendDirectMessage(
          threadId: 'dm_1',
          content: 'x',
          fromTeacher: true,
        ),
        throwsA(
          isA<ValidationException>().having(
            (e) => e.message,
            'message',
            'Message body is required.',
          ),
        ),
      );
    });

    test('a bad thread id is a not-found, not a crash', () async {
      build((_) => ok([]));
      await expectLater(
        repo.getDirectMessagesFor('fb_2'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('mark read posts to the read route and swallows failures', () async {
      build((r) {
        if (r.url.path == '/api/Chat/threads') return ok(_threads);
        return jsonResponse({'message': 'no'}, 500);
      });
      await repo.markDirectThreadRead('dm_1');
      expect(requests.last.url.path, '/api/Chat/threads/1/read');
    });
  });

  group('feedback', () {
    test('topics are fetched per student and filtered to the thread', () async {
      build((r) {
        expect(r.url.queryParameters['studentId'], '2');
        return ok([_feedback(1022), _feedback(1021)]);
      });
      final topics = await repo.getFeedbackTopicsFor('fb_2');
      expect(topics.map((t) => t.id).toSet(), {'1022', '1021'});
    });

    test('create sends tone mapped to what the backend knows', () async {
      build((r) {
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        expect(body['studentId'], 2);
        expect(body['tone'], 'Note');
        expect(body['isPositive'], isFalse);
        return ok({
          'id': 1030,
          'messageDto': {
            'id': 60,
            'senderRole': 1,
            'body': 'Needs work',
            'sentAt': '2026-10-15T10:00:00Z',
          },
        });
      });
      final t = await repo.createFeedbackTopic(
        threadId: 'fb_2',
        subject: 'Math',
        tone: FeedbackTone.needsAttention,
        message: 'Needs work',
      );
      expect(t.id, '1030');
      expect(t.messages.single.id, '60');
      expect(requests.single.url.path, '/api/TeacherModule/feedback/send');
    });

    test('teacher follow-up and parent reply use different routes', () async {
      build(
        (r) => ok({
          'messageDto': {
            'id': 1,
            'senderRole': 1,
            'body': 'x',
            'sentAt': '2026-10-15T10:00:00Z',
          },
        }),
      );
      await repo.replyToTopic(topicId: '7', content: 'hi', fromTeacher: true);
      expect(requests.last.url.path, '/api/TeacherModule/feedback/7/messages');
      repo.dispose();
      await realtime.dispose();

      build(
        (r) => ok({
          'messageDto': {
            'id': 2,
            'senderRole': 2,
            'body': 'x',
            'sentAt': '2026-10-15T10:00:00Z',
          },
        }),
        asParent: true,
      );
      await repo.replyToTopic(topicId: '7', content: 'hi', fromTeacher: false);
      expect(requests.last.url.path, '/api/TeacherModule/feedback/7/reply');
    });

    test('resolve / unresolve follow the cached state', () async {
      build((r) {
        if (r.url.path.endsWith('/history')) return ok([_feedback(1022)]);
        return ok({'message': 'ok'});
      });
      await repo.getFeedbackTopicsFor('fb_2');
      final resolved = await repo.toggleResolved('1022');
      expect(resolved.isResolved, isTrue);
      expect(requests.last.url.path, endsWith('/1022/resolve'));
      final reopened = await repo.toggleResolved('1022');
      expect(reopened.isResolved, isFalse);
      expect(requests.last.url.path, endsWith('/1022/unresolve'));
    });

    test('offline: topics come from the last successful fetch', () async {
      var fail = false;
      build((r) {
        if (fail) return jsonResponse({}, 500);
        return ok([_feedback(1022)]);
      });
      await repo.getFeedbackTopicsFor('fb_2');
      fail = true;
      final again = await repo.getFeedbackTopicsFor('fb_2');
      expect(again.single.id, '1022');
    });

    test('offline with nothing cached is an error', () async {
      build((_) => jsonResponse({}, 500));
      await expectLater(
        repo.getFeedbackTopicsFor('fb_2'),
        throwsA(isA<ServerException>()),
      );
    });

    test(
      'finds the thread of a feedback id (for notification links)',
      () async {
        build((r) {
          if (r.url.path.endsWith('/history')) {
            return ok([_feedback(1022), _feedback(1021, studentId: 3)]);
          }
          return ok([]);
        });
        expect(await repo.feedbackThreadIdFor('1021'), 'fb_3');
        expect(await repo.feedbackThreadIdFor('1022'), 'fb_2'); // cached now
      },
    );

    test('an unknown feedback id is null; offline is null too', () async {
      var fail = false;
      build((r) => fail ? jsonResponse({}, 500) : ok([_feedback(1022)]));
      expect(await repo.feedbackThreadIdFor('555'), isNull);
      fail = true;
      expect(await repo.feedbackThreadIdFor('777'), isNull);
    });

    test('delete calls the soft-delete route', () async {
      build((_) => ok({'message': 'Feedback deleted successfully.'}));
      await repo.deleteTopic('1022');
      expect(requests.single.method, 'DELETE');
      expect(requests.single.url.path, '/api/TeacherModule/feedback/1022');
    });
  });
}
