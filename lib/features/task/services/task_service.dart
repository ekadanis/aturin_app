import 'dart:async';
import 'package:flutter/material.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/task/services/task_utility_service.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';

/// TaskService refactored - Menggunakan API service dan utility service
class TaskService extends ChangeNotifier {
  final TaskApiService _taskApiService;
  final AlarmApiService _alarmApiService;
  final TaskUtilityService _utilityService;
    Timer? _statusChecker;
  bool _isStatusCheckerStarted = false;

  /// Constructor - Takes dependencies via DI
  TaskService({
    required TaskApiService taskApiService,
    required AlarmApiService alarmApiService,
    TaskUtilityService? utilityService,
  }) : _taskApiService = taskApiService,
       _alarmApiService = alarmApiService,
       _utilityService = utilityService ?? TaskUtilityService();

  /// State access
  List<Task> get tasks => _taskApiService.tasks;
  bool get isLoading => _taskApiService.isLoading;
  String? get errorMessage => _taskApiService.errorMessage;
    /// API Data Access - Delegate to API service
    // Fetch tasks from API
  Future<void> fetchTasks() async {
    await _taskApiService.fetchTasks();
  }
  
  // Force refresh from API
  Future<void> forceRefresh() async {
    await _taskApiService.fetchTasks();
  }
  
  // Get task by slug
  Future<Task?> getTaskBySlug(String slug) async {
    return await _taskApiService.getTaskBySlug(slug);
  }
    /// Business Logic and Task Operations
  
  // Filter tasks by status
  List<Task> getTasksByFilter(String filter) {
    return _utilityService.filterTasksByStatus(tasks, filter);
  }// Toggle task completion status
  Future<bool> toggleTaskCompletion(String? slug) async {
    if (slug == null) return false;
    
    try {
      final task = await getTaskBySlug(slug);
      if (task == null) return false;
      
      // Prepare new status
      final newStatus = task.isCompleted 
          ? TaskDatabaseStatus.belumSelesai 
          : TaskDatabaseStatus.selesai;
      
      // Call API to update task
      final result = await _taskApiService.updateTask(
        slug: slug,
        status: newStatus.value,
      );
        if (result.isSuccess) {
        // Refresh data
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      return false;
    }
  }
  /// Helper method for simple alarm toggle (used by UI)
  Future<bool> toggleTaskAlarmStatus(String slug) async {
    try {
      final task = await getTaskBySlug(slug);
      if (task == null) return false;
      
      final newAlarmId = task.isAlarmEnabled ? null : task.alarmId;
      
      final result = await _taskApiService.updateTask(
        slug: slug,
        alarmId: newAlarmId,
      );
        if (result.isSuccess) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling task alarm: $e');
      return false;
    }
  }
    // Add a new task
  Future<bool> addTask(Task task) async {
    try {
      // Prepare alarm if needed
      int? alarmId;
      
      if (task.isAlarmEnabled && _utilityService.isAlarmTimeValid(task.deadline)) {
        final alarmModel = _utilityService.prepareAlarmForTask(task);
        if (alarmModel != null) {
          final alarmResult = await _alarmApiService.createAlarm(alarmModel);
          if (alarmResult != null) {
            alarmId = alarmResult.id;
          }
        }
      }
      
      // Create task with API
      final result = await _taskApiService.createTask(
        title: task.title,
        description: task.description,
        deadline: task.deadline,
        estimatedDuration: task.estimatedDuration.toString(),
        category: task.category,
        alarmId: alarmId,
      );
      
      // Refresh data if successful
      if (result.isSuccess) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error adding task: $e');
      return false;
    }
  }
    // Update task
  Future<bool> updateTask(Task task) async {
    try {
      if (task.slug == null) return false;
      
      // Manage alarm
      int? alarmId = task.alarmId;
      
      if (task.isAlarmEnabled && _utilityService.isAlarmValid(task.deadline)) {
        // Update existing alarm or create new one
        if (task.alarmId != null && task.alarm?.slug != null) {
          // Update existing alarm
          final alarmTime = task.alarmDateTime ?? _utilityService.getRecommendedAlarmTime(task.deadline);
          final alarmModel = AlarmModel(
            id: task.alarmId,
            slug: task.alarm!.slug,
            alarmDateTime: alarmTime,
            alarmEnabled: true,
          );
          await _alarmApiService.updateAlarm(task.alarm!.slug, alarmModel);
        } else {
          // Create new alarm
          final alarmModel = _utilityService.prepareAlarmForTask(task);
          if (alarmModel != null) {
            final alarmResult = await _alarmApiService.createAlarm(alarmModel);
            if (alarmResult != null) {
              alarmId = alarmResult.id;
            }
          }
        }
      } else if (task.alarmId != null && task.alarm?.slug != null) {
        // Remove alarm if disabled
        await _alarmApiService.deleteAlarm(task.alarm!.slug);
        alarmId = null;
      }
      
      // Call API to update task
      final result = await _taskApiService.updateTask(
        slug: task.slug!,
        title: task.title,
        description: task.description,
        deadline: task.deadline,
        estimatedDuration: task.estimatedDuration.toString(),
        category: task.category,
        alarmId: alarmId,
        status: task.taskStatus.name,
      );
      
      // Refresh data if successful
      if (result.isSuccess) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating task: $e');
      return false;
    }
  }
    // Delete task
  Future<bool> deleteTask(String? slug) async {
    if (slug == null) return false;
    
    try {
      // Delete task and its alarm if exists
      final result = await _taskApiService.deleteTask(slug);
      
      if (result.isSuccess) {
        await fetchTasks();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      return false;
    }
  }
  
  /// Validation methods - Delegate to utility service
  String? validateTitle(String? value) => _utilityService.validateTitle(value);
  String? validateDeadline(DateTime? deadline) => _utilityService.validateDeadline(deadline);
  String? validateDuration(Duration? duration) => _utilityService.validateDuration(duration);
  String? validateCategory(dynamic category) => _utilityService.validateCategory(category);
  String? validateAlarm(DateTime? deadline, DateTime? alarm) => 
      _utilityService.validateAlarm(deadline, alarm);
  
  /// Status checking
  
  void startStatusChecker() {
    if (_isStatusCheckerStarted) return;
    _isStatusCheckerStarted = true;
    
    _statusChecker = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchTasks(); // Simply refresh data to get latest status from server
    });
  }
  
  /// UI Helper methods
  
  Future<void> handleSaveForm({
    required GlobalKey<FormState> formKey,
    required Task task,
    required bool isEdit,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!formKey.currentState!.validate()) return;
    
    try {
      final success = isEdit ? await updateTask(task) : await addTask(task);
      
      if (success) {
        onSuccess();
      } else {
        onError('Gagal ${isEdit ? 'memperbarui' : 'menambah'} tugas');
      }
    } catch (e) {
      onError('Terjadi kesalahan: $e');
    }
  }
  
  /// Alarm management
    // Enable all alarms
  Future<void> enableAllAlarms() async {
    try {
      // Iterate through tasks that should have alarms
      for (var task in tasks) {
        if (!task.isCompleted && 
            _utilityService.isAlarmValid(task.deadline) && 
            task.slug != null) {
          // If task has no alarm but should have one
          if (task.alarmId == null) {
            final alarmModel = _utilityService.prepareAlarmForTask(task);
            if (alarmModel != null) {
              final result = await _alarmApiService.createAlarm(alarmModel);
              if (result != null && result.id != null) {
                // Update task with new alarm
                await _taskApiService.updateTask(
                  slug: task.slug!,
                  alarmId: result.id,
                );
              }
            }
          }
        }
      }
      
      // Refresh data
      await fetchTasks();
    } catch (e) {
      debugPrint('Error enabling all alarms: $e');
    }
  }
  
  // Disable all alarms
  Future<void> disableAllAlarms() async {
    try {
      // Find tasks with alarms
      final tasksWithAlarms = tasks.where((t) => t.alarmId != null && t.slug != null).toList();
      
      for (var task in tasksWithAlarms) {
        // Update task to remove alarm reference
        await _taskApiService.updateTask(
          slug: task.slug!,
          alarmId: null,
        );
        
        // Delete the alarm if it has a slug
        if (task.alarm?.slug != null) {
          await _alarmApiService.deleteAlarm(task.alarm!.slug);
        }
      }
      
      // Refresh data
      await fetchTasks();
    } catch (e) {
      debugPrint('Error disabling all alarms: $e');
    }
  }

  @override
  void dispose() {
    _statusChecker?.cancel();
    _statusChecker = null;
    _isStatusCheckerStarted = false;
    super.dispose();
  }
}
