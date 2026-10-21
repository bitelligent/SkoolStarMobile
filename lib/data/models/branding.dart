import 'package:equatable/equatable.dart';
import 'package:skoolstar_teacher_module/core/utils/json_utils.dart';

/// Institute branding from `GET /api/Schools/{id}/branding`.
class Branding extends Equatable {
  const Branding({
    required this.instituteId,
    this.brandName = '',
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.allowCustomBranding = true,
  });

  /// Tolerant of missing / oddly-typed fields (a brand must never be able to
  /// break login).
  factory Branding.fromJson(Json json) => Branding(
    instituteId: json.intOrNull('instituteId') ?? -1,
    brandName: json.str('brandName').trim(),
    logoUrl: json.strOrNull('logoUrl')?.trim(),
    primaryColor: json.strOrNull('primaryColor'),
    secondaryColor: json.strOrNull('secondaryColor'),
    // Absent means the institute did not opt out.
    allowCustomBranding: json.boolean('allowCustomBranding', fallback: true),
  );

  final int instituteId;
  final String brandName;

  /// Server-relative (`/uploads/institutes/8/logo.png`) or absolute.
  final String? logoUrl;

  /// `#RRGGBB`.
  final String? primaryColor;
  final String? secondaryColor;

  /// When `false` the institute's overrides must be ignored.
  final bool allowCustomBranding;

  Json toJson() => {
    'instituteId': instituteId,
    'brandName': brandName,
    'logoUrl': logoUrl,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'allowCustomBranding': allowCustomBranding,
  };

  @override
  List<Object?> get props => [
    instituteId,
    brandName,
    logoUrl,
    primaryColor,
    secondaryColor,
    allowCustomBranding,
  ];
}
