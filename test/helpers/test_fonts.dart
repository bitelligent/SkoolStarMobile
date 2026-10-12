import 'dart:io';

import 'package:flutter/services.dart';

/// Widget tests render text in a placeholder font whose glyphs are far wider
/// than real text, which makes layout tests report overflows that never
/// happen on a device. The app uses Inter via `google_fonts`, which can't be
/// downloaded in tests, so register the SDK's Roboto under Inter's family
/// names instead. Roboto is a little narrower than Inter, so layout tests
/// also add a small text-scale margin.
Future<void> loadTestFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) return;
  final dir = '$root/bin/cache/artifacts/material_fonts';

  Future<void> register(String family, String file) async {
    final f = File('$dir/$file');
    if (!f.existsSync()) return;
    final bytes = f.readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
    await loader.load();
  }

  await register('Inter_regular', 'Roboto-Regular.ttf');
  await register('Inter_500', 'Roboto-Medium.ttf');
  // Roboto has no semibold; Bold is wider, so this errs on the safe side.
  await register('Inter_600', 'Roboto-Bold.ttf');
  await register('Inter_700', 'Roboto-Bold.ttf');
  await register('Inter_800', 'Roboto-Black.ttf');
  await register('Roboto', 'Roboto-Regular.ttf');
  await register(
    'MaterialIcons',
    '../material_fonts/MaterialIcons-Regular.otf',
  );
}
