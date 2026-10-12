import 'package:skoolstar_teacher_module/data/models/subject_model.dart';
import 'package:skoolstar_teacher_module/data/repositories/teacher_catalog.dart';

abstract interface class SubjectRepository {
  Future<List<Subject>> getAll();
}

class SubjectRepositoryImpl implements SubjectRepository {
  const SubjectRepositoryImpl(this._catalog);

  final TeacherCatalogSource _catalog;

  @override
  Future<List<Subject>> getAll() async => (await _catalog.load()).subjects;
}
