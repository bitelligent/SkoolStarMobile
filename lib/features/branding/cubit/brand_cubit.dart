import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/core/bloc/safe_cubit.dart';
import 'package:skoolstar_teacher_module/core/network/api_exception.dart';
import 'package:skoolstar_teacher_module/core/theme/brand_colors.dart';
import 'package:skoolstar_teacher_module/data/models/branding.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';
import 'package:skoolstar_teacher_module/data/repositories/branding_repository.dart';

/// What the UI needs to look like the institute: name, logo and colours.
class BrandState extends Equatable {
  const BrandState({
    required this.colors,
    required this.appName,
    this.logoUri,
    this.branding,
  });

  static const String defaultAppName = 'SkoolStar';

  static const BrandState defaults = BrandState(
    colors: BrandColors.fallback,
    appName: defaultAppName,
  );

  /// Applies [branding] (or the defaults when there is none, or the
  /// institute opted out of custom branding).
  factory BrandState.from(
    Branding? branding, {
    required Uri? Function(String) resolveLogo,
  }) {
    if (branding == null || !branding.allowCustomBranding) {
      // Keep the record so the same institute is not re-fetched needlessly.
      return BrandState(
        colors: BrandColors.fallback,
        appName: defaultAppName,
        branding: branding,
      );
    }
    final logo = branding.logoUrl;
    return BrandState(
      colors: BrandColors.fromSeeds(
        primary: parseHexColor(branding.primaryColor),
        secondary: parseHexColor(branding.secondaryColor),
      ),
      appName: branding.brandName.isEmpty ? defaultAppName : branding.brandName,
      logoUri: logo == null || logo.isEmpty ? null : resolveLogo(logo),
      branding: branding,
    );
  }

  final BrandColors colors;
  final String appName;
  final Uri? logoUri;

  /// The record this state was built from (`null` for the defaults).
  final Branding? branding;

  @override
  List<Object?> get props => [colors, appName, logoUri, branding];
}

/// App-wide white-label branding. Refreshed on every login and role/institute
/// switch; the last result is cached so the next cold start is branded from
/// the first frame.
class BrandCubit extends SafeCubit<BrandState> {
  BrandCubit({
    required BrandingRepository repository,
    required AuthRepository auth,
    Branding? initial,
  }) : _repo = repository,
       _auth = auth,
       super(
         BrandState.from(initial, resolveLogo: repository.resolveLogo),
       ) {
    _lastInstituteId = _activeInstituteId;
    _auth.session.addListener(_onSessionChanged);
    // A restored session: pick up any change made since the last run.
    if (_lastInstituteId != null) refresh();
  }

  final BrandingRepository _repo;
  final AuthRepository _auth;

  int? _lastInstituteId;

  /// Bumped per refresh so a slow response for a previous institute can never
  /// overwrite the current one.
  int _generation = 0;

  int? get _activeInstituteId {
    final session = _auth.session.value;
    return session.signedIn ? session.context?.instituteId : null;
  }

  void _onSessionChanged() {
    final id = _activeInstituteId;
    // Signed out: keep the last brand on screen for the login page.
    if (id == null || id == _lastInstituteId) return;
    _lastInstituteId = id;
    refresh();
  }

  /// Fetches the active institute's branding. Never throws: branding is
  /// cosmetic and must not get in the way of signing in.
  Future<void> refresh() async {
    final id = _activeInstituteId;
    if (id == null) return;
    final generation = ++_generation;

    // Never show another institute's brand while this one loads / is offline.
    final current = state.branding;
    if (current != null && current.instituteId != id) {
      emit(BrandState.defaults);
    }

    try {
      final fresh = await _repo.fetch(id);
      if (isClosed || generation != _generation) return;
      emit(BrandState.from(fresh, resolveLogo: _repo.resolveLogo));
      await _repo.save(fresh);
    } on UnauthorizedException {
      // The API client signs the user out; nothing to brand.
    } on NotFoundException {
      await _useDefaults(generation);
    } on ForbiddenException {
      await _useDefaults(generation);
    } on ApiException catch (e) {
      // Offline / server error: keep whatever is showing.
      debugPrint('Branding refresh failed: $e');
    }
  }

  Future<void> _useDefaults(int generation) async {
    if (isClosed || generation != _generation) return;
    emit(BrandState.defaults);
    await _repo.clearCache();
  }

  @override
  Future<void> close() {
    _auth.session.removeListener(_onSessionChanged);
    return super.close();
  }
}
