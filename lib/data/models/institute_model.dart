import 'package:freezed_annotation/freezed_annotation.dart';

part 'institute_model.freezed.dart';

@freezed
abstract class InstituteInfo with _$InstituteInfo {
  const factory InstituteInfo({
    required String id,
    required String name,
    required String type,
  }) = _InstituteInfo;
}
