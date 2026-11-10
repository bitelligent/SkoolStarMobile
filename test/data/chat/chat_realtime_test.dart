import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/realtime/signalr_connection.dart';
import 'package:skoolstar_teacher_module/data/realtime/chat_realtime.dart';

import '../../helpers/fake_hub_server.dart';

Future<void> _until(bool Function() test, {int ms = 4000}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (!test()) {
    if (DateTime.now().isAfter(end)) fail('condition not met in ${ms}ms');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

SignalRConnection _hub(FakeHubServer s, String path) => SignalRConnection(
  baseUrl: s.origin,
  path: path,
  accessToken: () => 'jwt',
  handshakeTimeout: const Duration(seconds: 2),
  invokeTimeout: const Duration(seconds: 1),
  backoff: const [Duration.zero, Duration(milliseconds: 50)],
);

void main() {
  late FakeHubServer server;
  late ChatRealtime realtime;
  late List<RealtimeEvent> events;

  setUp(() async {
    server = FakeHubServer();
    await server.start();
    realtime = ChatRealtime(
      chatHub: _hub(server, '/hubs/chat'),
      feedbackHub: _hub(server, '/hubs/feedback-chat'),
    );
    events = [];
    realtime.events.listen(events.add);
  });

  tearDown(() async {
    await realtime.dispose();
    await server.stop();
  });

  /// Both hubs connect to the same fake server: first socket = chat hub.
  Future<void> connect() async {
    realtime.start();
    await _until(() => realtime.isLive.value);
  }

  void pushChat(String target, Object arg) =>
      server.push(server.sockets[0], target, [arg]);
  void pushFeedback(String target, Object arg) =>
      server.push(server.sockets[1], target, [arg]);

  test('becomes live only when both hubs are connected', () async {
    expect(realtime.isLive.value, isFalse);
    await connect();
    expect(realtime.isLive.value, isTrue);
  });

  test('maps chat events and drops duplicate deliveries', () async {
    await connect();
    final msg = {
      'threadId': 1,
      'message': {'id': 31, 'senderUserId': 'u', 'body': 'hi'},
    };
    // The server delivers to the user group and the thread group.
    pushChat('MessageCreated', msg);
    pushChat('MessageCreated', msg);
    pushChat('ThreadUpdated', {'threadId': 1});
    pushChat('PresenceChanged', {'userId': 'u', 'online': true});
    await _until(() => events.length >= 3);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(events.whereType<DirectMessageCreated>().length, 1);
    final created = events.whereType<DirectMessageCreated>().single;
    expect(created.threadId, 1);
    expect(created.message['body'], 'hi');
    expect(events.whereType<DirectThreadUpdated>().single.threadId, 1);
    final presence = events.whereType<PresenceChanged>().single;
    expect(presence.userId, 'u');
    expect(presence.online, isTrue);
  });

  test('maps feedback events; unknown ones request a list refresh', () async {
    await connect();
    pushFeedback('MessageCreated', {
      'feedbackId': 1024,
      'message': {'id': 41, 'senderRole': 1, 'body': 'x'},
    });
    pushFeedback('FeedbackThreadCreated', {'feedbackId': 1030});
    await _until(() => events.length >= 2);

    final m = events.whereType<FeedbackMessageCreated>().single;
    expect(m.feedbackId, 1024);
    expect(events.whereType<FeedbackListChanged>().length, 1);
  });

  test('malformed payloads are ignored', () async {
    await connect();
    pushChat('MessageCreated', 'not an object');
    pushChat('MessageCreated', {'threadId': 1}); // no message
    pushChat('Something', {'a': 1});
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(events, isEmpty);
  });

  test('joins are sent once and ref-counted', () async {
    await connect();
    await realtime.joinThread(1);
    await realtime.joinThread(1); // second screen
    expect(
      server.invocations.where((i) => i.startsWith('JoinThread')).length,
      1,
    );
    await realtime.leaveThread(1);
    expect(server.invocations.any((i) => i.startsWith('LeaveThread')), isFalse);
    await realtime.leaveThread(1);
    expect(server.invocations.any((i) => i.startsWith('LeaveThread')), isTrue);
  });

  test('a join requested before connecting is sent once connected', () async {
    await realtime.joinThread(7);
    await realtime.joinFeedback(1024);
    await connect();
    await _until(
      () =>
          server.invocations.contains('JoinThread:[7]') &&
          server.invocations.contains('JoinFeedback:[1024]'),
    );
  });

  test('groups are restored and a resync is signalled after a drop', () async {
    await connect();
    await realtime.joinThread(1);
    await realtime.joinFeedback(1024);
    server.invocations.clear();

    await server.sockets[0].close(); // chat link drops
    await _until(() => events.any((e) => e is RealtimeResync));
    await _until(() => realtime.isLive.value);
    await _until(() => server.invocations.contains('JoinThread:[1]'));
  });

  test('stop clears groups so a new session starts clean', () async {
    await connect();
    await realtime.joinThread(1);
    await realtime.stop();
    expect(realtime.isLive.value, isFalse);

    server.invocations.clear();
    realtime.start();
    await _until(() => realtime.isLive.value);
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(server.invocations, isEmpty);
  });
}
