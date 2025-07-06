import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/jadwal/services/schedule_api_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'dart:convert';
import 'dart:math';

/// Service untuk mengelola Home Widget 
/// Menampilkan jadwal aktivitas dan tugas hari ini
class HomeWidgetService {
  static const String _widgetName = 'AturinAppHomeWidget';
  static const String _androidWidgetName = 'AturinAppHomeWidget';
  static const String _iOSWidgetName = 'AturinAppHomeWidget';
  
  final ScheduleApiService _scheduleService = ScheduleApiService();

  /// Initialize home widget
  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.aturin.app');
      
      // Register widget interaction callback
      HomeWidget.widgetClicked.listen((Uri? uri) {
        if (uri != null) {
          handleWidgetInteraction(uri.queryParameters['action']);
        }
      });
      
      debugPrint('🏠 HomeWidget: Initialized successfully');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Initialization error: $e');
    }
  }

  /// Update widget dengan data hari ini
  Future<void> updateTodaySchedule() async {
    try {
      final today = DateTime.now();
      
      debugPrint('🏠 HomeWidget: Starting update for date ${today.toString()}');
      
      // Use safe method to get schedule data
      Map<String, dynamic> scheduleData;
      try {
        debugPrint('🏠 HomeWidget: Using primary data fetching method');
        scheduleData = await _getSafeScheduleData(today);
      } catch (e) {
        debugPrint('🏠 HomeWidget: Primary method failed: $e, trying alternative method');
        // Try alternative method if primary fails
        scheduleData = await _getWidgetDataDirectly(today);
      }
      
      final aktivitasList = scheduleData['aktivitas'] as List<AktivitasModel>;
      final tasksList = scheduleData['tasks'] as List<Task>;

      debugPrint('🏠 HomeWidget: Got data: ${aktivitasList.length} activities, ${tasksList.length} tasks');

      // Format data untuk widget
      final widgetData = _formatDataForWidget(aktivitasList, tasksList, today);
      
      // Update widget data
      await _updateWidgetData(widgetData);
      
      // Trigger widget update
      await _updateWidget();
      
      debugPrint('🏠 HomeWidget: Updated with ${aktivitasList.length} activities and ${tasksList.length} tasks');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Update error: $e');
      debugPrint('🏠 HomeWidget: Error stack trace: ${StackTrace.current}');
      // Update dengan data kosong jika error
      await _updateEmptyWidget();
    }
  }

  /// Format data untuk widget
  Map<String, dynamic> _formatDataForWidget(
    List<AktivitasModel> aktivitas,
    List<Task> tasks,
    DateTime date,
  ) {
    // Gabungkan dan sort berdasarkan waktu
    List<Map<String, dynamic>> allItems = [];
    
    // Add activities
    for (final activity in aktivitas) {
      allItems.add({
        'type': 'activity',
        'title': activity.activityTitle,
        'time': activity.activityStartTime.hour,
        'minute': activity.activityStartTime.minute,
        'category': activity.activityCategory.displayName,
        'description': '', // AktivitasModel doesn't have description field
        'isCompleted': false, // Activities don't have completion status in schedule context
      });
    }
    
    // Add tasks
    for (final task in tasks) {
      allItems.add({
        'type': 'task',
        'title': task.title,
        'time': task.deadline.hour,
        'minute': task.deadline.minute,
        'category': task.category,
        'description': task.description ?? '',
        'isCompleted': task.taskStatus == TaskDatabaseStatus.selesai,
      });
    }
    
    // Sort by time
    allItems.sort((a, b) {
      final timeA = (a['time'] as int) * 60 + (a['minute'] as int);
      final timeB = (b['time'] as int) * 60 + (b['minute'] as int);
      return timeA.compareTo(timeB);
    });

    return {
      'date': _formatDate(date),
      'dateRaw': date.millisecondsSinceEpoch,
      'totalItems': allItems.length,
      'totalActivities': aktivitas.length,
      'totalTasks': tasks.length,
      'items': allItems,
      'isEmpty': allItems.isEmpty,
      'lastUpdated': DateTime.now().millisecondsSinceEpoch,
    };
  }

  /// Update data ke widget storage
  Future<void> _updateWidgetData(Map<String, dynamic> data) async {
    try {
      debugPrint('🏠 HomeWidget: Updating widget data with: ${data.toString().substring(0, 200)}...');
      
      // Save basic info - handling nullable & type safely
      await HomeWidget.saveWidgetData<String>('date', data['date'] as String? ?? 'Hari ini');
      await HomeWidget.saveWidgetData<int>('dateRaw', data['dateRaw'] as int? ?? DateTime.now().millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<int>('totalItems', data['totalItems'] as int? ?? 0);
      await HomeWidget.saveWidgetData<int>('totalActivities', data['totalActivities'] as int? ?? 0);
      await HomeWidget.saveWidgetData<int>('totalTasks', data['totalTasks'] as int? ?? 0);
      await HomeWidget.saveWidgetData<bool>('isEmpty', data['isEmpty'] as bool? ?? true);
      await HomeWidget.saveWidgetData<int>('lastUpdated', data['lastUpdated'] as int? ?? DateTime.now().millisecondsSinceEpoch);
      
      // Debug yang disimpan
      debugPrint('🏠 HomeWidget: Saved basic info - date: ${data['date']}, items: ${data['totalItems']}');
      
      try {
        // Save items as JSON string (untuk Android)
        final itemsJson = jsonEncode(data['items']);
        await HomeWidget.saveWidgetData<String>('itemsJson', itemsJson);
        debugPrint('🏠 HomeWidget: Saved JSON data: ${itemsJson.substring(0, min(100, itemsJson.length))}...');
      } catch (e) {
        debugPrint('🏠 HomeWidget: Error encoding JSON: $e');
        // Save empty array as fallback
        await HomeWidget.saveWidgetData<String>('itemsJson', '[]');
      }
      
      try {
        // Save individual items (untuk iOS, max 5 items)
        final items = data['items'] as List<dynamic>;
        final limitedItems = items.take(5).toList();
        
        debugPrint('🏠 HomeWidget: Saving ${limitedItems.length} individual items');
        
        for (int i = 0; i < 5; i++) {
          if (i < limitedItems.length) {
            final item = limitedItems[i] as Map<String, dynamic>;
            final type = item['type'] as String? ?? '';
            final title = item['title'] as String? ?? 'Untitled';
            final hour = item['time'] as int? ?? 0;
            final minute = item['minute'] as int? ?? 0;
            final category = item['category'] as String? ?? '';
            final isCompleted = item['isCompleted'] as bool? ?? false;
            
            await HomeWidget.saveWidgetData<String>('item_${i}_type', type);
            await HomeWidget.saveWidgetData<String>('item_${i}_title', title);
            await HomeWidget.saveWidgetData<String>('item_${i}_time', _formatTime(hour, minute));
            await HomeWidget.saveWidgetData<String>('item_${i}_category', category);
            await HomeWidget.saveWidgetData<bool>('item_${i}_isCompleted', isCompleted);
            
            debugPrint('🏠 HomeWidget: Saved item $i: $title');
          } else {
            // Clear unused slots
            await HomeWidget.saveWidgetData<String>('item_${i}_type', '');
            await HomeWidget.saveWidgetData<String>('item_${i}_title', '');
            await HomeWidget.saveWidgetData<String>('item_${i}_time', '');
            await HomeWidget.saveWidgetData<String>('item_${i}_category', '');
            await HomeWidget.saveWidgetData<bool>('item_${i}_isCompleted', false);
          }
        }
      } catch (e) {
        debugPrint('🏠 HomeWidget: Error saving individual items: $e');
      }
      
      debugPrint('🏠 HomeWidget: All data saved successfully');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Error saving data: $e');
    }
  }

  /// Update widget kosong
  Future<void> _updateEmptyWidget() async {
    try {
      final today = DateTime.now();
      await HomeWidget.saveWidgetData<String>('date', _formatDate(today));
      await HomeWidget.saveWidgetData<int>('dateRaw', today.millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<int>('totalItems', 0);
      await HomeWidget.saveWidgetData<int>('totalActivities', 0);
      await HomeWidget.saveWidgetData<int>('totalTasks', 0);
      await HomeWidget.saveWidgetData<bool>('isEmpty', true);
      await HomeWidget.saveWidgetData<int>('lastUpdated', DateTime.now().millisecondsSinceEpoch);
      await HomeWidget.saveWidgetData<String>('itemsJson', '[]');
      
      // Clear all item slots
      for (int i = 0; i < 5; i++) {
        await HomeWidget.saveWidgetData<String>('item_${i}_type', '');
        await HomeWidget.saveWidgetData<String>('item_${i}_title', '');
        await HomeWidget.saveWidgetData<String>('item_${i}_time', '');
        await HomeWidget.saveWidgetData<String>('item_${i}_category', '');
        await HomeWidget.saveWidgetData<bool>('item_${i}_isCompleted', false);
      }
      
      await _updateWidget();
    } catch (e) {
      debugPrint('🏠 HomeWidget: Error updating empty widget: $e');
    }
  }

  /// Trigger widget update
  Future<void> _updateWidget() async {
    try {
      debugPrint('🏠 HomeWidget: Triggering widget update with name: $_androidWidgetName');
      
      // Update Android widget
      final androidResult = await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
      
      // Verify update was triggered
      debugPrint('🏠 HomeWidget: Update result: $androidResult');
      
      // Trigger a second update after a short delay (helps with some Android devices)
      await Future.delayed(const Duration(milliseconds: 500));
      final secondResult = await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _androidWidgetName,
        iOSName: _iOSWidgetName,
      );
      
      debugPrint('🏠 HomeWidget: Second update result: $secondResult');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Error triggering update: $e');
      debugPrint('🏠 HomeWidget: Error stack trace: ${StackTrace.current}');
    }
  }

  /// Format tanggal
  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final days = [
      'Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
    ];
    
    return '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Format waktu
  String _formatTime(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Handle widget tap (untuk navigation)
  Future<void> handleWidgetInteraction(String? action) async {
    debugPrint('🏠 HomeWidget: Interaction received: $action');
    
    // Handle different actions
    switch (action) {
      case 'view_schedule':
        debugPrint('🏠 HomeWidget: Processing view_schedule action');
        // User tapped widget untuk melihat jadwal
        // Navigation akan ditangani oleh konsumer dari service ini
        break;
      case 'open_schedule':
        // Navigate ke halaman jadwal
        debugPrint('🏠 HomeWidget: Processing open_schedule action');
        break;
      case 'add_task':
        // Navigate ke halaman tambah tugas
        debugPrint('🏠 HomeWidget: Processing add_task action');
        break;
      case 'add_activity':
        // Navigate ke halaman tambah aktivitas
        debugPrint('🏠 HomeWidget: Processing add_activity action');
        break;
      default:
        // Default: open main app
        debugPrint('🏠 HomeWidget: Processing unknown action: $action');
        break;
    }
    
    // Reset pending action after processing
    await HomeWidget.saveWidgetData<String>('pending_action', null);
  }
  
  /// Check for pending widget interactions
  Future<String?> checkPendingInteractions() async {
    final pendingAction = await HomeWidget.getWidgetData<String>('pending_action');
    final pendingTime = await HomeWidget.getWidgetData<int>('pending_action_time');
    
    if (pendingAction != null && pendingTime != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - pendingTime;
      
      // Process only if action is recent (less than 30 seconds)
      if (diff < 30000) {
        debugPrint('🏠 HomeWidget: Found pending action: $pendingAction');
        return pendingAction;
      } else {
        // Clear old pending actions
        await HomeWidget.saveWidgetData<String>('pending_action', null);
        debugPrint('🏠 HomeWidget: Cleared old pending action');
      }
    }
    
    return null;
  }

  /// Get widget data untuk debugging
  Future<Map<String, dynamic>?> getWidgetData() async {
    try {
      return {
        'date': await HomeWidget.getWidgetData<String>('date'),
        'totalItems': await HomeWidget.getWidgetData<int>('totalItems'),
        'totalActivities': await HomeWidget.getWidgetData<int>('totalActivities'),
        'totalTasks': await HomeWidget.getWidgetData<int>('totalTasks'),
        'isEmpty': await HomeWidget.getWidgetData<bool>('isEmpty'),
        'lastUpdated': await HomeWidget.getWidgetData<int>('lastUpdated'),
      };
    } catch (e) {
      debugPrint('🏠 HomeWidget: Error getting data: $e');
      return null;
    }
  }

  /// Schedule periodic updates (optional - dapat dipanggil dari background task)
  Future<void> schedulePeriodicUpdate() async {
    // Implement periodic update logic if needed
    // This would typically be called from a background task
    debugPrint('🏠 HomeWidget: Scheduling periodic updates');
  }

  /// Manual refresh untuk testing
  Future<void> forceRefresh() async {
    debugPrint('🏠 HomeWidget: Force refresh triggered');
    
    try {
      // Clear existing data first
      await HomeWidget.saveWidgetData<String>('date', null);
      await HomeWidget.saveWidgetData<int>('dateRaw', null);
      await HomeWidget.saveWidgetData<int>('totalItems', null);
      await HomeWidget.saveWidgetData<int>('totalActivities', null);
      await HomeWidget.saveWidgetData<int>('totalTasks', null);
      await HomeWidget.saveWidgetData<bool>('isEmpty', null);
      await HomeWidget.saveWidgetData<String>('itemsJson', null);
      
      // Force update with current data
      debugPrint('🏠 HomeWidget: Old data cleared, updating with fresh data');
      await updateTodaySchedule();
      
      // Trigger additional update
      await Future.delayed(const Duration(seconds: 1));
      await _updateWidget();
      
      debugPrint('🏠 HomeWidget: Force refresh completed successfully');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Force refresh failed: $e');
      // Still try to update with empty state if refresh fails
      await _updateEmptyWidget();
    }
  }

  /// Alternative method to get today's data safely
  Future<Map<String, dynamic>> _getSafeScheduleData(DateTime date) async {
    try {
      // Try to get activities safely with more detailed error handling
      List<AktivitasModel> aktivitasList = [];
      try {
        debugPrint('🏠 HomeWidget: Attempting to fetch all activities...');
        final allActivities = await _scheduleService.getAllAktivitas();
        debugPrint('🏠 HomeWidget: Received ${allActivities.length} activities from API');
        
        if (allActivities.isNotEmpty) {
          // Filter by today manually to avoid API date parsing issues
          final today = DateTime(date.year, date.month, date.day);
          debugPrint('🏠 HomeWidget: Filtering activities for date: $today');
          
          final filteredActivities = <AktivitasModel>[];
          for (int i = 0; i < allActivities.length; i++) {
            try {
              final activity = allActivities[i];
              final activityDate = DateTime(
                activity.activityDate.year,
                activity.activityDate.month,
                activity.activityDate.day,
              );
              if (activityDate.isAtSameMomentAs(today)) {
                filteredActivities.add(activity);
              }
            } catch (e) {
              debugPrint('🏠 HomeWidget: Error processing activity at index $i: $e');
              continue; // Skip this activity and continue
            }
          }
          
          aktivitasList = filteredActivities;
          debugPrint('🏠 HomeWidget: Filtered to ${aktivitasList.length} activities for today');
        } else {
          debugPrint('🏠 HomeWidget: Unexpected response type: ${allActivities.runtimeType}');
          aktivitasList = [];
        }
      } catch (e) {
        debugPrint('🏠 HomeWidget: Error fetching activities: $e');
        debugPrint('🏠 HomeWidget: Stack trace: ${StackTrace.current}');
        aktivitasList = [];
      }
      
      // Try to get tasks safely with more detailed error handling
      List<Task> tasksList = [];
      try {
        debugPrint('🏠 HomeWidget: Attempting to fetch all tasks...');
        final allTasks = await _scheduleService.getAllTasks();
        debugPrint('🏠 HomeWidget: Received ${allTasks.length} tasks from API');
        
        if (allTasks.isNotEmpty) {
          // Filter by today manually
          final today = DateTime(date.year, date.month, date.day);
          debugPrint('🏠 HomeWidget: Filtering tasks for date: $today');
          
          final filteredTasks = <Task>[];
          for (int i = 0; i < allTasks.length; i++) {
            try {
              final task = allTasks[i];
              final taskDate = DateTime(
                task.deadline.year,
                task.deadline.month,
                task.deadline.day,
              );
              if (taskDate.isAtSameMomentAs(today)) {
                filteredTasks.add(task);
              }
            } catch (e) {
              debugPrint('🏠 HomeWidget: Error processing task at index $i: $e');
              continue; // Skip this task and continue
            }
          }
          
          tasksList = filteredTasks;
          debugPrint('🏠 HomeWidget: Filtered to ${tasksList.length} tasks for today');
        } else {
          debugPrint('🏠 HomeWidget: Unexpected tasks response type: ${allTasks.runtimeType}');
          tasksList = [];
        }
      } catch (e) {
        debugPrint('🏠 HomeWidget: Error fetching tasks: $e');
        debugPrint('🏠 HomeWidget: Stack trace: ${StackTrace.current}');
        tasksList = [];
      }
      
      return {
        'aktivitas': aktivitasList,
        'tasks': tasksList,
        'date': date,
      };
    } catch (e) {
      debugPrint('🏠 HomeWidget: Error in safe schedule data: $e');
      debugPrint('🏠 HomeWidget: Stack trace: ${StackTrace.current}');
      return {
        'aktivitas': <AktivitasModel>[],
        'tasks': <Task>[],
        'date': date,
      };
    }
  }

  /// Alternative safe method using direct API calls for widget data
  /// This bypasses any potential issues with the service layer
  Future<Map<String, dynamic>> _getWidgetDataDirectly(DateTime date) async {
    try {
      debugPrint('🏠 HomeWidget: Using direct API approach for data fetching');
      
      List<AktivitasModel> aktivitasList = [];
      List<Task> tasksList = [];
      
      // Try direct activity API call
      try {
        final activityApiService = ActivityApiService();
        final allActivities = await activityApiService.getActivitiesByDate(date);
        aktivitasList = allActivities;
        debugPrint('🏠 HomeWidget: Direct API - Got ${aktivitasList.length} activities');
      } catch (e) {
        debugPrint('🏠 HomeWidget: Direct API activities failed: $e');
        aktivitasList = [];
      }
      
      // Try to get today's tasks using task API
      try {
        final taskApiService = TaskApiService();
        final allTasks = await taskApiService.getTasksToday();
        
        // Filter for the specific date
        final today = DateTime(date.year, date.month, date.day);
        tasksList = allTasks.where((task) {
          final taskDate = DateTime(
            task.deadline.year,
            task.deadline.month,
            task.deadline.day,
          );
          return taskDate.isAtSameMomentAs(today);
        }).toList();
        
        debugPrint('🏠 HomeWidget: Direct API - Got ${tasksList.length} tasks for today');
      } catch (e) {
        debugPrint('🏠 HomeWidget: Direct API tasks failed: $e');
        tasksList = [];
      }
      
      return {
        'aktivitas': aktivitasList,
        'tasks': tasksList,
        'date': date,
      };
    } catch (e) {
      debugPrint('🏠 HomeWidget: Direct API method failed: $e');
      return {
        'aktivitas': <AktivitasModel>[],
        'tasks': <Task>[],
        'date': date,
      };
    }
  }
}
