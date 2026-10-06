import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Abstract source so a remote/API implementation can be swapped in later
/// without touching repositories or cubits.
abstract class JsonDataSource {
  Future<Map<String, dynamic>> readJsonObject(String assetPath);
  Future<List<dynamic>> readJsonArray(String assetPath);
}

/// Reads JSON files bundled under `assets/json/`.
class LocalJsonDataSource implements JsonDataSource {
  const LocalJsonDataSource({this.simulatedLatency = const Duration(milliseconds: 300)});

  /// Artificial delay so loading states are visible in dev. Set to
  /// [Duration.zero] (or remove) when wiring real APIs.
  final Duration simulatedLatency;

  @override
  Future<Map<String, dynamic>> readJsonObject(String assetPath) async {
    await Future<void>.delayed(simulatedLatency);
    final raw = await rootBundle.loadString(assetPath);
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<List<dynamic>> readJsonArray(String assetPath) async {
    await Future<void>.delayed(simulatedLatency);
    final raw = await rootBundle.loadString(assetPath);
    return jsonDecode(raw) as List<dynamic>;
  }
}
