import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skoolstar_teacher_module/app.dart';
import 'package:skoolstar_teacher_module/core/network/jwt.dart';
import 'package:skoolstar_teacher_module/core/network/secure_token_store.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/data/repositories/branding_repository.dart';

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

  // A saved token past its expiry can only produce a burst of 401s: drop it
  // and open on the login screen instead.
  if (isJwtExpired(tokenStore.accessToken)) await tokenStore.clear();

  // Last known institute branding, so the splash / login of a returning user
  // are already themed. Falls back to the SkoolStar defaults.
  final keyValueStore = SecureKeyValueStore();
  final branding = await readCachedBranding(keyValueStore);

  runApp(
    SkoolStarApp(
      tokenStore: tokenStore,
      keyValueStore: keyValueStore,
      initialBranding: branding,
    ),
  );
}
