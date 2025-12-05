import 'package:get_storage/get_storage.dart';

import '../models/task.dart';

class TaskService {
  final _box = GetStorage();
  final _key = 'tasks';

  List<Task> getTasks() {
    List? data = _box.read<List>(_key);
    if (data == null) {
      return [];
    }
    return data.map((e) => Task.fromJson(e)).toList();
  }

  void saveTasks(List<Task> tasks) {
    _box.write(_key, tasks.map((e) => e.toJson()).toList());
  }
}
