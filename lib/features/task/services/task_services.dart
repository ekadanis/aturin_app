import '../database/task_database.dart';
import '../models/task.dart';

class TaskService {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Task>> getAllTasks() async {
    final result = await dbHelper.queryAll();
    return result.map((row) => Task.fromMap(row)).toList();
  }

  Future<Task?> getTaskById(int id) async {
    final row = await dbHelper.queryById(id);
    if (row != null) {
      return Task.fromMap(row);
    }
    return null;
  }

  Future<int> addTask(Task task) async {
    return await dbHelper.insert(task.toMap());
  }

  Future<int> updateTask(Task task) async {
    return await dbHelper.update(task.toMap());
  }

  Future<int> deleteTask(int id) async {
    return await dbHelper.delete(id);
  }

  Future<void> clearAllTasks() async {
    await dbHelper.deleteAll();
  }
}
