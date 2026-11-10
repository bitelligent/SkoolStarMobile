import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A tiny in-process SignalR server (negotiate + JSON handshake + invocations)
/// so the real WebSocket protocol code is exercised end to end.
class FakeHubServer {
  late HttpServer _http;
  final List<WebSocket> sockets = [];
  final List<String> tokens = [];
  final List<Map<String, dynamic>> received = [];
  int negotiateStatus = 200;
  bool answerInvocations = true;
  bool ignoreHandshake = false;
  bool closeAfterHandshake = false;
  int negotiates = 0;
  final List<String> invocations = [];

  String get origin => 'http://127.0.0.1:${_http.port}';

  Future<void> start() async {
    _http = await HttpServer.bind('127.0.0.1', 0);
    _http.listen((req) async {
      if (req.method == 'POST' && req.uri.path.endsWith('/negotiate')) {
        negotiates++;
        tokens.add(req.uri.queryParameters['access_token'] ?? '');
        req.response.statusCode = negotiateStatus;
        req.response.headers.contentType = ContentType.json;
        req.response.write(
          jsonEncode({
            'negotiateVersion': 1,
            'connectionId': 'c$negotiates',
            'connectionToken': 'tok$negotiates',
            'availableTransports': <Object>[],
          }),
        );
        await req.response.close();
        return;
      }
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        final ws = await WebSocketTransformer.upgrade(req);
        sockets.add(ws);
        ws.listen((Object? data) {
          for (final f in '$data'.split('\u001e').where((e) => e.isNotEmpty)) {
            final json = jsonDecode(f) as Map<String, dynamic>;
            if (json.containsKey('protocol')) {
              if (!ignoreHandshake) ws.add('{}\u001e');
              if (closeAfterHandshake) unawaited(ws.close());
              continue;
            }
            received.add(json);
            if (json['type'] == 1) {
              invocations.add(
                '${json['target']}:${jsonEncode(json['arguments'])}',
              );
            }
            if (json['type'] == 1 && answerInvocations) {
              ws.add(
                '${jsonEncode({
                  'type': 3,
                  'invocationId': json['invocationId'],
                  'result': 'ok:${json['target']}',
                })}\u001e',
              );
            }
          }
        });
        return;
      }
      req.response.statusCode = 404;
      await req.response.close();
    });
  }

  void push(WebSocket ws, String target, List<Object?> args) => ws.add(
    '${jsonEncode({'type': 1, 'target': target, 'arguments': args})}\u001e',
  );

  Future<void> stop() async {
    for (final s in sockets) {
      await s.close();
    }
    await _http.close(force: true);
  }
}
