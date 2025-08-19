import 'package:aturin_app/features/task/data/model/task_model.dart';

/// Task utility functions
/// Pure functions without side effects for task-related operations
class TaskUtils {
  TaskUtils._(); // Private constructor to prevent instantiation

  /// Validation methods
  static String? validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Judul wajib diisi';
    if (trimmed.length > 20) return 'Judul maksimal 20 karakter';
    return null;
  }

  static String? validateDeadline(DateTime? deadline) {
    if (deadline == null) return 'Batas waktu wajib diisi';
    return null;
  }

  static String? validateDuration(Duration? duration) {
    if (duration == null) return 'Estimasi waktu wajib diisi';
    return null;
  }

  static String? validateCategory(dynamic category) {
    if (category == null) return 'Kategori wajib diisi';
    return null;
  }

  static String? validateAlarm(DateTime? deadline, DateTime? alarm) {
    if (alarm == null) return 'Waktu alarm wajib diisi';
    if (deadline != null && alarm.isAfter(deadline)) {
      return 'Alarm harus sebelum deadline';
    }
    return null;
  }

  /// Business rules
  static bool canEnableAlarm(DateTime? deadline) {
    return deadline != null && 
        deadline.isAfter(DateTime.now().add(const Duration(hours: 1)));
  }

  static bool isAlarmTimeValid(DateTime? deadline) {
    if (deadline == null) return false;
    // Alarm diatur 1 jam sebelum deadline, jika (deadline - 1 jam) masih di masa depan
    final alarmTime = deadline.subtract(const Duration(hours: 1));
    return alarmTime.isAfter(DateTime.now());
  }

  /// Status helpers
  static TaskStatus determineTaskStatus(Task task) {
    final now = DateTime.now();
    
    if (task.status == TaskStatus.completed) {
      return TaskStatus.completed;
    }
    
    if (task.deadline.isBefore(now)) {
      return TaskStatus.late;
    }
    
    return TaskStatus.upcoming;
  }

  /// Formatting helpers
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}j ${minutes}m';
  }

  static String formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      return 'Terlambat ${(-difference.inDays)} hari';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays} hari lagi';
    }
    
    if (difference.inHours > 0) {
      return '${difference.inHours} jam lagi';
    }
    
    return '${difference.inMinutes} menit lagi';
  }
}
