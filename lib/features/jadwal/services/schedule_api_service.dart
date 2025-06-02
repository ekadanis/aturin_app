import 'package:flutter/material.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import '../../../core/services/api/activities/activity_api_service.dart';
import '../../../core/services/api/task/task_api_service.dart';
import '../../../core/services/api/alarm/alarm_api_service.dart';
import 'package:alarm/alarm.dart';

/// Schedule API Service that handles both Activities and Tasks
/// Following TaskService pattern for consistency
class ScheduleApiService {
  final ActivityApiService _activityApiService = ActivityApiService();
  final TaskApiService _taskApiService = TaskApiService();
  final AlarmApiService _alarmApiService = AlarmApiService();

  // ============================
  // AKTIVITAS CRUD OPERATIONS
  // ============================

  /// Get all aktivitas - following TaskService pattern
  Future<List<AktivitasModel>> getAllAktivitas() async {
    try {
      return await _activityApiService.getAllActivities();
    } catch (e) {
      debugPrint('Error fetching aktivitas: $e');
      rethrow;
    }
  }

  /// Get aktivitas by date - following TaskService pattern
  Future<List<AktivitasModel>> getAktivitasByDate(DateTime date) async {
    try {
      return await _activityApiService.getActivitiesByDate(date);
    } catch (e) {
      debugPrint('Error fetching aktivitas by date: $e');
      rethrow;
    }
  }

  /// Create aktivitas - following TaskService pattern
  Future<AktivitasModel?> createAktivitas(AktivitasModel aktivitas) async {
    try {
      return await _activityApiService.createActivity(aktivitas);
    } catch (e) {
      debugPrint('Error creating aktivitas: $e');
      rethrow;
    }
  }

  /// Update aktivitas - following TaskService pattern
  Future<AktivitasModel?> updateAktivitas({
    required String slug,
    AktivitasModel? data,
    String? status,
    int? alarmId,
  }) async {
    try {
      return await _activityApiService.updateActivity(slug, data!);
    } catch (e) {
      debugPrint('Error updating aktivitas: $e');
      rethrow;
    }
  }

  /// Delete aktivitas - following TaskService pattern
  Future<bool> deleteAktivitas(String slug) async {
    try {
      // Get aktivitas first to handle alarm cleanup
      final aktivitas = await _activityApiService.getActivityBySlug(slug);
      
      // Delete alarm if exists - same as TaskService
      if (aktivitas?.alarmId != null) {
        try {
          await Alarm.stop(aktivitas!.alarmId!);
          
          final allAlarms = await _alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((a) => a.id == aktivitas.alarmId).firstOrNull;
          if (existingAlarm != null) {
            await _alarmApiService.deleteAlarm(existingAlarm.slug);
          }
        } catch (e) {
          debugPrint('Error deleting aktivitas alarm: $e');
        }
      }

      return await _activityApiService.deleteActivity(slug);
    } catch (e) {
      debugPrint('Error deleting aktivitas: $e');
      rethrow;
    }
  }

  // ============================
  // TASK CRUD OPERATIONS
  // ============================

  /// Get all tasks - following TaskService pattern
  Future<List<Task>> getAllTasks() async {
    try {
      return await _taskApiService.getAllTasks();
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      rethrow;
    }
  }

  /// Get tasks by status - following TaskService pattern
  Future<Map<String, dynamic>?> getTasksByStatus(String status) async {
    try {
      return await _taskApiService.getTasksByStatus(status);
    } catch (e) {
      debugPrint('Error fetching tasks by status: $e');
      rethrow;
    }
  }
  /// Update task - following TaskService pattern
  Future<bool> updateTask({
    required String slug,
    String? status,
    int? alarmId,
  }) async {
    try {
      final result = await _taskApiService.updateTask(
        slug: slug,
        status: status,
        alarmId: alarmId,
      );
      return result.isSuccess;
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  /// Delete task - following TaskService pattern
  Future<bool> deleteTask(String slug) async {
    try {
      // Get task first to handle alarm cleanup
      final tasks = await _taskApiService.getAllTasks();
      final task = tasks.where((t) => t.slug == slug).firstOrNull;
      
      // Delete alarm if exists - same as TaskService
      if (task?.alarmId != null) {
        try {
          await Alarm.stop(task!.alarmId!);
          
          final allAlarms = await _alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((a) => a.id == task.alarmId).firstOrNull;
          if (existingAlarm != null) {
            await _alarmApiService.deleteAlarm(existingAlarm.slug);
          }
        } catch (e) {
          debugPrint('Error deleting task alarm: $e');
        }
      }

      final result = await _taskApiService.deleteTask(slug);
      return result.isSuccess;
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  // ============================
  // COMBINED SCHEDULE OPERATIONS
  // ============================

  /// Get combined schedule (aktivitas + tasks) for a specific date
  Future<Map<String, dynamic>> getScheduleByDate(DateTime date) async {
    try {
      final aktivitasList = await getAktivitasByDate(date);
      final allTasks = await getAllTasks();
      
      // Filter tasks by date
      final tasksForDate = allTasks.where((task) {
        final taskDate = DateTime(
          task.deadline.year,
          task.deadline.month,
          task.deadline.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);
        return taskDate.isAtSameMomentAs(targetDate);
      }).toList();

      return {
        'aktivitas': aktivitasList,
        'tasks': tasksForDate,
        'date': date,
      };
    } catch (e) {
      debugPrint('Error getting schedule by date: $e');
      rethrow;
    }
  }

  /// Get combined schedule for date range
  Future<Map<String, dynamic>> getScheduleByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final aktivitasList = await _activityApiService.getActivitiesByDateRange(startDate, endDate);
      final allTasks = await getAllTasks();
      
      // Filter tasks by date range
      final tasksInRange = allTasks.where((task) {
        final taskDate = DateTime(
          task.deadline.year,
          task.deadline.month,
          task.deadline.day,
        );
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day);
        
        return taskDate.isAfter(start.subtract(const Duration(days: 1))) &&
               taskDate.isBefore(end.add(const Duration(days: 1)));
      }).toList();

      return {
        'aktivitas': aktivitasList,
        'tasks': tasksInRange,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      debugPrint('Error getting schedule by date range: $e');
      rethrow;
    }
  }
  /// Count overdue tasks in schedule - removed aktivitas completion logic
  /// since schedule context doesn't support completed activities
  Future<Map<String, dynamic>?> countOverdueScheduleItems() async {
    try {
      final taskData = await _taskApiService.countLateTasks();
      
      return {
        'overdue_tasks': taskData?['overdue_tasks'] ?? 0,
        'total_overdue': taskData?['overdue_tasks'] ?? 0,
      };
    } catch (e) {
      debugPrint('Error counting overdue schedule items: $e');
      return null;
    }
  }
}
