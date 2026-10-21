import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';

class _Counter extends SafeCubit<int> {
  _Counter() : super(0);

  Future<void> slowLoad(Completer<int> gate) async {
    final v = await gate.future;
    emit(v); // arrives after the screen has gone
  }
}

void main() {
  test('a late result after close is dropped instead of throwing', () async {
    final cubit = _Counter();
    final gate = Completer<int>();
    final load = cubit.slowLoad(gate);

    await cubit.close();
    gate.complete(5);

    await expectLater(load, completes);
    expect(cubit.state, 0);
  });

  test('works normally while open', () async {
    final cubit = _Counter();
    final emitted = <int>[];
    final sub = cubit.stream.listen(emitted.add);
    final gate = Completer<int>()..complete(7);
    await cubit.slowLoad(gate);
    await Future<void>.delayed(Duration.zero);
    expect(emitted, [7]);
    await sub.cancel();
    await cubit.close();
  });
}
