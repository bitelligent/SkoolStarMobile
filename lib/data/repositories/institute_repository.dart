import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/institute_model.dart';

abstract class InstituteRepository {
  Future<InstituteInfo> getCurrent();
}

class InstituteRepositoryImpl implements InstituteRepository {
  const InstituteRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;

  @override
  Future<InstituteInfo> getCurrent() async {
    final json = await _dataSource.readJsonObject('assets/json/institute.json');
    return InstituteInfo.fromJson(json);
  }
}
