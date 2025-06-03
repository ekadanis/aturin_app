import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';

class HomeService extends ChangeNotifier {
  // API Services
  final TaskApiService _taskApiService = TaskApiService();
  final ActivityApiService _activityApiService = ActivityApiService();
  
  // Data lists
  List<Task> _tasks = [];
  List<AktivitasModel> _aktivitas = [];
  
  // Loading state
  bool _isLoading = false;
  
  // Stream controllers untuk real-time updates
  final StreamController<List<Task>> _tasksController = StreamController<List<Task>>.broadcast();
  final StreamController<List<AktivitasModel>> _aktivitasController = StreamController<List<AktivitasModel>>.broadcast();
  
  // Streams
  Stream<List<Task>> get tasksStream => _tasksController.stream;
  Stream<List<AktivitasModel>> get aktivitasStream => _aktivitasController.stream;

  // Getter that returns only today's tasks sorted by deadline
  List<Task> get todayTasks {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter tasks for today and sort them by deadline
    final todayTasksList = _tasks.where((task) {
      // Include tasks from today
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      return taskDate.isAtSameMomentAs(today);
    }).toList()
    ..sort((a, b) {
      // Belum dikerjakan duluan, lalu selesai
      if (a.status != TaskStatus.completed &&
          b.status == TaskStatus.completed) {
        return -1;
      }
      if (a.status == TaskStatus.completed &&
          b.status != TaskStatus.completed) {
        return 1;
      }
      // Urutkan berdasarkan deadline
      return a.deadline.compareTo(b.deadline);
    });

    return todayTasksList;
  }

  // Getter that returns only today's activities sorted by start time
  List<AktivitasModel> get todayAktivitas {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter activities for today and sort them by start time
    final todayAktivitasList = _aktivitas.where((aktivitas) {
      // Include activities from today
      final aktivitasDate = DateTime(
        aktivitas.activityDate.year,
        aktivitas.activityDate.month,
        aktivitas.activityDate.day,
      );
      return aktivitasDate.isAtSameMomentAs(today);
    }).toList()
    ..sort((a, b) {
      // Urutkan berdasarkan start time
      return a.activityStartTime.compareTo(b.activityStartTime);
    });

    return todayAktivitasList;
  }

  // Backward compatibility - alias for todayTasks
  List<Task> get tasks => todayTasks;

  // Getter for all tasks (unfiltered)
  List<Task> get allTasks => _tasks;
  
  // Loading state getter
  bool get isLoading => _isLoading;
  HomeService() {
    // Constructor tidak lagi melakukan auto-fetch
    // Widget yang membutuhkan data harus secara explicit memanggil fetchData()
    debugPrint('🏠 HomeService: Initialized without auto-fetch to prevent double fetch');
  }
  // Fetch both tasks and activities from the API - REAL TIME
  Future<void> fetchData({bool showLoading = true}) async {
    final stackTrace = StackTrace.current;
    debugPrint('🚀 HomeService: fetchData() called from: ${stackTrace.toString().split('\n')[1]}');
    
    if (_isLoading) {
      debugPrint('🔄 HomeService: Already loading, skipping fetch');
      return;
    }

    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      debugPrint('🚀 HomeService: Fetching fresh data...');
        // Fetch both tasks and activities in parallel
      await Future.wait([
        _fetchTasks(),
        _fetchActivities(),
      ]);

      // Update streams dengan data terbaru
      _tasksController.add(todayTasks);
      _aktivitasController.add(todayAktivitas);

      debugPrint('✅ HomeService: Data updated - ${_tasks.length} tasks, ${_aktivitas.length} activities');
      
    } catch (e) {
      debugPrint('❌ HomeService: Error in fetchData: $e');
    } finally {
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  // Private method untuk fetch tasks
  Future<void> _fetchTasks() async {
    try {
      _tasks = await _taskApiService.getTasksToday();
      debugPrint('✅ HomeService: Fetched ${_tasks.length} tasks from API');
    } catch (e) {
      debugPrint('❌ HomeService: Error fetching tasks: $e');
      _tasks = [];
    }
  }

  // Private method untuk fetch activities
  Future<void> _fetchActivities() async {
    try {
      _aktivitas = await _activityApiService.getTodayActivities();
      debugPrint('✅ HomeService: Fetched ${_aktivitas.length} activities from API');
    } catch (e) {
      debugPrint('❌ HomeService: Error fetching activities: $e');
      _aktivitas = [];
    }
  }

  // Legacy method for backward compatibility
  Future<void> fetchTasks() async {
    await fetchData();
  }

  List<Task> get nonAcademicTasks {
    return _tasks
        .where((task) => task.category != TaskCategory.akademik)
        .toList();
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
          task.status != TaskStatus.completed;
    }).length;
  }

  // Count today's activities
  int getTodayActivitiesCount() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _aktivitas.where((aktivitas) {
      final aktivitasDate = DateTime(
        aktivitas.activityDate.year,
        aktivitas.activityDate.month,
        aktivitas.activityDate.day,
      );
      return aktivitasDate.isAtSameMomentAs(today);
    }).length;
  }

  // Force refresh untuk memastikan data terbaru
  Future<void> forceRefresh() async {
    debugPrint('🔄 HomeService: Force refresh triggered');
    await fetchData(showLoading: true);
  }

  // Refresh tanpa loading indicator untuk background updates
  Future<void> refreshSilently() async {
    debugPrint('🔄 HomeService: Silent refresh triggered');
    await fetchData(showLoading: false);
  }

  Future<void> toggleTaskCompletion(int? id) async {
    if (id == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      
      if (task.slug == null) {
        debugPrint('❌ HomeService: Cannot toggle task completion - slug is null');
        return;
      }

      try {
        // Toggle status antara selesai dan belum_selesai
        final newStatus = task.isCompleted ? 'belum_selesai' : 'selesai';

        // Update via API
        final result = await _taskApiService.updateTask(
          slug: task.slug!,
          status: newStatus,
        );

        if (result.isSuccess) {
          debugPrint('✅ HomeService: Task completion toggled successfully');
          // Refresh data setelah update
          await refreshSilently();
        } else {
          debugPrint('❌ HomeService: Failed to toggle task completion via API: ${result.message}');
        }
      } catch (e) {
        debugPrint('❌ HomeService: Error toggling task completion: $e');
      }
    }
  }

  Future<void> toggleAlarm(int? id) async {
    if (id == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      
      // Toggle alarm enabled status
      AlarmModel? updatedAlarm;
      if (task.alarm != null) {
        updatedAlarm = AlarmModel(
          id: task.alarm!.id,
          alarmDateTime: task.alarm!.alarmDateTime,
          alarmEnabled: !task.alarm!.alarmEnabled,
          slug: task.alarm!.slug,
        );
      }

      final updatedTask = task.copyWith(
        alarm: updatedAlarm,
      );

      // Update local data only (no database operations)
      _tasks[index] = updatedTask;
      
      debugPrint('✅ HomeService: Alarm toggled locally');
      notifyListeners();
      
      // Update streams
      _tasksController.add(todayTasks);
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      // Find task by ID
      final task = _tasks.where((t) => t.id == taskId).firstOrNull;
      if (task?.slug == null) {
        debugPrint('❌ HomeService: Cannot delete task - slug is null for task ID: $taskId');
        return;
      }

      // Delete via API
      final result = await _taskApiService.deleteTask(task!.slug!);
      
      if (result.isSuccess) {
        debugPrint('✅ HomeService: Task deleted successfully');
        // Refresh data setelah delete
        await refreshSilently();
      } else {
        debugPrint('❌ HomeService: Failed to delete task via API: ${result.message}');
      }
    } catch (e) {
      debugPrint('❌ HomeService: Error deleting task: $e');
    }
  }
  
  Future<void> deleteActivity(int activityId) async {
    try {
      // Find activity by ID
      final activity = _aktivitas.where((a) => a.id == activityId).firstOrNull;
      if (activity?.slug == null) {
        debugPrint('❌ HomeService: Cannot delete activity - slug is null for activity ID: $activityId');
        return;
      }

      // Delete via API
      final success = await _activityApiService.deleteActivity(activity!.slug!);
      
      if (success) {
        debugPrint('✅ HomeService: Activity deleted successfully');
        // Refresh data setelah delete
        await refreshSilently();
      } else {
        debugPrint('❌ HomeService: Failed to delete activity via API');
      }
    } catch (e) {
      debugPrint('❌ HomeService: Error deleting activity: $e');
    }
  }

  // Method untuk dipanggil dari luar ketika ada perubahan
  Future<void> onTaskChanged() async {
    debugPrint('🔄 HomeService: Task changed event received');
    await refreshSilently();
  }

  Future<void> onActivityChanged() async {
    debugPrint('🔄 HomeService: Activity changed event received');
    await refreshSilently();
  }

  Future<void> onDataChanged() async {
    debugPrint('🔄 HomeService: Data changed event received');
    await refreshSilently();
  }

  @override
  void dispose() {
    _tasksController.close();
    _aktivitasController.close();
    super.dispose();
  }
}