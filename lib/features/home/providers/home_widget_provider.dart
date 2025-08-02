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
      debugPrint('🏠 HomeWidgetProvider: Initialized successfully with background service');
    } catch (e) {
      _error = e.toString();
      debugPrint('🏠 HomeWidgetProvider: Initialization error: $e');
      notifyListeners();
    }
  }
  
  /// Process any pending widget interactions
  Future<void> _processPendingInteractions() async {
    try {
      final pendingAction = await _homeWidgetService.checkPendingInteractions();
      if (pendingAction != null) {
        debugPrint('🏠 HomeWidgetProvider: Processing pending action: $pendingAction');
        await _homeWidgetService.handleWidgetInteraction(pendingAction);
        
        // Set pending navigation request (akan diproses oleh HomePage)
        _pendingNavigation = pendingAction;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('🏠 HomeWidgetProvider: Error processing pending interactions: $e');
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
      
      debugPrint('🏠 Processing data: ${activities?.length ?? 0} activities, ${tasks?.length ?? 0} tasks');
      
      // Process activities
      if (activities != null) {
        debugPrint('🏠 Raw activities data: $activities');
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
            debugPrint('🏠 Added activity: ${scheduleItem.title} on ${scheduleItem.date} at ${scheduleItem.time}');
          } catch (e) {
            debugPrint('🏠 Error processing activity: $e, data: $activity');
          }
        }
      }
      
      // Process tasks
      if (tasks != null) {
        debugPrint('🏠 Raw tasks data: ${tasks.take(3)}'); // Show first 3 tasks only
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
            debugPrint('🏠 Added task: ${scheduleItem.title} on ${scheduleItem.date} at ${scheduleItem.time}');
          } catch (e) {
            debugPrint('🏠 Error processing task: $e, data: $task');
          }
        }
      }

      await _homeWidgetService.updateTodaySchedule(
        activities: activityItems,
        tasks: taskItems,
      );
      
      _lastUpdate = DateTime.now();
      _lastWidgetData = await _homeWidgetService.getWidgetData();
      
      debugPrint('🏠 HomeWidgetProvider: Widget updated - ${activityItems.length} activities, ${taskItems.length} tasks');
    } catch (e) {
      _error = e.toString();
      debugPrint('🏠 HomeWidgetProvider: Update error: $e');
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
        debugPrint('🏠 Parsed date: $dateValue -> $localDate (local)');
        return localDate;
      } catch (e) {
        debugPrint('🏠 Error parsing date: $dateValue');
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
        debugPrint('🏠 Error parsing time: $timeValue');
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
        debugPrint('🏠 Error parsing activity time: $timeValue');
        return baseDate;
      }
    }
    
    return baseDate;
  }

  /// Force refresh widget (untuk manual trigger)
  Future<void> forceRefresh() async {
    debugPrint('🏠 HomeWidgetProvider: Force refresh triggered');
    
    try {
      debugPrint('🏠 Fetching data from API...');
      
      // Fetch data dari server
      await _activityApiService.fetchActivities(forceRefresh: true);
      await _taskApiService.fetchTasks(forceRefresh: true);
      
      // Ambil data dan convert ke Map
      final activitiesData = _activityApiService.activities.map((a) => a.toMap()).toList();
      final tasksData = _taskApiService.tasks.map((t) => t.toMap()).toList();
      
      debugPrint('🏠 API returned ${activitiesData.length} activities, ${tasksData.length} tasks');
      
      await updateWidget(activities: activitiesData, tasks: tasksData);
    } catch (e) {
      debugPrint('🏠 Error fetching data: $e');
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
    debugPrint('🏠 HomeWidgetProvider: Disposed with background service stopped');
  }
}
