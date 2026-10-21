import 'dart:convert';

import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_endpoints.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';
import 'package:skoolstar_teacher_module/data/models/branding.dart';

/// Reads the persisted branding without needing an [ApiClient], so `main`
/// can brand the very first frame.
Future<Branding?> readCachedBranding(KeyValueStore store) async {
  final raw = await store.read(BrandingRepositoryImpl.cacheKey);
  if (raw == null) return null;
  try {
    final json = jsonDecode(raw);
    return json is Json ? Branding.fromJson(json) : null;
  } on FormatException {
    return null;
  }
}

abstract interface class BrandingRepository {
  /// The branding saved by the last successful [fetch], so the splash and
  /// login screens of a returning user are already branded.
  Future<Branding?> loadCached();

  /// Branding of [instituteId] from the server. Throws `ApiException`.
  Future<Branding> fetch(int instituteId);

  Future<void> save(Branding branding);
  Future<void> clearCache();

  /// Absolute URL for a server-relative logo path.
  Uri? resolveLogo(String reference);
}

class BrandingRepositoryImpl implements BrandingRepository {
  const BrandingRepositoryImpl({
    required ApiClient apiClient,
    required KeyValueStore store,
  }) : _api = apiClient,
       _store = store;

  static const cacheKey = 'branding.v1';

  final ApiClient _api;
  final KeyValueStore _store;

  @override
  Future<Branding?> loadCached() => readCachedBranding(_store);

  @override
  Future<Branding> fetch(int instituteId) async {
    final json = await _api.get(ApiEndpoints.instituteBranding(instituteId));
    final parsed = json is Json ? Branding.fromJson(json) : null;
    // The path id is authoritative even if the body omits / mangles it.
    return Branding(
      instituteId: instituteId,
      brandName: parsed?.brandName ?? '',
      logoUrl: parsed?.logoUrl,
      primaryColor: parsed?.primaryColor,
      secondaryColor: parsed?.secondaryColor,
      allowCustomBranding: parsed?.allowCustomBranding ?? true,
    );
  }

  @override
  Future<void> save(Branding branding) =>
      _store.write(cacheKey, jsonEncode(branding.toJson()));

  @override
  Future<void> clearCache() => _store.remove(cacheKey);

  @override
  Uri? resolveLogo(String reference) => _api.resolveFileUrl(reference);
}
