import 'package:flutter/material.dart';
import '../database/task_database.dart';
import '../models/task.dart';

class TaskService extends ChangeNotifier {
  final taskDatabase = TaskDatabase();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  // Fetch all tasks from the database
  Future<void> fetchTasks() async {
    final result = await taskDatabase.queryAll();
    _tasks = result.map((row) => Task.fromMap(row)).toList();
    notifyListeners();
  }

  // Get tasks filtered by the selected filter
  List<Task> getTasksByFilter(String filter) {
    switch (filter) {
      case 'Terlambat':
        return _tasks.where((task) => task.status == TaskStatus.late).toList();
      case 'Belum Selesai':
        return _tasks.where((task) => !task.isCompleted).toList();
      case 'Selesai':
        return _tasks.where((task) => task.isCompleted).toList();
      case 'Semua':
      default:
        return _tasks;
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(int? id) async {
    if (id == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final now = DateTime.now();
      final updatedTask = task.copyWith(
        isDone: !task.isDone,
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? now : null,
      );

      await taskDatabase.update(updatedTask.toMap());
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // Toggle alarm status
  Future<void> toggleAlarm(int? id) async {
    if (id == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final updatedTask = task.copyWith(
        isAlarmEnabled: !task.isAlarmEnabled,
        isAlarmActive: !task.isAlarmActive,
      );

      await taskDatabase.update(updatedTask.toMap());
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final result = await taskDatabase.queryAll();
    _tasks = result.map((row) => Task.fromMap(row)).toList();
    notifyListeners();
    return _tasks;
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    final row = await taskDatabase.queryById(id);
    if (row != null) {
      return Task.fromMap(row);
    }
    return null;
  }

  // Add a new task
  Future<int> addTask(Task task) async {
    final id = await taskDatabase.insert(task.toMap());
    await fetchTasks(); // Refresh the task list
    return id;
  }

  // Update an existing task
  Future<int> updateTask(Task task) async {
    final result = await taskDatabase.update(task.toMap());
    await fetchTasks(); // Refresh the task list
    return result;
  }

  // Delete a task
  Future<int> deleteTask(int? id) async {
    if (id == null) return 0;
    final result = await taskDatabase.delete(id);
    await fetchTasks(); // Refresh the task list
    return result;
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    await taskDatabase.deleteAll();
    await fetchTasks(); // Refresh the task list
  }

  String? validateTitle(String? value) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) return 'Judul wajib diisi';
  if (trimmed.length > 20) return 'Judul maksimal 20 karakter';
  return null;
}


  String? validateDeadline(DateTime? deadline) {
    if (deadline == null) return 'Deadline wajib diisi';
    return null;
  }

  String? validateDuration(Duration? duration) {
    if (duration == null) return 'Estimasi waktu wajib diisi';
    return null;
  }

  String? validateCategory(dynamic category) {
    if (category == null) return 'Kategori wajib diisi';
    return null;
  }

  String? validateAlarm(DateTime? deadline, DateTime? alarm) {
    if (alarm == null) return 'Waktu alarm wajib diisi';
    if (deadline != null && alarm.isAfter(deadline)) {
      return 'Alarm harus sebelum deadline';
    }
    return null;
  }

  bool canEnableAlarm(DateTime? deadline) {
    return deadline != null &&
        deadline.isAfter(DateTime.now().add(Duration(hours: 1)));
  }

  Future<void> saveTaskForm({required bool isEdit, required Task task}) async {
    if (isEdit) {
      await updateTask(task);
    } else {
      await addTask(task);
    }
  }

  Future<void> handleSaveForm({
  required GlobalKey<FormState> formKey,
  required Task task,
  required bool isEdit,
  required VoidCallback onSuccess,
  required void Function(String message) onError,
}) async {
  if (!formKey.currentState!.validate()) return;

  try {
    await saveTaskForm(isEdit: isEdit, task: task);
    onSuccess();
  } catch (e) {
    onError('Gagal menyimpan tugas');
  }
}
bool isDeadlineValid(DateTime? deadline) {
  return deadline != null &&
         deadline.isAfter(DateTime.now().add(Duration(hours: 1)));
}

}
