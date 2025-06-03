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

  // Cache dan throttling untuk optimasi performa
  List<Task>? _cachedTodayTasks;
  List<AktivitasModel>? _cachedTodayAktivitas;
  DateTime _lastFetchTime = DateTime(1970);

  final Map<String, List<Task>> _cachedFilteredTasks = {};  // Getter that returns only today's tasks sorted by deadline
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

  // Getter for all tasks (unfiltered)
  List<Task> get allTasks => _tasks;
  HomeService() {
    fetchData();
    startStatusChecker();
  }  // Fetch both tasks and activities from the API
  Future<void> fetchData() async {
    // Throttling: Batasi fetch maksimal sekali tiap 2 detik
    final now = DateTime.now();
    if (now.difference(_lastFetchTime).inSeconds < 2 &&
        _tasks.isNotEmpty &&
        _aktivitas.isNotEmpty) {
      debugPrint(
        'Home: Using cached data (fetched ${now.difference(_lastFetchTime).inSeconds}s ago)',
      );
      return;
    }
    try {
      // Fetch today's uncompleted tasks from API
      try {
        _tasks = await _taskApiService.getTasksToday();
        debugPrint('✅ HomeService: Fetched ${_tasks.length} uncompleted tasks today from API');
      } catch (e) {
        debugPrint('❌ HomeService: Error fetching today tasks from API: $e');
        // Fallback to empty data
        _tasks = [];
      }      // Fetch today's activities from API
      try {
        _aktivitas = await _activityApiService.getTodayActivities();
        debugPrint('✅ HomeService: Fetched ${_aktivitas.length} activities today from API');
      } catch (e) {
        debugPrint('❌ HomeService: Error fetching today activities from API: $e');
        // No fallback, just use empty data
        _aktivitas = [];
      }

      // Reset cache
      _cachedTodayTasks = null;
      _cachedTodayAktivitas = null;
      _lastFetchTime = now;

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching data: $e');
      _tasks = [];
      _aktivitas = [];
      notifyListeners();
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

  void startStatusChecker() {
    _statusChecker?.cancel();
    _statusChecker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => fetchData(),
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
    _cachedTodayTasks = null;
    _cachedTodayAktivitas = null;
    _lastFetchTime = DateTime(1970); // Reset waktu fetch terakhir
    await fetchData();
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
  }  Future<void> deleteTask(int taskId) async {
    try {
      // Find task by ID
      final task = _tasks.where((t) => t.id == taskId).firstOrNull;
      if (task?.slug == null) {
        debugPrint('❌ HomeService: Cannot delete task - slug is null for task ID: $taskId');
        return;
      }

      // Delete via API (this includes auto-refresh)
      final result = await _taskApiService.deleteTask(task!.slug!);
      
      if (result.isSuccess) {
        // Force refresh to get the latest data from API
        await forceRefresh();
        
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

      // Delete via API (this includes auto-refresh)
      final success = await _activityApiService.deleteActivity(activity!.slug!);
      
      if (success) {
        // Force refresh to get the latest data from API
        await forceRefresh();
        
        debugPrint('✅ HomeService: Activity deleted and data refreshed successfully');
      } else {
        debugPrint('❌ HomeService: Failed to delete activity via API');
      }
    } catch (e) {
      debugPrint('❌ HomeService: Error deleting activity: $e');
    }
  }

  // void updateFromBannerProfile(User user) {
  //   _tasks = user.todayTasks ?? [];
  //   _aktivitas = user.todayActivities ?? [];

  //   _cachedTodayTasks = null;
  //   _cachedTodayAktivitas = null;
  //   _lastFetchTime = DateTime.now();

  //   notifyListeners();
  // }

  @override
  void dispose() {
    stopStatusChecker();
    super.dispose();
  }
}
