import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skoolstar_teacher_module/features/branding/cubit/brand_cubit.dart';

extension BrandStateContext on BuildContext {
  /// Institute name / logo / colours. Rebuilds the caller when branding
  /// changes. Falls back to the SkoolStar defaults when no [BrandCubit] is in
  /// scope, so widgets stay usable in isolation.
  BrandState get brandState {
    try {
      return watch<BrandCubit>().state;
    } on Object {
      // ProviderNotFoundException (flutter_bloc does not export the type).
      return BrandState.defaults;
    }
  }

  /// The name the app calls itself (institute brand name or "SkoolStar").
  String get appName => brandState.appName;
}
