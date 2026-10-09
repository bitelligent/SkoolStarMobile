import 'package:skoolstar_teacher_module/data/models/class_group.dart';
import 'package:skoolstar_teacher_module/data/repositories/teacher_catalog.dart';

abstract interface class ClassRepository {
  Future<List<ClassGroup>> getAll();
}

class ClassRepositoryImpl implements ClassRepository {
  const ClassRepositoryImpl(this._catalog);

  final TeacherCatalogSource _catalog;

  @override
  Future<List<ClassGroup>> getAll() async => (await _catalog.load()).classes;
}
