import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/subject_model.dart';

abstract class SubjectRepository {
  Future<List<Subject>> getAll();
}

class SubjectRepositoryImpl implements SubjectRepository {
  const SubjectRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;

  @override
  Future<List<Subject>> getAll() async {
    final list = await _dataSource.readJsonArray('assets/json/subjects.json');
    return list
        .cast<Map<String, dynamic>>()
        .map(Subject.fromJson)
        .toList();
  }
}
