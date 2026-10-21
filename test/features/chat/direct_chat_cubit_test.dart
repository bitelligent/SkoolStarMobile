import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/data/models/chat_thread.dart';
import 'package:skoolstar_teacher_module/data/models/direct_message.dart';
import 'package:skoolstar_teacher_module/data/models/message_status.dart';
import 'package:skoolstar_teacher_module/data/repositories/chat_repository.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_cubit.dart';
import 'package:skoolstar_teacher_module/features/chat/cubit/direct_chat_state.dart';

import 'chat_fakes.dart';

void main() {
  late FakeChatRepository repo;
  late DirectChatCubit cubit;

  DirectChatLoaded loaded() => cubit.state as DirectChatLoaded;
  List<String> contents() => loaded().messages.map((m) => m.content).toList();

  Future<void> boot({
    List<DirectMessage>? messages,
    bool asParent = false,
    ChatThread? thread,
  }) async {
    repo = FakeChatRepository(thread: thread, messages: messages);
    cubit = DirectChatCubit(
      threadId: 'dm_1',
      repository: repo,
      asParent: asParent,
      markReadDelay: const Duration(milliseconds: 10),
    );
    await cubit.load();
  }

  tearDown(() async {
    await cubit.close();
    await repo.dispose();
  });

  test('load joins the thread and marks it read', () async {
    await boot(messages: [dm('1', 'hello')]);
    expect(contents(), ['hello']);
    expect(repo.watched, ['dm_1']);
    await pump(40);
    expect(repo.reads, ['dm_1']);
  });

  test('closing the screen leaves the thread', () async {
    await boot();
    await cubit.close();
    expect(repo.unwatched, ['dm_1']);
  });

  test('optimistic send: sending then sent, in order', () async {
    await boot();
    final hold = repo.holdSend = Completer<DirectMessage>();
    expect(await cubit.send('  hi there '), isTrue);

    expect(loaded().messages.single.status, MessageStatus.sending);
    expect(loaded().messages.single.content, 'hi there');

    hold.complete(
      DirectMessage(
        id: '77',
        threadId: 'dm_1',
        fromTeacher: true,
        content: 'hi there',
        sentAt: DateTime.now(),
      ),
    );
    await pump();
    final m = loaded().messages.single;
    expect(m.id, '77');
    expect(m.status, MessageStatus.sent);
    expect(m.clientId, isNull);
  });

  test('rejects empty and over-long text locally', () async {
    await boot();
    expect(await cubit.send('   '), isFalse);
    expect(await cubit.send('x' * 1001), isFalse);
    expect(repo.sendCount, 0);
    expect(await cubit.send('x' * 1000), isTrue);
  });

  test('push echo arriving before the HTTP answer shows one message', () async {
    await boot();
    final hold = repo.holdSend = Completer<DirectMessage>();
    await cubit.send('hello');

    final server = DirectMessage(
      id: '90',
      threadId: 'dm_1',
      fromTeacher: true,
      content: 'hello',
      sentAt: DateTime.now(),
    );
    repo.controller.add(DirectMessageReceived('dm_1', server));
    await pump();
    expect(loaded().messages.length, 1);
    expect(loaded().messages.single.id, '90');

    hold.complete(server);
    await pump();
    expect(loaded().messages.length, 1);
    expect(loaded().messages.single.status, MessageStatus.sent);
  });

  test('the same push delivered twice is shown once', () async {
    await boot();
    final m = dm('5', 'from parent');
    repo.controller
      ..add(DirectMessageReceived('dm_1', m))
      ..add(DirectMessageReceived('dm_1', m));
    await pump();
    expect(contents(), ['from parent']);
  });

  test('events for another thread are ignored', () async {
    await boot();
    repo.controller.add(DirectMessageReceived('dm_2', dm('5', 'other')));
    await pump();
    expect(loaded().messages, isEmpty);
  });

  test('incoming message is appended and marked read', () async {
    await boot(messages: [dm('1', 'a')]);
    await pump(40);
    repo.reads.clear();

    repo.controller.add(DirectMessageReceived('dm_1', dm('2', 'b')));
    await pump(60);
    expect(contents(), ['a', 'b']);
    expect(repo.reads, ['dm_1']);
  });

  test('failed send can be retried', () async {
    await boot();
    repo.failSendWith = networkError;
    await cubit.send('hello');
    await pump();
    expect(loaded().messages.single.status, MessageStatus.failed);

    repo.failSendWith = null;
    final id = loaded().messages.single.clientId!;
    cubit.retry(id);
    expect(loaded().messages.single.status, MessageStatus.sending);
    await pump();
    expect(loaded().messages.single.status, MessageStatus.sent);
    expect(repo.sendCount, 2);
  });

  test('retry does not duplicate a send that actually arrived', () async {
    await boot();
    repo.failSendWith = networkError; // the response was lost
    await cubit.send('hello');
    await pump();
    final id = loaded().messages.single.clientId!;

    // ...but the server did store it.
    repo.messages = [
      DirectMessage(
        id: '41',
        threadId: 'dm_1',
        fromTeacher: true,
        content: 'hello',
        sentAt: DateTime.now(),
      ),
    ];
    cubit.retry(id);
    await pump();

    expect(repo.sendCount, 1); // no second POST
    expect(loaded().messages.length, 1);
    expect(loaded().messages.single.id, '41');
    expect(loaded().messages.single.status, MessageStatus.sent);
  });

  test('a failed message can be discarded', () async {
    await boot();
    repo.failSendWith = networkError;
    await cubit.send('oops');
    await pump();
    cubit.discard(loaded().messages.single.clientId!);
    expect(loaded().messages, isEmpty);
  });

  test('messages are delivered in the order they were written', () async {
    await boot();
    final first = repo.holdSend = Completer<DirectMessage>();
    await cubit.send('one');
    await cubit.send('two');
    await pump();
    expect(repo.sentContents, ['one']); // two is queued behind one

    first.complete(
      DirectMessage(
        id: '1',
        threadId: 'dm_1',
        fromTeacher: true,
        content: 'one',
        sentAt: DateTime.now(),
      ),
    );
    await pump(60);
    expect(repo.sentContents, ['one', 'two']);
    expect(contents(), ['one', 'two']);
  });

  test('own unconfirmed messages stay below newer incoming ones', () async {
    await boot();
    repo.holdSend = Completer<DirectMessage>();
    await cubit.send('mine');
    // Device clock is behind: the peer's message has a later timestamp.
    repo.controller.add(
      DirectMessageReceived(
        'dm_1',
        dm('9', 'theirs', at: DateTime.now().add(const Duration(hours: 1))),
      ),
    );
    await pump();
    expect(contents(), ['theirs', 'mine']);
  });

  test('reconnect fetches what was missed', () async {
    await boot(messages: [dm('1', 'a')]);
    repo.messages = [dm('1', 'a'), dm('2', 'missed while offline')];
    repo.controller.add(const ChatResync());
    await pump();
    expect(contents(), ['a', 'missed while offline']);
    expect(repo.watched.length, 2); // re-joined (idempotent server side)
  });

  test('live flag follows the connection', () async {
    await boot();
    expect(loaded().isLive, isTrue);
    repo.live.value = false;
    expect(loaded().isLive, isFalse);
    repo.live.value = true;
    expect(loaded().isLive, isTrue);
  });

  test('presence of the peer updates the header', () async {
    await boot();
    expect(loaded().thread.isOnline, isFalse);
    repo.controller.add(const PeerPresenceChanged('peer', online: true));
    await pump();
    expect(loaded().thread.isOnline, isTrue);
    repo.controller.add(
      const PeerPresenceChanged('someone-else', online: false),
    );
    await pump();
    expect(loaded().thread.isOnline, isTrue);
  });

  test('a reply from the peer proves they read my earlier message', () async {
    await boot(messages: [dm('1', 'mine', fromTeacher: true)]);
    expect(loaded().messages.single.isRead, isFalse);

    repo.controller.add(DirectMessageReceived('dm_1', dm('2', 'theirs')));
    await pump();
    expect(loaded().messages.first.isRead, isTrue); // mine, now read
  });

  test('read ticks: peer read my messages up to the last one', () async {
    await boot(messages: [dm('1', 'mine 1', fromTeacher: true)]);
    expect(loaded().messages.first.isRead, isFalse);

    repo.thread = repo.thread.copyWith(outgoingLast: true);
    repo.controller.add(const DirectThreadChanged('dm_1'));
    await pump();
    expect(loaded().messages.first.isRead, isTrue);

    // A new message of mine is unread until the peer reads again.
    repo.holdSend = Completer<DirectMessage>()
      ..complete(
        DirectMessage(
          id: '3',
          threadId: 'dm_1',
          fromTeacher: true,
          content: 'mine 2',
          sentAt: DateTime.now().add(const Duration(minutes: 1)),
        ),
      );
    await cubit.send('mine 2');
    await pump();
    expect(loaded().messages.first.isRead, isTrue);
    expect(loaded().messages.last.isRead, isFalse);
  });

  test('parent perspective: own messages are the non-teacher ones', () async {
    await boot(asParent: true);
    repo.holdSend = Completer<DirectMessage>();
    await cubit.send('from parent');
    expect(loaded().messages.single.fromTeacher, isFalse);
  });

  group('history', () {
    test('a full first page means there may be more', () async {
      await boot(
        messages: [for (var i = 1; i <= 30; i++) dm('$i', 'm$i')],
      );
      expect(loaded().hasMore, isTrue);
    });

    test('older messages are prepended without duplicates', () async {
      await boot(
        messages: [for (var i = 31; i <= 60; i++) dm('$i', 'm$i')],
      );
      repo.olderPage = [for (var i = 1; i <= 30; i++) dm('$i', 'm$i')];
      await cubit.loadOlder();
      expect(loaded().messages.length, 60);
      expect(loaded().messages.first.id, '1');
      expect(loaded().messages.last.id, '60');
      expect(loaded().hasMore, isTrue);

      repo.olderPage = [];
      await cubit.loadOlder();
      expect(loaded().hasMore, isFalse);
      expect(loaded().isLoadingOlder, isFalse);
    });

    test('loadOlder is a no-op without more history', () async {
      await boot(messages: [dm('1', 'a')]);
      repo.olderPage = [dm('0', 'x')];
      await cubit.loadOlder();
      expect(loaded().messages.length, 1);
    });
  });

  test('unknown chat shows an error', () async {
    repo = FakeChatRepository();
    final r = _NoThreadRepo();
    cubit = DirectChatCubit(threadId: 'dm_9', repository: r);
    await cubit.load();
    expect(cubit.state, isA<DirectChatError>());
  });
}

class _NoThreadRepo extends FakeChatRepository {
  @override
  Future<ChatThread?> getThreadById(String id) async => null;
}
