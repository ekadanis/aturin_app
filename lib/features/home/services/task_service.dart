import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/task/database/task_database.dart';
import 'package:aturin_app/features/task/model/task.dart' as TaskModel;
import 'package:aturin_app/features/home/models/task_model.dart';

class TaskService extends ChangeNotifier {
  final taskDatabase = TaskDatabase();
  List<Task> _tasks = [];
  Timer? _statusChecker;
  
  // Cache dan throttling untuk optimasi performa
  List<Task>? _cachedTodayTasks;
  DateTime _lastFetchTime = DateTime(1970);

  // Getter that returns only today's tasks sorted by deadline
  List<Task> get tasks {
    // Gunakan cache jika tersedia
    if (_cachedTodayTasks != null) {
      return _cachedTodayTasks!;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Filter tasks for today and sort them by deadline
    _cachedTodayTasks = _tasks
      .where((task) {
        // Include tasks from today
        final taskDate = DateTime(
          task.deadline.year,
          task.deadline.month,
          task.deadline.day,
        );
        return taskDate.isAtSameMomentAs(today);
      })
      .toList()
      ..sort((a, b) {
        // Belum dikerjakan duluan, lalu selesai
        if (a.status != TaskStatus.selesai && b.status == TaskStatus.selesai) {
          return -1;
        }
        if (a.status == TaskStatus.selesai && b.status != TaskStatus.selesai) {
          return 1;
        }
        // Urutkan berdasarkan deadline
        return a.deadline.compareTo(b.deadline);
      });
      
    return _cachedTodayTasks!;
  }

  // Getter for all tasks (unfiltered)
  List<Task> get allTasks => _tasks;

  TaskService() {
    fetchTasks();
    startStatusChecker();
  }

  // Fetch all tasks from the database and convert to Home Task model
  Future<void> fetchTasks() async {
    // Throttling: Batasi fetch maksimal sekali tiap 2 detik
    final now = DateTime.now();
    if (now.difference(_lastFetchTime).inSeconds < 2 && _tasks.isNotEmpty) {
      debugPrint('Home: Using cached tasks (fetched ${now.difference(_lastFetchTime).inSeconds}s ago)');
      return;
    }
    
    try {
      final result = await taskDatabase.queryAll();
      final dbTasks = result.map((row) => TaskModel.Task.fromMap(row)).toList();
      
      // Convert from TaskModel.Task to home's Task model
      _tasks = dbTasks.map((dbTask) {
        return Task(
          category: _convertToHomeCategory(dbTask.category),
          title: dbTask.title,
          timeRange: _formatTimeRange(dbTask.deadline, dbTask.estimatedDuration),
          status: _convertToHomeStatus(dbTask.isCompleted),
          deadline: dbTask.deadline,
          isAlarmEnabled: dbTask.isAlarmEnabled,
          isLateCompletion: dbTask.isCompleted && 
              (dbTask.status == TaskModel.TaskStatus.late || 
               (dbTask.completedAt != null && dbTask.completedAt!.isAfter(dbTask.deadline))),
        );
      }).toList();
      
      // Reset cache
      _cachedTodayTasks = null;
      _lastFetchTime = now;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      _tasks = [];
      notifyListeners();
    }
  }

  // Convert status to just two options: selesai or belumDikerjakan
  TaskStatus _convertToHomeStatus(bool isCompleted) {
    return isCompleted ? TaskStatus.selesai : TaskStatus.belumDikerjakan;
  }

  // Convert category string to home's TaskCategory enum
  TaskCategory _convertToHomeCategory(String category) {
    final categoryLower = category.toLowerCase();
    
    if (categoryLower.contains('akademik')) return TaskCategory.akademik;
    if (categoryLower.contains('hiburan')) return TaskCategory.hiburan;
    if (categoryLower.contains('pekerjaan')) return TaskCategory.pekerjaan;
    if (categoryLower.contains('olahraga')) return TaskCategory.olahraga;
    if (categoryLower.contains('sosial')) return TaskCategory.sosial;
    if (categoryLower.contains('spiritual')) return TaskCategory.spiritual;
    if (categoryLower.contains('pribadi')) return TaskCategory.pribadi;
    if (categoryLower.contains('istirahat')) return TaskCategory.istirahat;
    
    return TaskCategory.akademik;
  }

  String _formatTimeRange(DateTime deadline, Duration duration) {
    final hour = deadline.hour.toString().padLeft(2, '0');
    final minute = deadline.minute.toString().padLeft(2, '0');
    
    final endHour = (deadline.hour + duration.inHours) % 24;
    final endMinute = (deadline.minute + (duration.inMinutes % 60)) % 60;
    final endHourStr = endHour.toString().padLeft(2, '0');
    final endMinuteStr = endMinute.toString().padLeft(2, '0');
    
    return '$hour:$minute – $endHourStr:$endMinuteStr';
  }

  void startStatusChecker() {
    _statusChecker?.cancel();
    _statusChecker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => fetchTasks(),
    );
  }

  void stopStatusChecker() {
    _statusChecker?.cancel();
    _statusChecker = null;
  }

  // Count today's tasks that aren't completed
  int getTodayTasksCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _tasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      return taskDate.isAtSameMomentAs(today) && 
             task.status != TaskStatus.selesai;
    }).length;
  }

  // Force refresh untuk memastikan data terbaru
  Future<void> forceRefresh() async {
    _cachedTodayTasks = null;
    _lastFetchTime = DateTime(1970); // Reset waktu fetch terakhir
    await fetchTasks();
  }

  @override
  void dispose() {
    stopStatusChecker();
    super.dispose();
  }
}
