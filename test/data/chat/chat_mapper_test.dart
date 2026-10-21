import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/mappers/chat_mapper.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';

// Shapes captured from the live API.
const _threadJson = {
  'threadId': 1,
  'peerUserId': '758a18d3',
  'peerName': 'Muhammad Amir',
  'peerAvatarUrl': null,
  'peerOnline': true,
  'relationshipTag': 'Irha Shahzadi',
  'studentId': 3,
  'studentName': 'Irha Shahzadi',
  'lastMessageSnippet': 'hey brother',
  'lastMessageAt': '2026-10-12T16:02:58.9996390Z',
  'unreadCount': 2,
  'lastOutboundRead': true,
};

Map<String, dynamic> _row({
  int id = 1022,
  int studentId = 2,
  String student = 'Jannat Shahzadi',
  String parentName = 'Muhammad Amir',
  String subject = 'Positive feedback',
  bool isPositive = true,
  bool isResolved = false,
  int unread = 0,
  List<Map<String, dynamic>>? messages,
}) => {
  'feedbackId': id,
  'studentId': studentId,
  'studentName': student,
  'parentName': parentName,
  'teacherMessage': 'test test',
  'isPositive': isPositive,
  'subject': subject,
  'tone': isPositive ? 'Positive' : 'Note',
  'isResolved': isResolved,
  'unreadCount': unread,
  'teacherSentAt': '2026-10-13T13:42:52.6631702',
  'messages':
      messages ??
      [
        {
          'id': 32,
          'senderRole': 1,
          'body': 'test test',
          'sentAt': '2026-10-13T13:42:52.6631702',
          'senderName': 'Tahir Mughal',
        },
      ],
};

void main() {
  group('thread ids', () {
    test('direct round trip', () {
      expect(directThreadId(12), 'dm_12');
      expect(serverDirectThreadId('dm_12'), 12);
      expect(serverDirectThreadId('fb_12'), isNull);
      expect(serverDirectThreadId('dm_x'), isNull);
    });

    test('feedback round trip, with and without teacher', () {
      expect(feedbackThreadId(2), 'fb_2');
      expect(parseFeedbackThreadId('fb_2')!.studentId, 2);
      expect(parseFeedbackThreadId('fb_2')!.teacherKey, isNull);

      final id = feedbackThreadId(2, teacherKey: 'Tahir Mughal_Jr/1');
      final parsed = parseFeedbackThreadId(id)!;
      expect(parsed.studentId, 2);
      expect(parsed.teacherKey, 'Tahir Mughal_Jr/1');
      expect(parseFeedbackThreadId('dm_1'), isNull);
    });
  });

  group('parseServerTime', () {
    test('a value without a zone is UTC, like the ones with Z', () {
      final bare = parseServerTime('2026-10-13T13:49:06.2169506');
      final zoned = parseServerTime('2026-10-13T13:49:06.2169506Z');
      expect(bare.isAtSameMomentAs(zoned), isTrue);
      expect(bare.toUtc().hour, 13);
    });

    test('offsets and garbage', () {
      expect(
        parseServerTime('2026-10-13T15:00:00+02:00').toUtc().hour,
        13,
      );
      expect(parseServerTime('nope').millisecondsSinceEpoch, 0);
      expect(parseServerTime(null, fallback: DateTime(2020)), DateTime(2020));
    });
  });

  group('direct chat', () {
    test('thread', () {
      final t = directThreadFromJson(_threadJson)!;
      expect(t.id, 'dm_1');
      expect(t.name, 'Muhammad Amir');
      expect(t.role, 'Irha Shahzadi');
      expect(t.category, ChatCategory.oneToOne);
      expect(t.unreadCount, 2);
      expect(t.isOnline, isTrue);
      expect(t.outgoingLast, isTrue);
      expect(t.peerUserId, '758a18d3');
    });

    test('thread without id is dropped', () {
      expect(directThreadFromJson({'peerName': 'x'}), isNull);
    });

    test('own messages are those not sent by the peer', () {
      const fromPeer = {
        'id': 4,
        'senderUserId': '758a18d3',
        'body': 'hi',
        'sentAt': '2026-10-07T14:48:52.1670919',
      };
      const fromMe = {
        'id': 5,
        'senderUserId': '7f84ee65',
        'body': 'yo',
        'sentAt': '2026-10-07T14:49:08.751635',
      };
      // Teacher view: peer is the parent.
      final t1 = directMessageFromJson(
        fromPeer,
        threadId: 'dm_1',
        peerUserId: '758a18d3',
        asParent: false,
      )!;
      final t2 = directMessageFromJson(
        fromMe,
        threadId: 'dm_1',
        peerUserId: '758a18d3',
        asParent: false,
      )!;
      expect(t1.fromTeacher, isFalse);
      expect(t2.fromTeacher, isTrue);

      // Parent view: peer is the teacher; "mine" means not fromTeacher.
      final p1 = directMessageFromJson(
        fromPeer,
        threadId: 'dm_1',
        peerUserId: '758a18d3',
        asParent: true,
      )!;
      final p2 = directMessageFromJson(
        fromMe,
        threadId: 'dm_1',
        peerUserId: '758a18d3',
        asParent: true,
      )!;
      expect(p1.fromTeacher, isTrue);
      expect(p2.fromTeacher, isFalse);
    });

    test('a message without id or body is dropped', () {
      expect(
        directMessageFromJson(
          {'body': 'x'},
          threadId: 'dm_1',
          peerUserId: 'p',
          asParent: false,
        ),
        isNull,
      );
    });
  });

  group('feedback', () {
    test('topic maps tone, subject, resolved and messages', () {
      final t = feedbackTopicFromJson(
        _row(
          isPositive: false,
          subject: 'Math',
          isResolved: true,
          messages: [
            {
              'id': 2,
              'senderRole': 2,
              'body': 'thanks',
              'sentAt': '2026-10-13T14:00:00',
            },
            {
              'id': 1,
              'senderRole': 1,
              'body': 'hello',
              'sentAt': '2026-10-13T13:00:00',
            },
          ],
        ),
        threadId: 'fb_2',
        asParent: false,
      )!;
      expect(t.id, '1022');
      expect(t.subject, 'Math');
      expect(t.tone, FeedbackTone.needsAttention);
      expect(t.isResolved, isTrue);
      // Sorted oldest first, roles mapped.
      expect(t.messages.map((m) => m.content), ['hello', 'thanks']);
      expect(t.messages.map((m) => m.fromTeacher), [true, false]);
    });

    test('a blank subject falls back to a readable label', () {
      final t = feedbackTopicFromJson(
        _row(subject: ''),
        threadId: 'fb_2',
        asParent: true,
      )!;
      expect(t.subject, 'Positive feedback');
    });

    test('unread count marks the newest messages of the other side', () {
      final msgs = [
        for (var i = 1; i <= 4; i++)
          {
            'id': i,
            'senderRole': i.isOdd ? 1 : 2,
            'body': 'm$i',
            'sentAt': '2026-10-13T13:0$i:00',
          },
      ];
      // Teacher view: parent messages are 2 and 4; 1 unread -> only #4.
      final teacher = feedbackTopicFromJson(
        _row(unread: 1, messages: msgs),
        threadId: 'fb_2',
        asParent: false,
      )!;
      expect(teacher.unreadFromParent, 1);
      expect(teacher.messages.last.isRead, isFalse);
      expect(teacher.messages[1].isRead, isTrue);

      // Parent view: teacher messages are 1 and 3; 2 unread -> both.
      final parent = feedbackTopicFromJson(
        _row(unread: 2, messages: msgs),
        threadId: 'fb_2',
        asParent: true,
      )!;
      expect(parent.unreadFromTeacher, 2);
    });

    test('no messages array falls back to the teacher message', () {
      final row = _row()..['messages'] = <Object>[];
      final t = feedbackTopicFromJson(row, threadId: 'fb_2', asParent: false)!;
      expect(t.messages.single.content, 'test test');
      expect(t.messages.single.fromTeacher, isTrue);
    });

    test('teacher threads group by student, newest first', () {
      final threads = feedbackThreadsFromRows([
        _row(id: 1, studentId: 2),
        _row(
          id: 2,
          studentId: 3,
          student: 'Irha Shahzadi',
          parentName: '',
          unread: 1,
          messages: [
            {
              'id': 9,
              'senderRole': 2,
              'body': 'reply',
              'sentAt': '2026-10-14T10:00:00',
            },
          ],
        ),
        _row(id: 3, studentId: 2),
      ], asParent: false);

      expect(threads.map((t) => t.id), ['fb_3', 'fb_2']);
      final irha = threads.first;
      expect(irha.name, 'Irha Shahzadi’s parent'); // no parent name given
      expect(irha.role, 'Parent · Irha Shahzadi');
      expect(irha.unreadCount, 1);
      expect(irha.lastMessage, 'reply');
      expect(threads.last.name, 'Muhammad Amir');
    });

    test('parent threads group by student and teacher', () {
      Map<String, dynamic> row(int id, String teacher) => _row(
        id: id,
        messages: [
          {
            'id': id,
            'senderRole': 1,
            'body': 'hi',
            'sentAt': '2026-10-13T13:00:00',
            'senderName': teacher,
          },
        ],
      );
      final threads = feedbackThreadsFromRows([
        row(1, 'Tahir Mughal'),
        row(2, 'Tahir Mughal'),
        row(3, 'Sara Khan'),
      ], asParent: true);
      expect(threads.length, 2);
      expect(
        threads.map((t) => t.name),
        containsAll(['Tahir Mughal', 'Sara Khan']),
      );
      expect(threads.first.role, 'Teacher · Jannat Shahzadi');
    });

    test('server tone mapping only uses values the backend understands', () {
      expect(toneToServer(FeedbackTone.positive), 'Positive');
      expect(toneToServer(FeedbackTone.needsAttention), 'Note');
      expect(toneToServer(FeedbackTone.neutral), 'Note');
    });
  });
}
