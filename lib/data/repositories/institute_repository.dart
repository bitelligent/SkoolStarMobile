import 'package:skoolstar_teacher_module/data/models/institute_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/auth_repository.dart';

abstract interface class InstituteRepository {
  Future<InstituteInfo> getCurrent();
}

/// The institute comes from the active login context, so no extra request.
class InstituteRepositoryImpl implements InstituteRepository {
  const InstituteRepositoryImpl(this._auth);

  final AuthRepository _auth;

  @override
  Future<InstituteInfo> getCurrent() async {
    final context = await _auth.requireContext();
    return InstituteInfo(
      id: '${context.instituteId ?? ''}',
      name: context.instituteName ?? '',
      type: (context.instituteTypeName ?? '').toUpperCase(),
    );
  }
}
