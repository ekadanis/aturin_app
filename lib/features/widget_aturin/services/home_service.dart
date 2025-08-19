import 'package:aturin_app/features/task/data/model/task_model.dart';
import 'package:aturin_app/features/schedule/data/model/aktivitas_model.dart';

/// HomeService - Pure utility service untuk logika Home screen
/// 
/// TUJUAN UTAMA:
/// - Computed properties untuk data Home screen
/// - Filter dan sorting logic
/// - Utility functions untuk dashboard statistics
/// 
/// TIDAK MELAKUKAN:
/// - API calls (gunakan TaskApiService/ActivityApiService via Provider)
/// - State management (gunakan GlobalStateService via Provider)
/// - Data fetching (gunakan Provider architecture)
/// 
/// PENGGUNAAN:
/// ```dart
/// final homeService = Provider.of<HomeService>(context);
/// final tasks = Provider.of<GlobalStateService>(context).allTasks;
/// final todayTasks = homeService.getTodayTasks(tasks);
/// ```
class HomeService {
  
  /// Filter tasks untuk hari ini dan sort berdasarkan deadline
  List<Task> getTodayTasks(List<Task> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allTasks.where((task) {
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
  }

  /// Filter aktivitas untuk hari ini dan sort berdasarkan start time
  List<AktivitasModel> getTodayActivities(List<AktivitasModel> allActivities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allActivities.where((aktivitas) {
      final aktivitasDate = DateTime(
        aktivitas.activityDate.year,
        aktivitas.activityDate.month,
        aktivitas.activityDate.day,
      );
      return aktivitasDate.isAtSameMomentAs(today);
    }).toList()
      ..sort((a, b) {
        return a.activityStartTime.compareTo(b.activityStartTime);
      });
  }

  /// Filter tasks yang bukan kategori akademik
  List<Task> getNonAcademicTasks(List<Task> allTasks) {
    return allTasks
        .where((task) => task.category != TaskCategory.akademik)
        .toList();
  }

  /// Hitung jumlah tasks hari ini yang belum selesai
  int getTodayTasksCount(List<Task> allTasks) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allTasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      return taskDate.isAtSameMomentAs(today) &&
          task.status != TaskStatus.completed;
    }).length;
  }

  /// Hitung jumlah aktivitas hari ini
  int getTodayActivitiesCount(List<AktivitasModel> allActivities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return allActivities.where((aktivitas) {
      final aktivitasDate = DateTime(
        aktivitas.activityDate.year,
        aktivitas.activityDate.month,
        aktivitas.activityDate.day,
      );
      return aktivitasDate.isAtSameMomentAs(today);
    }).length;
  }

  /// Get statistics untuk dashboard
  Map<String, int> getHomeStats(List<Task> allTasks, List<AktivitasModel> allActivities) {
    return {
      'todayTasks': getTodayTasksCount(allTasks),
      'todayActivities': getTodayActivitiesCount(allActivities),
      'totalTasks': allTasks.length,
      'totalActivities': allActivities.length,
      'completedTasks': allTasks.where((task) => task.status == TaskStatus.completed).length,
    };
  }

  /// Filter tasks by status
  List<Task> getTasksByStatus(List<Task> allTasks, TaskStatus status) {
    return allTasks.where((task) => task.status == status).toList();
  }

  /// Filter activities by category
  List<AktivitasModel> getActivitiesByCategory(
    List<AktivitasModel> allActivities, 
    String category
  ) {
    return allActivities.where((aktivitas) => 
      aktivitas.activityCategory.displayName.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  /// Get upcoming tasks (next 7 days)
  List<Task> getUpcomingTasks(List<Task> allTasks) {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));

    return allTasks.where((task) {
      return task.deadline.isAfter(now) && 
             task.deadline.isBefore(weekFromNow) &&
             task.status != TaskStatus.completed;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  /// Get overdue tasks
  List<Task> getOverdueTasks(List<Task> allTasks) {
    final now = DateTime.now();

    return allTasks.where((task) {
      return task.deadline.isBefore(now) && 
             task.status != TaskStatus.completed;
    }).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }


}
