import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/feedback_topic.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/feedback_chat_state.dart';

import 'chat_fakes.dart';

FeedbackMessage fm(
  String id,
  String content, {
  bool fromTeacher = true,
  bool isRead = true,
  int minute = 0,
}) => FeedbackMessage(
  id: id,
  fromTeacher: fromTeacher,
  content: content,
  sentAt: DateTime(2026, 10, 1, 9, minute),
  isRead: isRead,
);

FeedbackTopic topic(
  String id, {
  List<FeedbackMessage>? messages,
  bool resolved = false,
  int day = 1,
}) => FeedbackTopic(
  id: id,
  threadId: 'fb_2',
  subject: 'Subject $id',
  tone: FeedbackTone.positive,
  createdAt: DateTime(2026, 10, day),
  messages: messages ?? [fm('m$id', 'first $id')],
  isResolved: resolved,
);

void main() {
  late FakeChatRepository repo;
  late FeedbackChatCubit cubit;

  FeedbackChatLoaded loaded() => cubit.state as FeedbackChatLoaded;
  FeedbackTopic topicOf(String id) =>
      loaded().topics.firstWhere((t) => t.id == id);

  Future<void> boot({
    List<FeedbackTopic>? topics,
    bool asParent = false,
    Duration poll = const Duration(hours: 1),
  }) async {
    repo = FakeChatRepository(
      thread: ChatThread(
        id: 'fb_2',
        name: 'Muhammad Amir',
        category: ChatCategory.feedback,
        lastMessageAt: DateTime(2026, 10, 1),
      ),
    )..topics = topics ?? [topic('10', day: 2), topic('9')];
    cubit = FeedbackChatCubit(
      threadId: 'fb_2',
      repository: repo,
      asParent: asParent,
      pollInterval: poll,
      markReadDelay: const Duration(milliseconds: 10),
    );
    await cubit.load();
  }

  tearDown(() async {
    await cubit.close();
    await repo.dispose();
  });

  test('load watches every topic, expands the newest, marks it read', () async {
    await boot();
    expect(repo.watchedTopics.toSet(), {'10', '9'});
    expect(loaded().expandedTopicIds, {'10'});
    await pump(40);
    expect(repo.topicReads, ['10']);
  });

  test('reply is optimistic and confirmed', () async {
    await boot();
    final hold = repo.holdReply = Completer();
    expect(await cubit.replyToTopic('10', 'Thanks!'), isTrue);

    var last = topicOf('10').messages.last;
    expect(last.status, MessageStatus.sending);
    expect(last.content, 'Thanks!');

    hold.complete(fm('100', 'Thanks!'));
    await pump();
    last = topicOf('10').messages.last;
    expect(last.id, '100');
    expect(last.status, MessageStatus.sent);
    expect(topicOf('10').messages.length, 2);
  });

  test('server limits are enforced locally (2..1000)', () async {
    await boot();
    expect(await cubit.replyToTopic('10', 'x'), isFalse);
    expect(await cubit.replyToTopic('10', ' x '), isFalse);
    expect(await cubit.replyToTopic('10', 'x' * 1001), isFalse);
    expect(await cubit.replyToTopic('missing', 'okay'), isFalse);
    expect(repo.replyCount, 0);
    expect(await cubit.replyToTopic('10', 'ok'), isTrue);
  });

  test('push echo before the answer does not duplicate', () async {
    await boot();
    final hold = repo.holdReply = Completer();
    await cubit.replyToTopic('10', 'Thanks!');

    final server = fm('101', 'Thanks!');
    repo.controller.add(FeedbackMessageReceived('10', server));
    await pump();
    expect(topicOf('10').messages.length, 2);

    hold.complete(server);
    await pump();
    expect(topicOf('10').messages.length, 2);
    expect(topicOf('10').messages.last.status, MessageStatus.sent);
  });

  test('live message from the other side lands in its topic', () async {
    await boot();
    repo.controller.add(
      FeedbackMessageReceived(
        '10',
        fm('50', 'parent says hi', fromTeacher: false, isRead: false),
      ),
    );
    await pump(60);
    expect(topicOf('10').messages.last.content, 'parent says hi');
    // The topic is open, so it is marked read and the flag cleared.
    expect(repo.topicReads, contains('10'));
    expect(topicOf('10').messages.last.isRead, isTrue);
  });

  test('duplicate pushes are merged by id', () async {
    await boot();
    final m = fm('50', 'once', fromTeacher: false);
    repo.controller
      ..add(FeedbackMessageReceived('10', m))
      ..add(FeedbackMessageReceived('10', m));
    await pump();
    expect(topicOf('10').messages.where((x) => x.id == '50').length, 1);
  });

  test('a push for an unknown topic is ignored', () async {
    await boot();
    repo.controller.add(FeedbackMessageReceived('999', fm('1', 'x')));
    await pump();
    expect(loaded().topics.length, 2);
  });

  test('failed reply: retry, and no duplicate if it had arrived', () async {
    await boot();
    repo.failReplyWith = networkError;
    await cubit.replyToTopic('10', 'Thanks!');
    await pump();
    var m = topicOf('10').messages.last;
    expect(m.status, MessageStatus.failed);

    // The send did reach the server; only the answer was lost.
    repo.topics = [
      topic(
        '10',
        day: 2,
        messages: [
          fm('m10', 'first 10'),
          FeedbackMessage(
            id: '200',
            fromTeacher: true,
            content: 'Thanks!',
            sentAt: DateTime.now(),
          ),
        ],
      ),
      topic('9'),
    ];
    final before = repo.replyCount;
    cubit.retryReply('10', m.clientId!);
    await pump();

    expect(repo.replyCount, before);
    expect(topicOf('10').messages.length, 2);
    expect(topicOf('10').messages.last.id, '200');
  });

  test('failed reply retried normally when it did not arrive', () async {
    await boot();
    repo.failReplyWith = networkError;
    await cubit.replyToTopic('10', 'Thanks!');
    await pump();
    final id = topicOf('10').messages.last.clientId!;

    repo.failReplyWith = null;
    cubit.retryReply('10', id);
    await pump();
    expect(topicOf('10').messages.last.status, MessageStatus.sent);
    expect(repo.replyCount, 2);
  });

  test('discarding a failed reply removes it', () async {
    await boot();
    repo.failReplyWith = networkError;
    await cubit.replyToTopic('10', 'Thanks!');
    await pump();
    cubit.discardReply('10', topicOf('10').messages.last.clientId!);
    expect(topicOf('10').messages.length, 1);
  });

  test('refresh keeps unsent replies and the open cards', () async {
    await boot();
    repo.failReplyWith = networkError;
    await cubit.replyToTopic('10', 'still unsent');
    await pump();
    cubit.toggleExpanded('9');

    repo.topics = [
      topic('11', day: 3), // a new topic appeared
      topic('10', day: 2),
      topic('9'),
    ];
    await cubit.refresh();

    expect(loaded().topics.map((t) => t.id), ['11', '10', '9']);
    expect(topicOf('10').messages.last.content, 'still unsent');
    expect(topicOf('10').messages.last.status, MessageStatus.failed);
    expect(loaded().expandedTopicIds, {'10', '9'});
    expect(repo.watchedTopics, contains('11')); // new topic is watched
  });

  test('reconnect and list-change events trigger a refresh', () async {
    await boot();
    final base = repo.topicFetches;
    repo.controller.add(const ChatResync());
    await pump();
    expect(repo.topicFetches, base + 1);
    repo.controller.add(const FeedbackListChanged());
    await pump();
    expect(repo.topicFetches, base + 2);
  });

  test('periodic refresh picks up changes the server does not push', () async {
    await boot(poll: const Duration(milliseconds: 40));
    repo.topics = [topic('10', day: 2, resolved: true), topic('9')];
    await pump(150);
    expect(topicOf('10').isResolved, isTrue);
  });

  test('a failing refresh keeps the screen as is', () async {
    await boot();
    repo.failTopicsWith = networkError;
    await cubit.refresh();
    expect(cubit.state, isA<FeedbackChatLoaded>());
    expect(loaded().topics.length, 2);
  });

  test('toggleResolved is optimistic and rolls back on failure', () async {
    await boot();
    repo.failToggleWith = networkError;
    final f = cubit.toggleResolved('10');
    expect(topicOf('10').isResolved, isTrue); // optimistic
    await f;
    expect(topicOf('10').isResolved, isFalse); // rolled back

    repo.failToggleWith = null;
    await cubit.toggleResolved('10');
    expect(topicOf('10').isResolved, isTrue);
  });

  test('createTopic prepends, expands and watches the new topic', () async {
    await boot();
    final ok = await cubit.createTopic(
      subject: 'Math',
      tone: FeedbackTone.positive,
      message: 'Great job',
    );
    expect(ok, isTrue);
    expect(loaded().topics.first.subject, 'Math');
    expect(loaded().expandedTopicIds, contains(loaded().topics.first.id));
    expect(repo.watchedTopics, contains(loaded().topics.first.id));
  });

  test('createTopic failure leaves the list alone', () async {
    await boot();
    repo.failReplyWith = networkError;
    final ok = await cubit.createTopic(
      subject: 'Math',
      tone: FeedbackTone.positive,
      message: 'Great job',
    );
    expect(ok, isFalse);
    expect(loaded().topics.length, 2);
    expect(loaded().creatingTopic, isFalse);
  });

  test('createTopic enforces the length limits', () async {
    await boot();
    expect(
      await cubit.createTopic(
        subject: '',
        tone: FeedbackTone.neutral,
        message: 'x',
      ),
      isFalse,
    );
  });

  test('parent perspective replies as the parent', () async {
    await boot(asParent: true);
    repo.failReplyWith = networkError;
    await cubit.replyToTopic('10', 'hello teacher');
    expect(topicOf('10').messages.last.fromTeacher, isFalse);
  });

  test('closing stops polling and leaves the topics', () async {
    await boot(poll: const Duration(milliseconds: 20));
    await cubit.close();
    final fetches = repo.topicFetches;
    await pump(100);
    expect(repo.topicFetches, fetches);
  });
}
