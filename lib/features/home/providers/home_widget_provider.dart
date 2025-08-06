import 'package:flutter/foundation.dart';
import 'package:aturin_app/features/home/services/home_widget_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/features/home/services/widget_background_service.dart';

/// Provider untuk mengelola state Home Widget
class HomeWidgetProvider extends ChangeNotifier {
  final HomeWidgetService _homeWidgetService = HomeWidgetService();
  final ActivityApiService _activityApiService = ActivityApiService();
  final TaskApiService _taskApiService = TaskApiService();
  
  bool _isInitialized = false;
  bool _isUpdating = false;
  DateTime? _lastUpdate;
  Map<String, dynamic>? _lastWidgetData;
  String? _error;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isUpdating => _isUpdating;
  DateTime? get lastUpdate => _lastUpdate;
  Map<String, dynamic>? get lastWidgetData => _lastWidgetData;
  String? get error => _error;

  /// Initialize home widget service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _error = null;
      await _homeWidgetService.initialize();
      _isInitialized = true;
      
      // Initial update
      await updateWidget();
      
      // Check for pending widget interactions
      await _processPendingInteractions();
      
      // Start background service untuk auto-update
      WidgetBackgroundService.startDailyUpdate(this);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  /// Process any pending widget interactions
  Future<void> _processPendingInteractions() async {
    try {
      final pendingAction = await _homeWidgetService.checkPendingInteractions();
      if (pendingAction != null) {
        await _homeWidgetService.handleWidgetInteraction(pendingAction);
        
        // Set pending navigation request (akan diproses oleh HomePage)
        _pendingNavigation = pendingAction;
        notifyListeners();
      }
    } catch (e) {
    }
  }
  
  // Pending navigation request
  String? _pendingNavigation;
  String? get pendingNavigation => _pendingNavigation;
  
  // Clear pending navigation after processed
  void clearPendingNavigation() {
    _pendingNavigation = null;
    notifyListeners();
  }

  /// Update widget dengan data terbaru dari repository
  Future<void> updateWidget({
    List<dynamic>? activities,
    List<dynamic>? tasks,
  }) async {
    if (_isUpdating) return;
    
    try {
      _isUpdating = true;
      _error = null;
      notifyListeners();

      // Convert data to ScheduleItem format
      final List<ScheduleItem> activityItems = [];
      final List<ScheduleItem> taskItems = [];
      
      
      // Process activities
      if (activities != null) {
        for (var activity in activities) {
          try {
            final scheduleItem = ScheduleItem(
              id: activity['id']?.toString() ?? '',
              title: activity['activity_title'] ?? 'Aktivitas',
              date: _parseDate(activity['activity_date']),
              time: _parseActivityTime(activity['activity_date'], activity['activity_start_time']),
              type: 'activity',
              category: activity['activity_category'] ?? 'umum',
            );
            activityItems.add(scheduleItem);
          } catch (e) {
          }
        }
      }
      
      // Process tasks
      if (tasks != null) {
        for (var task in tasks) {
          try {
            final taskDate = _parseDate(task['task_deadline']);
            final taskTime = _parseTime(task['task_deadline']);
            final scheduleItem = ScheduleItem(
              id: task['id']?.toString() ?? '',
              title: task['task_title'] ?? 'Tugas',
              date: taskDate,
              time: taskTime,
              type: 'task',
              category: task['task_category'] ?? 'umum',
            );
            taskItems.add(scheduleItem);
          } catch (e) {
          }
        }
      }

      await _homeWidgetService.updateTodaySchedule(
        activities: activityItems,
        tasks: taskItems,
      );
      
      _lastUpdate = DateTime.now();
      _lastWidgetData = await _homeWidgetService.getWidgetData();
      
    } catch (e) {
      _error = e.toString();
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
  
  /// Helper untuk parse tanggal dari berbagai format
  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    
    if (dateValue is DateTime) return dateValue;
    
    if (dateValue is String) {
      try {
        // Parse and convert to local time
        final parsedDate = DateTime.parse(dateValue);
        // Convert UTC to local time
        final localDate = parsedDate.toLocal();
        return localDate;
      } catch (e) {
        return DateTime.now();
      }
    }
    
    return DateTime.now();
  }
  
  /// Helper untuk parse waktu dari berbagai format
  DateTime _parseTime(dynamic timeValue) {
    final now = DateTime.now();
    
    if (timeValue == null) return now;
    
    if (timeValue is DateTime) return timeValue;
    
    if (timeValue is String) {
      try {
        // Format ISO8601 (untuk tasks deadline)
        if (timeValue.contains('T') && timeValue.contains('Z')) {
          return DateTime.parse(timeValue).toLocal();
        }
        
        // Format HH:mm
        if (timeValue.contains(':') && !timeValue.contains('T')) {
          final parts = timeValue.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return now.copyWith(hour: hour, minute: minute, second: 0, millisecond: 0);
        }
        
        // Format waktu lain
        return DateTime.parse(timeValue);
      } catch (e) {
        return now;
      }
    }
    
    return now;
  }

  /// Helper untuk parse waktu activity dengan menggabungkan date dan time
  DateTime _parseActivityTime(dynamic dateValue, dynamic timeValue) {
    final baseDate = _parseDate(dateValue);
    
    if (timeValue == null) return baseDate;
    
    if (timeValue is String && timeValue.contains(':')) {
      try {
        final parts = timeValue.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return baseDate.copyWith(hour: hour, minute: minute, second: 0, millisecond: 0);
      } catch (e) {
        return baseDate;
      }
    }
    
    return baseDate;
  }

  /// Force refresh widget (untuk manual trigger)
  Future<void> forceRefresh() async {
    
    try {
      
      // Fetch data dari server
      await _activityApiService.fetchActivities(forceRefresh: true);
      await _taskApiService.fetchTasks(forceRefresh: true);
      
      // Ambil data dan convert ke Map
      final activitiesData = _activityApiService.activities.map((a) => a.toMap()).toList();
      final tasksData = _taskApiService.tasks.map((t) => t.toMap()).toList();
      
      
      await updateWidget(activities: activitiesData, tasks: tasksData);
    } catch (e) {
      await updateWidget(activities: [], tasks: []);
    }
  }

  /// Handle widget interaction
  Future<void> handleWidgetInteraction(String? action) async {
    await _homeWidgetService.handleWidgetInteraction(action);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Stop background service
    WidgetBackgroundService.stop();
    super.dispose();
  }
}
