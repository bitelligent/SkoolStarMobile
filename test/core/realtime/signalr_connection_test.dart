import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/realtime/signalr_connection.dart';

import '../../helpers/fake_hub_server.dart';

Future<void> _until(bool Function() test, {int ms = 4000}) async {
  final end = DateTime.now().add(Duration(milliseconds: ms));
  while (!test()) {
    if (DateTime.now().isAfter(end)) fail('condition not met in ${ms}ms');
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

void main() {
  late FakeHubServer server;
  setUp(() async {
    server = FakeHubServer();
    await server.start();
  });
  tearDown(() => server.stop());

  SignalRConnection make({
    String? Function()? token,
    Duration serverTimeout = const Duration(seconds: 40),
    Duration pingInterval = const Duration(seconds: 15),
  }) => SignalRConnection(
    baseUrl: server.origin,
    path: '/hubs/chat',
    accessToken: token ?? () => 'jwt',
    serverTimeout: serverTimeout,
    pingInterval: pingInterval,
    handshakeTimeout: const Duration(seconds: 2),
    invokeTimeout: const Duration(seconds: 1),
    backoff: const [Duration.zero, Duration(milliseconds: 50)],
  );

  test('connects, receives events and completes invocations', () async {
    final hub = make()..start();
    addTearDown(hub.dispose);
    final events = <HubMessage>[];
    hub.messages.listen(events.add);

    await _until(() => hub.isConnected);
    expect(server.tokens.single, 'jwt');

    server.push(server.sockets.single, 'MessageCreated', [
      {'threadId': 1},
    ]);
    await _until(() => events.isNotEmpty);
    expect(events.single.target, 'MessageCreated');
    expect((events.single.arguments.single as Map)['threadId'], 1);

    expect(await hub.invoke('JoinThread', [1]), 'ok:JoinThread');
  });

  test('invoke while disconnected fails fast', () async {
    final hub = make();
    addTearDown(hub.dispose);
    await expectLater(hub.invoke('JoinThread', [1]), throwsStateError);
  });

  test('invoke times out when the server never completes it', () async {
    server.answerInvocations = false;
    final hub = make()..start();
    addTearDown(hub.dispose);
    await _until(() => hub.isConnected);
    await expectLater(
      hub.invoke('JoinThread', [1]),
      throwsA(isA<TimeoutException>()),
    );
  });

  test('reconnects after the server drops the socket and signals it', () async {
    final hub = make()..start();
    addTearDown(hub.dispose);
    var reconnects = 0;
    hub.reconnected.listen((_) => reconnects++);
    await _until(() => hub.isConnected);

    await server.sockets.first.close();
    await _until(() => reconnects == 1 && hub.isConnected);
    expect(server.negotiates, 2);

    // Invocations work on the new link.
    expect(await hub.invoke('JoinThread', [2]), 'ok:JoinThread');
  });

  test('a pending invoke fails when the link drops', () async {
    server.answerInvocations = false;
    final hub = make()..start();
    addTearDown(hub.dispose);
    await _until(() => hub.isConnected);

    final f = hub.invoke('JoinThread', [1]);
    final expectation = expectLater(f, throwsStateError);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await server.sockets.first.close();
    await expectation;
  });

  test('uses a fresh token on every reconnect', () async {
    var n = 0;
    final hub = make(token: () => 'jwt${++n}')..start();
    addTearDown(hub.dispose);
    await _until(() => hub.isConnected);
    await server.sockets.first.close();
    await _until(() => server.tokens.length == 2 && hub.isConnected);
    expect(server.tokens, ['jwt1', 'jwt2']);
  });

  test('a rejected token stops retrying', () async {
    server.negotiateStatus = 401;
    final hub = make()..start();
    addTearDown(hub.dispose);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(hub.status.value, HubStatus.disconnected);
    expect(server.negotiates, 1);
  });

  test('server errors keep retrying with backoff', () async {
    server.negotiateStatus = 500;
    final hub = make()..start();
    addTearDown(hub.dispose);
    await _until(() => server.negotiates >= 3);
    expect(hub.status.value, isNot(HubStatus.disconnected));

    server.negotiateStatus = 200;
    await _until(() => hub.isConnected);
  });

  test('a silent server is detected by the keep-alive timeout', () async {
    final hub = make(
      pingInterval: const Duration(milliseconds: 100),
      serverTimeout: const Duration(milliseconds: 400),
    )..start();
    addTearDown(hub.dispose);
    var reconnects = 0;
    hub.reconnected.listen((_) => reconnects++);
    await _until(() => hub.isConnected);
    // The fake server never pings; the client must give up on the link.
    await _until(() => reconnects >= 1, ms: 6000);
  });

  test('reconnectNow skips the backoff wait', () async {
    server.negotiateStatus = 500;
    final hub = SignalRConnection(
      baseUrl: server.origin,
      path: '/hubs/chat',
      accessToken: () => 'jwt',
      handshakeTimeout: const Duration(seconds: 2),
      backoff: const [Duration.zero, Duration(seconds: 30)],
    )..start();
    addTearDown(hub.dispose);
    await _until(() => server.negotiates >= 2);
    final before = server.negotiates;
    server.negotiateStatus = 200;
    hub.reconnectNow();
    await _until(() => hub.isConnected, ms: 3000);
    expect(server.negotiates, greaterThan(before));
  });

  test('stop closes the link and does not reconnect', () async {
    final hub = make()..start();
    addTearDown(hub.dispose);
    await _until(() => hub.isConnected);
    await hub.stop();
    expect(hub.status.value, HubStatus.disconnected);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(server.negotiates, 1);
  });

  test('a server that accepts then drops is not hammered', () async {
    // Closes every socket right after the handshake.
    server.closeAfterHandshake = true;
    final hub = SignalRConnection(
      baseUrl: server.origin,
      path: '/hubs/chat',
      accessToken: () => 'jwt',
      handshakeTimeout: const Duration(seconds: 2),
      stableAfter: const Duration(seconds: 30),
      backoff: const [
        Duration.zero,
        Duration(milliseconds: 200),
        Duration(milliseconds: 400),
        Duration(seconds: 5),
      ],
    )..start();
    addTearDown(hub.dispose);
    await Future<void>.delayed(const Duration(seconds: 1));
    // Without the stable-connection rule this would reconnect in a tight loop
    // (hundreds of attempts) and starve the UI thread.
    expect(server.negotiates, lessThan(6), reason: '${server.negotiates}');
    expect(server.negotiates, greaterThan(1));
  });

  test('stop() then start() quickly never runs two loops', () async {
    final hub = make();
    addTearDown(hub.dispose);
    for (var i = 0; i < 5; i++) {
      hub.start();
      await hub.stop();
    }
    hub.start();
    await _until(() => hub.isConnected);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    // One live socket: the others were never kept or were closed.
    final open = server.sockets.where((s) => s.closeCode == null).length;
    expect(open, 1, reason: 'open sockets: $open');
    expect(hub.isConnected, isTrue);
  });
}
