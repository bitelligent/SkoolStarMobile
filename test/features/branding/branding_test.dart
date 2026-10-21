import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:skoolstar_teacher_module/core/network/api_client.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/storage/key_value_store.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/data/models/auth/auth_context.dart';
import 'package:skoolstar_teacher_module/data/models/branding.dart';
import 'package:skoolstar_teacher_module/data/repositories/branding_repository.dart';
import 'package:skoolstar_teacher_module/features/branding/cubit/brand_cubit.dart';

import '../../helpers/fakes.dart';

AuthContext _ctx(int instituteId) => AuthContext(
  contextKey: 'teacher-$instituteId',
  role: 'Teacher',
  instituteId: instituteId,
  staffId: 1,
);

class _FakeBrandingRepo implements BrandingRepository {
  final Map<int, Completer<Branding>> pending = {};
  final List<int> fetched = [];
  Branding? saved;
  bool cleared = false;

  @override
  Future<Branding> fetch(int instituteId) {
    fetched.add(instituteId);
    return (pending[instituteId] = Completer<Branding>()).future;
  }

  @override
  Future<Branding?> loadCached() async => saved;

  @override
  Future<void> save(Branding branding) async => saved = branding;

  @override
  Future<void> clearCache() async {
    cleared = true;
    saved = null;
  }

  @override
  Uri? resolveLogo(String reference) =>
      Uri.parse('https://api.test/${reference.replaceFirst('/', '')}');
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('BrandColors', () {
    test('parses #RRGGBB, RRGGBB and #RGB; rejects garbage', () {
      expect(parseHexColor('#1A73E8'), const Color(0xFF1A73E8));
      expect(parseHexColor('1a73e8'), const Color(0xFF1A73E8));
      expect(parseHexColor('#0f0'), const Color(0xFF00FF00));
      expect(parseHexColor('blue'), isNull);
      expect(parseHexColor('#12345'), isNull);
      expect(parseHexColor(null), isNull);
      expect(parseHexColor(''), isNull);
    });

    test('no seeds gives the SkoolStar defaults', () {
      expect(BrandColors.fromSeeds(), BrandColors.fallback);
    });

    test('keeps a brand colour that is already dark enough', () {
      final b = BrandColors.fromSeeds(primary: const Color(0xFF1A73E8));
      expect(b.primary, const Color(0xFF1A73E8));
      expect(b.primaryLight.computeLuminance(), greaterThan(0.7));
    });

    test('darkens a too-light primary so white text stays readable', () {
      final b = BrandColors.fromSeeds(primary: Colors.white);
      // WCAG: white on primary must reach at least 3:1.
      expect(1.05 / (b.primary.computeLuminance() + 0.05), greaterThan(3));
    });

    test('uses dark text on a light secondary', () {
      final b = BrandColors.fromSeeds(
        primary: const Color(0xFF1A73E8),
        secondary: const Color(0xFFFFEB3B),
      );
      expect(b.onSecondary, const Color(0xFF0F172A));
    });

    test('missing secondary falls back to the default secondary', () {
      final b = BrandColors.fromSeeds(primary: const Color(0xFF1A73E8));
      expect(b.secondary, BrandColors.fallback.secondary);
    });
  });

  group('Branding', () {
    test('parses the documented payload', () {
      final b = Branding.fromJson({
        'instituteId': 8,
        'brandName': ' Bright Future ',
        'logoUrl': '/uploads/institutes/8/logo-1.png',
        'primaryColor': '#1A73E8',
        'secondaryColor': '#34A853',
        'allowCustomBranding': true,
      });
      expect(b.instituteId, 8);
      expect(b.brandName, 'Bright Future');
      expect(b.primaryColor, '#1A73E8');
      expect(Branding.fromJson(b.toJson()), b);
    });

    test('tolerates nulls and missing fields', () {
      final b = Branding.fromJson({'instituteId': '8', 'logoUrl': null});
      expect(b.brandName, '');
      expect(b.logoUrl, isNull);
      expect(b.allowCustomBranding, isTrue);
    });
  });

  group('BrandingRepository', () {
    test('fetches the institute branding and caches the last result', () async {
      late Uri requested;
      final api = ApiClient(
        baseUrl: 'https://api.test',
        httpClient: MockClient((r) async {
          requested = r.url;
          return jsonResponse({
            'instituteId': 8,
            'brandName': 'Bright Future',
            'logoUrl': '/uploads/institutes/8/logo.png',
            'primaryColor': '#1A73E8',
            'secondaryColor': '#34A853',
            'allowCustomBranding': true,
          });
        }),
      );
      final store = InMemoryKeyValueStore();
      final repo = BrandingRepositoryImpl(apiClient: api, store: store);

      final b = await repo.fetch(8);
      expect(requested.path, '/api/Schools/8/branding');
      expect(b.brandName, 'Bright Future');

      await repo.save(b);
      expect(await readCachedBranding(store), b);
      expect(
        repo.resolveLogo(b.logoUrl!).toString(),
        'https://api.test/uploads/institutes/8/logo.png',
      );

      await repo.clearCache();
      expect(await readCachedBranding(store), isNull);
    });

    test('a corrupt cache is ignored', () async {
      final store = InMemoryKeyValueStore();
      await store.write(BrandingRepositoryImpl.cacheKey, '{not json');
      expect(await readCachedBranding(store), isNull);
    });
  });

  group('BrandCubit', () {
    late FakeAuthRepository auth;
    late _FakeBrandingRepo repo;

    const bright = Branding(
      instituteId: 8,
      brandName: 'Bright Future',
      logoUrl: '/uploads/institutes/8/logo.png',
      primaryColor: '#1A73E8',
      secondaryColor: '#34A853',
    );

    BrandCubit build({Branding? initial}) =>
        BrandCubit(repository: repo, auth: auth, initial: initial);

    setUp(() {
      auth = FakeAuthRepository(context: _ctx(8));
      repo = _FakeBrandingRepo();
    });

    test('starts with the SkoolStar defaults when nothing is cached', () {
      final cubit = build();
      expect(cubit.state.appName, 'SkoolStar');
      expect(cubit.state.colors, BrandColors.fallback);
      expect(cubit.state.logoUri, isNull);
      addTearDown(cubit.close);
    });

    test('applies the cached brand immediately, then the fresh one', () async {
      final cubit = build(initial: bright);
      addTearDown(cubit.close);
      expect(cubit.state.appName, 'Bright Future');

      repo.pending[8]!.complete(
        const Branding(
          instituteId: 8,
          brandName: 'Bright Future 2',
          primaryColor: '#B00020',
        ),
      );
      await _settle();
      expect(cubit.state.appName, 'Bright Future 2');
      expect(cubit.state.colors.primary, const Color(0xFFB00020));
      expect(repo.saved?.brandName, 'Bright Future 2');
    });

    test('resolves the logo to an absolute url', () async {
      final cubit = build();
      addTearDown(cubit.close);
      repo.pending[8]!.complete(bright);
      await _settle();
      expect(
        cubit.state.logoUri.toString(),
        'https://api.test/uploads/institutes/8/logo.png',
      );
    });

    test('ignores overrides when custom branding is not allowed', () async {
      final cubit = build();
      addTearDown(cubit.close);
      repo.pending[8]!.complete(
        const Branding(
          instituteId: 8,
          brandName: 'Nope',
          primaryColor: '#B00020',
          allowCustomBranding: false,
        ),
      );
      await _settle();
      expect(cubit.state.appName, 'SkoolStar');
      expect(cubit.state.colors, BrandColors.fallback);
    });

    test('an invalid colour falls back per slot', () async {
      final cubit = build();
      addTearDown(cubit.close);
      repo.pending[8]!.complete(
        const Branding(
          instituteId: 8,
          brandName: 'X',
          primaryColor: 'not-a-colour',
          secondaryColor: '#34A853',
        ),
      );
      await _settle();
      expect(cubit.state.colors.primary, BrandColors.fallback.primary);
      expect(cubit.state.colors.secondary, const Color(0xFF34A853));
    });

    test('offline refresh keeps the cached brand', () async {
      final cubit = build(initial: bright);
      addTearDown(cubit.close);
      repo.pending[8]!.completeError(const NetworkException());
      await _settle();
      expect(cubit.state.appName, 'Bright Future');
    });

    test('404 / 403 resets to defaults and clears the cache', () async {
      final cubit = build(initial: bright);
      addTearDown(cubit.close);
      repo.pending[8]!.completeError(const ForbiddenException());
      await _settle();
      expect(cubit.state.appName, 'SkoolStar');
      expect(repo.cleared, isTrue);
    });

    test('switching institute never shows the previous brand', () async {
      final other = _ctx(9);
      auth = FakeAuthRepository(context: _ctx(8), contexts: [_ctx(8), other]);
      final cubit = build(initial: bright);
      addTearDown(cubit.close);
      repo.pending[8]!.complete(bright);
      await _settle();
      expect(cubit.state.appName, 'Bright Future');

      await auth.selectContext(other.contextKey);
      // Institute 9's brand has not arrived (or the device is offline).
      expect(cubit.state.appName, 'SkoolStar');
      expect(repo.fetched, [8, 9]);

      repo.pending[9]!.complete(
        const Branding(instituteId: 9, brandName: 'Nine'),
      );
      await _settle();
      expect(cubit.state.appName, 'Nine');
    });

    test('a slow response for a previous institute is discarded', () async {
      final other = _ctx(9);
      auth = FakeAuthRepository(context: _ctx(8), contexts: [_ctx(8), other]);
      final cubit = build();
      addTearDown(cubit.close);

      await auth.selectContext(other.contextKey);
      repo.pending[9]!.complete(
        const Branding(instituteId: 9, brandName: 'Nine'),
      );
      await _settle();
      // Institute 8's response limps in last.
      repo.pending[8]!.complete(bright);
      await _settle();
      expect(cubit.state.appName, 'Nine');
    });

    test('sign-out keeps the brand for the login screen', () async {
      final cubit = build(initial: bright);
      addTearDown(cubit.close);
      repo.pending[8]!.complete(bright);
      await _settle();

      await auth.logout();
      expect(cubit.state.appName, 'Bright Future');
    });

    test('signing in fetches the branding', () async {
      await auth.logout();
      final cubit = build();
      addTearDown(cubit.close);
      expect(repo.fetched, isEmpty);

      auth.signInAs(_ctx(8));
      expect(repo.fetched, [8]);
    });
  });
}
