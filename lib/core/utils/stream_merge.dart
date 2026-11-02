import 'dart:async';

/// One broadcast stream carrying the events of all [streams]; they are only
/// subscribed to while someone listens.
Stream<T> mergeStreams<T>(List<Stream<T>> streams) {
  late StreamController<T> controller;
  final subs = <StreamSubscription<T>>[];
  controller = StreamController<T>.broadcast(
    onListen: () {
      for (final s in streams) {
        subs.add(s.listen(controller.add, onError: controller.addError));
      }
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
      subs.clear();
    },
  );
  return controller.stream;
}
