import 'package:flutter/material.dart';
import '../database/task_database.dart';
import '../models/task.dart';
import '../../alarm/services/alarm_service.dart';
import 'package:alarm/alarm.dart' as alarm_package;

class TaskService extends ChangeNotifier {
  final taskDatabase = TaskDatabase();
  final AlarmService _alarmService = AlarmService();
  List<Task> _tasks = [];
  bool _isAlarmInitialized = false;

  List<Task> get tasks => _tasks;

  // Konstruktor dengan inisialisasi alarm
  TaskService() {
    _initializeAlarm();
  }

  // Inisialisasi alarm package
  Future<void> _initializeAlarm() async {
    if (!_isAlarmInitialized) {
      await alarm_package.Alarm.init();
      _isAlarmInitialized = true;
    }
  }

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
      
      // Update alarm status
      await _alarmService.updateAlarmStatus(updatedTask);
      
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

  // Add a new task with automatic alarm setup
  Future<int> addTask(Task task) async {
    // Simpan task di database
    final id = await taskDatabase.insert(task.toMap());
    
    // Buat task baru dengan ID yang baru saja diberikan database
    final newTask = Task(
      id: id,
      title: task.title,
      deadline: task.deadline,
      estimatedDuration: task.estimatedDuration,
      category: task.category,
      isAlarmEnabled: task.isAlarmEnabled,
      alarmDateTime: task.alarmDateTime,
    );
    
    // Setup alarm if enabled
    if (task.isAlarmEnabled && task.alarmDateTime != null) {
      await _alarmService.setAlarmForTask(newTask);
    }
    
    await fetchTasks(); // Refresh the task list
    return id;
  }

  // Update an existing task with automatic alarm update
  Future<int> updateTask(Task task) async {
    final result = await taskDatabase.update(task.toMap());
    
    // Update alarm status
    await _alarmService.updateAlarmStatus(task);
    
    await fetchTasks(); // Refresh the task list
    return result;
  }

  // Delete a task
  Future<int> deleteTask(int? id) async {
    if (id == null) return 0;
    
    // Remove alarm if exists
    await _alarmService.removeAlarmForTask(id);
    
    final result = await taskDatabase.delete(id);
    await fetchTasks(); // Refresh the task list
    return result;
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    // Stop all alarms for these tasks
    for (final task in _tasks) {
      if (task.id != null) {
        await _alarmService.removeAlarmForTask(task.id!);
      }
    }
    
    await taskDatabase.deleteAll();
    await fetchTasks(); // Refresh the task list
  }
}
