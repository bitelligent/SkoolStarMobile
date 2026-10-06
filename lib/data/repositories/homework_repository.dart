import 'package:skoolstar_teacher_module/data/datasources/local_json_data_source.dart';
import 'package:skoolstar_teacher_module/data/models/homework_model.dart';

abstract class HomeworkRepository {
  Future<List<Homework>> getForSession(String sessionId);
  Future<Homework> create(Homework homework);
}

class HomeworkRepositoryImpl implements HomeworkRepository {
  HomeworkRepositoryImpl(this._dataSource);

  final JsonDataSource _dataSource;
  final List<Homework> _memoryStore = [];
  bool _seeded = false;

  Future<void> _seed() async {
    if (_seeded) return;
    final list = await _dataSource.readJsonArray('assets/json/homeworks.json');
    _memoryStore.addAll(
      list.cast<Map<String, dynamic>>().map(Homework.fromJson),
    );
    _seeded = true;
  }

  @override
  Future<List<Homework>> getForSession(String sessionId) async {
    await _seed();
    return _memoryStore.where((h) => h.sessionId == sessionId).toList();
  }

  @override
  Future<Homework> create(Homework homework) async {
    await _seed();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final created = homework.copyWith(
      id: 'hw_${DateTime.now().millisecondsSinceEpoch}',
    );
    _memoryStore.add(created);
    return created;
  }
}
