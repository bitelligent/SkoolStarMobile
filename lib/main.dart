import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoolstar_teacher_module/app.dart';
import 'package:skoolstar_teacher_module/core/network/secure_token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Restore the saved session before the first frame so the router can
  // decide between login and dashboard synchronously.
  final tokenStore = SecureTokenStore();
  await tokenStore.load();

  runApp(SkoolStarApp(tokenStore: tokenStore));
}
