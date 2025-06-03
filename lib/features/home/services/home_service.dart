import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';

class HomeService extends ChangeNotifier {
  // API Services for today data
  final TaskApiService _taskApiService = TaskApiService();
  final ActivityApiService _activityApiService = ActivityApiService();
  
  List<Task> _tasks = [];
  List<AktivitasModel> _aktivitas = [];
  Timer? _statusChecker;

  // Cache untuk optimasi performa
  List<Task>? _cachedTodayTasks;
  List<AktivitasModel>? _cachedTodayAktivitas;
  
  // Flags untuk mendeteksi perubahan
  bool _tasksNeedRefresh = true;
  bool _activitiesNeedRefresh = true;
  bool _isLoading = false;

  final Map<String, List<Task>> _cachedFilteredTasks = {};

  // Getter that returns only today's tasks sorted by deadline
  List<Task> get todayTasks {
    // Gunakan cache jika tersedia
    if (_cachedTodayTasks != null) {
      return _cachedTodayTasks!;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter tasks for today and sort them by deadline
    _cachedTodayTasks =
        _tasks.where((task) {
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

    return _cachedTodayTasks!;
  }

  // Getter that returns only today's activities sorted by start time
  List<AktivitasModel> get todayAktivitas {
    // Gunakan cache jika tersedia
    if (_cachedTodayAktivitas != null) {
      return _cachedTodayAktivitas!;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Filter activities for today and sort them by start time
    _cachedTodayAktivitas =
        _aktivitas.where((aktivitas) {
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

    return _cachedTodayAktivitas!;
  }

  // Backward compatibility - alias for todayTasks
  List<Task> get tasks => todayTasks;

  // Backward compatibility - alias for todayAktivitas
  List<AktivitasModel> get aktivitas => todayAktivitas;

  // Getter for all tasks (unfiltered)
  List<Task> get allTasks => _tasks;
  
  // Getter for all activities (unfiltered)
  List<AktivitasModel> get allAktivitas => _aktivitas;
  
  // Loading state getter
  bool get isLoading => _isLoading;

  HomeService() {
    fetchData();
    startStatusChecker();
  }

  // Fetch both tasks and activities from the API
  Future<void> fetchData({bool force = false}) async {
    // Skip jika tidak ada perubahan dan tidak di-force
    if (!force && !_tasksNeedRefresh && !_activitiesNeedRefresh && !_isDataEmpty()) {
      debugPrint('Home: No changes detected, skipping fetch');
      return;
    }

    if (_isLoading) {
      debugPrint('Home: Already loading, skipping fetch');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch tasks hanya jika perlu
      if (_tasksNeedRefresh || _tasks.isEmpty || force) {
        try {
          _tasks = await _taskApiService.getTasksToday();
          _tasksNeedRefresh = false;
          _cachedTodayTasks = null; // Reset cache
          debugPrint('✅ HomeService: Fetched ${_tasks.length} tasks from API');
        } catch (e) {
          debugPrint('❌ HomeService: Error fetching tasks: $e');
          _tasks = [];
        }
      }

      // Fetch activities hanya jika perlu
      if (_activitiesNeedRefresh || _aktivitas.isEmpty || force) {
        try {
          _aktivitas = await _activityApiService.getTodayActivities();
          _activitiesNeedRefresh = false;
          _cachedTodayAktivitas = null; // Reset cache
          debugPrint('✅ HomeService: Fetched ${_aktivitas.length} activities from API');
        } catch (e) {
          debugPrint('❌ HomeService: Error fetching activities: $e');
          _aktivitas = [];
        }
      }

      // Reset cache
      _cachedFilteredTasks.clear();
      
    } catch (e) {
      debugPrint('❌ HomeService: General error in fetchData: $e');
      _tasks = [];
      _aktivitas = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to check if data is empty
  bool _isDataEmpty() {
    return _tasks.isEmpty && _aktivitas.isEmpty;
  }

  // Method untuk mark bahwa tasks perlu di-refresh
  void markTasksForRefresh() {
    _tasksNeedRefresh = true;
    _cachedTodayTasks = null;
    _cachedFilteredTasks.clear();
  }

  // Method untuk mark bahwa activities perlu di-refresh
  void markActivitiesForRefresh() {
    _activitiesNeedRefresh = true;
    _cachedTodayAktivitas = null;
  }

  // Method untuk refresh kedua data
  void markAllForRefresh() {
    markTasksForRefresh();
    markActivitiesForRefresh();
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

  void startStatusChecker() {
    _statusChecker?.cancel();
    _statusChecker = Timer.periodic(
      const Duration(minutes: 5), // Perbesar interval jadi 5 menit
      (_) {
        // Hanya check status jika tidak sedang loading
        if (!_isLoading) {
          fetchData();
        }
      },
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
          task.status != TaskStatus.completed;
    }).length;
  }

  // Force refresh untuk memastikan data terbaru
  Future<void> forceRefresh() async {
    markAllForRefresh();
    await fetchData(force: true);
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
          // Update local data only if API call succeeds
          final now = DateTime.now();
          final updatedTask = task.copyWith(
            taskStatus: task.isCompleted 
                ? TaskDatabaseStatus.belumSelesai 
                : TaskDatabaseStatus.selesai,
            completedAt: !task.isCompleted ? now : null,
          );

          _tasks[index] = updatedTask;
          
          // Reset cache untuk memaksa refresh tampilan
          _cachedTodayTasks = null;
          _cachedFilteredTasks.clear();

          debugPrint('✅ HomeService: Task completion toggled successfully');
          notifyListeners();
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
      
      // Reset cache
      _cachedTodayTasks = null;
      _cachedFilteredTasks.clear();
      
      debugPrint('✅ HomeService: Alarm toggled locally');
      notifyListeners();
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
        // Mark tasks for refresh dan fetch ulang
        markTasksForRefresh();
        await fetchData();
        
        debugPrint('✅ HomeService: Task deleted and data refreshed successfully');
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
        // Mark activities for refresh dan fetch ulang
        markActivitiesForRefresh();
        await fetchData();
        
        debugPrint('✅ HomeService: Activity deleted and data refreshed successfully');
      } else {
        debugPrint('❌ HomeService: Failed to delete activity via API');
      }
    } catch (e) {
      debugPrint('❌ HomeService: Error deleting activity: $e');
    }
  }

  // Method untuk dipanggil dari luar ketika ada perubahan
  Future<void> onTaskChanged() async {
    markTasksForRefresh();
    await fetchData();
  }

  Future<void> onActivityChanged() async {
    markActivitiesForRefresh();
    await fetchData();
  }

  Future<void> onDataChanged() async {
    markAllForRefresh();
    await fetchData();
  }

  @override
  void dispose() {
    stopStatusChecker();
    super.dispose();
  }
}