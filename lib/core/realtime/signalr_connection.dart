import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

enum HubStatus {
  /// Not started, stopped, or gave up (e.g. rejected token).
  disconnected,

  /// First connection attempt.
  connecting,

  /// Handshake done; invocations and events flow.
  connected,

  /// The link dropped and we are retrying with backoff.
  reconnecting,
}

/// A server-to-client invocation (`{"type":1,"target":…,"arguments":[…]}`).
class HubMessage {
  const HubMessage(this.target, this.arguments);

  final String target;
  final List<Object?> arguments;

  @override
  String toString() => 'HubMessage($target, $arguments)';
}

/// Opens the raw socket. Injectable so tests can use a local server, and so
/// the transport can be swapped without touching the protocol code.
typedef SocketConnector = Future<WebSocket> Function(Uri uri);

/// Minimal ASP.NET Core SignalR client (JSON protocol, WebSocket transport).
///
/// Covers what the chat needs and does it defensively:
///  * negotiate + handshake with timeouts,
///  * keep-alive pings and dead-link detection (half-open sockets after the
///    phone sleeps or switches network),
///  * automatic reconnect with jittered exponential backoff, forever, until
///    [stop],
///  * a fresh access token for every (re)connect,
///  * pending invocations fail fast when the link drops.
///
/// Group membership is server-side connection state, so callers must re-join
/// when [reconnected] fires.
class SignalRConnection {
  SignalRConnection({
    required this.baseUrl,
    required this.path,
    required this.accessToken,
    SocketConnector? connector,
    this.pingInterval = const Duration(seconds: 15),
    this.serverTimeout = const Duration(seconds: 40),
    this.handshakeTimeout = const Duration(seconds: 10),
    this.invokeTimeout = const Duration(seconds: 10),
    this.stableAfter = const Duration(seconds: 10),
    this.backoff = const [
      Duration.zero,
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
      Duration(seconds: 20),
      Duration(seconds: 30),
    ],
    Random? random,
  }) : _connector = connector ?? _defaultConnector,
       _random = random ?? Random();

  /// Server origin, e.g. `http://host:86`.
  final String baseUrl;

  /// Hub path, e.g. `/hubs/chat`.
  final String path;

  /// Current bearer token (read on every connect).
  final FutureOr<String?> Function() accessToken;

  final Duration pingInterval;
  final Duration serverTimeout;
  final Duration handshakeTimeout;
  final Duration invokeTimeout;

  /// How long a connection must stay up before the backoff starts over.
  final Duration stableAfter;
  final List<Duration> backoff;

  final SocketConnector _connector;
  final Random _random;

  static const _sep = '\u001e';

  final ValueNotifier<HubStatus> _status = ValueNotifier(
    HubStatus.disconnected,
  );
  final StreamController<HubMessage> _messages = StreamController.broadcast();
  final StreamController<void> _reconnected = StreamController.broadcast();

  ValueListenable<HubStatus> get status => _status;

  /// Server invocations (events).
  Stream<HubMessage> get messages => _messages.stream;

  /// Fires after every successful connect that follows a drop.
  Stream<void> get reconnected => _reconnected.stream;

  bool get isConnected => _status.value == HubStatus.connected;

  WebSocket? _socket;
  Timer? _pingTimer;
  DateTime _lastFrameAt = DateTime.now();
  bool _running = false;

  /// Identifies the live connection loop: a stop/start in quick succession
  /// must never leave the old loop running next to the new one.
  int _generation = 0;
  Timer? _stableTimer;
  bool _everConnected = false;
  int _attempt = 0;
  int _invocationSeq = 0;
  Completer<void>? _wake;
  final Map<String, Completer<Object?>> _pending = {};

  /// Starts (or keeps) the connection loop. Safe to call repeatedly.
  void start() {
    if (_running) return;
    _running = true;
    _everConnected = false;
    _attempt = 0;
    unawaited(_loop(++_generation));
  }

  /// Closes the link and stops reconnecting.
  Future<void> stop() async {
    _running = false;
    _generation++;
    _wakeBackoff();
    _teardown();
    _setStatus(HubStatus.disconnected);
  }

  /// Retry immediately instead of waiting out the backoff (app resumed,
  /// network came back).
  void reconnectNow() {
    if (!_running) return;
    _attempt = 0;
    _wakeBackoff();
  }

  void _wakeBackoff() {
    final wake = _wake;
    if (wake != null && !wake.isCompleted) wake.complete();
  }

  /// Verifies a link that looks open is really alive (call on app resume):
  /// pings and drops the socket if nothing comes back soon.
  void verifyAlive({Duration within = const Duration(seconds: 5)}) {
    final socket = _socket;
    if (socket == null || !isConnected) {
      reconnectNow();
      return;
    }
    final before = _lastFrameAt;
    _sendFrame({'type': 6});
    Timer(within, () {
      if (identical(_socket, socket) && !_lastFrameAt.isAfter(before)) {
        unawaited(socket.close(4000, 'stale'));
      }
    });
  }

  /// Invokes a hub method and waits for its completion. Throws
  /// [StateError] when not connected and [TimeoutException] when the server
  /// does not answer.
  Future<Object?> invoke(String target, [List<Object?> args = const []]) {
    if (!isConnected) {
      return Future.error(StateError('Hub not connected'));
    }
    final id = '${++_invocationSeq}';
    final completer = Completer<Object?>();
    _pending[id] = completer;
    _sendFrame({
      'type': 1,
      'invocationId': id,
      'target': target,
      'arguments': args,
    });
    return completer.future.timeout(
      invokeTimeout,
      onTimeout: () {
        _pending.remove(id);
        throw TimeoutException('$target timed out');
      },
    );
  }

  Future<void> dispose() async {
    await stop();
    await _messages.close();
    await _reconnected.close();
    _status.dispose();
  }

  // ─── Connection loop ────────────────────────────────────────────────

  Future<void> _loop(int generation) async {
    bool current() => _running && generation == _generation;

    while (current()) {
      final closed = Completer<void>();
      try {
        _setStatus(
          _everConnected ? HubStatus.reconnecting : HubStatus.connecting,
        );
        await _connectOnce(closed, generation);
      } on _Unauthorized {
        // A rejected token will not fix itself by retrying; the REST layer
        // signs the user out and a new login restarts us.
        if (generation == _generation) {
          _running = false;
          _setStatus(HubStatus.disconnected);
        }
        return;
      } on Object catch (e) {
        debugPrint('SignalR $path connect failed: $e');
        if (!current()) return;
        _teardown();
        _setStatus(HubStatus.reconnecting);
        await _sleepBackoff();
        continue;
      }

      // Connected: wait until the link drops.
      await closed.future;
      if (!current()) return;
      _teardown();
      _setStatus(HubStatus.reconnecting);
      await _sleepBackoff();
    }
  }

  Future<void> _sleepBackoff() async {
    final base = backoff[min(_attempt, backoff.length - 1)];
    _attempt++;
    if (base == Duration.zero) return;
    final jitter = 0.75 + _random.nextDouble() * 0.5;
    final wake = _wake = Completer<void>();
    await Future.any([
      Future<void>.delayed(base * jitter),
      wake.future,
    ]);
  }

  Future<void> _connectOnce(Completer<void> closed, int generation) async {
    final token = await accessToken();
    if (token == null || token.isEmpty) throw _Unauthorized();

    final origin = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final connectionId = await _negotiate('$origin$path', token);

    final wsOrigin = origin.replaceFirst(RegExp('^http'), 'ws');
    final uri = Uri.parse('$wsOrigin$path').replace(
      queryParameters: {'id': connectionId, 'access_token': token},
    );
    final socket = await _connector(uri).timeout(handshakeTimeout);
    if (generation != _generation) {
      // stop()/start() ran while we were connecting: this attempt is stale.
      unawaited(socket.close(1000, 'superseded'));
      throw StateError('superseded');
    }
    _socket = socket;

    final handshake = Completer<void>();
    var buffer = '';

    socket.listen(
      (Object? data) {
        _lastFrameAt = DateTime.now();
        if (data is! String) return;
        buffer += data;
        var idx = buffer.indexOf(_sep);
        while (idx != -1) {
          final frame = buffer.substring(0, idx);
          buffer = buffer.substring(idx + 1);
          if (frame.isNotEmpty) {
            if (!handshake.isCompleted) {
              _onHandshake(frame, handshake);
            } else {
              _onFrame(frame);
            }
          }
          idx = buffer.indexOf(_sep);
        }
      },
      onError: (Object e) {
        // cancelOnError also cancels onDone, so end the link here too.
        if (!handshake.isCompleted) handshake.completeError(e);
        if (!closed.isCompleted) closed.complete();
      },
      onDone: () {
        if (!handshake.isCompleted) {
          handshake.completeError(StateError('closed during handshake'));
        }
        if (!closed.isCompleted) closed.complete();
      },
      cancelOnError: true,
    );

    socket.add('${jsonEncode({'protocol': 'json', 'version': 1})}$_sep');
    await handshake.future.timeout(handshakeTimeout);

    _lastFrameAt = DateTime.now();
    final wasReconnect = _everConnected;
    _everConnected = true;
    // Only a connection that survives for a while earns a fresh backoff; a
    // server that accepts and immediately drops must not be hammered.
    _stableTimer?.cancel();
    _stableTimer = Timer(stableAfter, () => _attempt = 0);
    _startPings(socket);
    _setStatus(HubStatus.connected);
    if (wasReconnect) _reconnected.add(null);
  }

  Future<String> _negotiate(String hubUrl, String token) async {
    final client = HttpClient()..connectionTimeout = handshakeTimeout;
    try {
      final uri = Uri.parse('$hubUrl/negotiate').replace(
        queryParameters: {'negotiateVersion': '1', 'access_token': token},
      );
      final request = await client.postUrl(uri);
      // IIS rejects a body-less POST without an explicit length (HTTP 411).
      request.headers.contentLength = 0;
      final response = await request.close().timeout(handshakeTimeout);
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(handshakeTimeout);
      if (response.statusCode == 401 || response.statusCode == 403) {
        throw _Unauthorized();
      }
      if (response.statusCode != 200) {
        throw HttpException('negotiate ${response.statusCode}');
      }
      final json = jsonDecode(body) as Map<String, dynamic>;
      final id = json['connectionToken'] ?? json['connectionId'];
      if (id is! String) throw const FormatException('no connection id');
      return id;
    } finally {
      client.close(force: true);
    }
  }

  void _onHandshake(String frame, Completer<void> handshake) {
    try {
      final json = jsonDecode(frame) as Map<String, dynamic>;
      if (json['error'] != null) {
        handshake.completeError(StateError('${json['error']}'));
      } else {
        handshake.complete();
      }
    } on Object catch (e) {
      handshake.completeError(e);
    }
  }

  void _onFrame(String frame) {
    final Object? json;
    try {
      json = jsonDecode(frame);
    } on FormatException {
      return;
    }
    if (json is! Map<String, dynamic>) return;
    switch (json['type']) {
      case 1: // Invocation
        final target = json['target'];
        if (target is String) {
          final args = json['arguments'];
          _messages.add(
            HubMessage(target, args is List ? args : const <Object?>[]),
          );
        }
      case 3: // Completion
        final completer = _pending.remove('${json['invocationId']}');
        if (completer == null || completer.isCompleted) return;
        final error = json['error'];
        if (error != null) {
          completer.completeError(StateError('$error'));
        } else {
          completer.complete(json['result']);
        }
      case 7: // Close
        unawaited(_socket?.close(1000, 'server close'));
      case 6: // Ping
        break;
    }
  }

  void _startPings(WebSocket socket) {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(pingInterval, (_) {
      if (!identical(_socket, socket)) return;
      if (DateTime.now().difference(_lastFrameAt) > serverTimeout) {
        // Nothing (not even the server's keep-alive) for too long.
        unawaited(socket.close(4001, 'timeout'));
        return;
      }
      _sendFrame({'type': 6});
    });
  }

  void _sendFrame(Map<String, Object?> frame) {
    try {
      _socket?.add('${jsonEncode(frame)}$_sep');
    } on Object catch (e) {
      debugPrint('SignalR send failed: $e');
    }
  }

  void _teardown() {
    _stableTimer?.cancel();
    _pingTimer?.cancel();
    _pingTimer = null;
    final socket = _socket;
    _socket = null;
    if (socket != null) unawaited(socket.close().catchError((Object _) {}));
    for (final c in _pending.values) {
      if (!c.isCompleted) c.completeError(StateError('Connection lost'));
    }
    _pending.clear();
  }

  void _setStatus(HubStatus s) {
    if (_status.value != s) _status.value = s;
  }

  static Future<WebSocket> _defaultConnector(Uri uri) => WebSocket.connect(
    uri.toString(),
  );
}

class _Unauthorized implements Exception {}
