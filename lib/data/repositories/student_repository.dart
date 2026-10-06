import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/student_model.dart';

abstract class StudentRepository {
  Future<List<Student>> getAll();
  Future<List<Student>> getByClassIds(List<String> classIds);
}

class StudentRepositoryImpl implements StudentRepository {
  const StudentRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;

  @override
  Future<List<Student>> getAll() async {
    final list = await _dataSource.readJsonArray('assets/json/students.json');
    return list
        .cast<Map<String, dynamic>>()
        .map(Student.fromJson)
        .toList();
  }

  @override
  Future<List<Student>> getByClassIds(List<String> classIds) async {
    final all = await getAll();
    if (classIds.isEmpty) return all;
    return all.where((s) => classIds.contains(s.classGroupId)).toList();
  }
}
