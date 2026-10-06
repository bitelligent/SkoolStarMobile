import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/class_group.dart';

abstract class ClassRepository {
  Future<List<ClassGroup>> getAll();
}

class ClassRepositoryImpl implements ClassRepository {
  const ClassRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;

  @override
  Future<List<ClassGroup>> getAll() async {
    final list = await _dataSource.readJsonArray('assets/json/classes.json');
    return list
        .cast<Map<String, dynamic>>()
        .map(ClassGroup.fromJson)
        .toList();
  }
}
