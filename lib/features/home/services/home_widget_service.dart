import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

/// Service untuk mengelola Home Widget - Calendar Version
/// Modern calendar-style widget dengan data real
class HomeWidgetService {
  
  /// Initialize home widget
  Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.com.aturinjaya.pdbl');
      debugPrint('🏠 HomeWidget: Calendar widget initialized');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Initialization error: $e');
    }
  }

  /// Update widget dengan data schedule hari ini
  Future<void> updateTodaySchedule({
    List<ScheduleItem>? activities,
    List<ScheduleItem>? tasks,
  }) async {
    try {
      final now = DateTime.now();
      final dateFormat = DateFormat('EEEE, d MMM', 'id_ID');
      final todayString = dateFormat.format(now);
      
      debugPrint('🏠 Widget Service: Processing ${activities?.length ?? 0} activities, ${tasks?.length ?? 0} tasks');
      debugPrint('🏠 Widget Service: Today is ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
      
      // Debug: Print all activities with their dates
      if (activities != null) {
        for (var activity in activities) {
          debugPrint('🏠 Activity: ${activity.title} - Date: ${activity.date.year}-${activity.date.month.toString().padLeft(2, '0')}-${activity.date.day.toString().padLeft(2, '0')}');
        }
      }
      
      // Filter items for today
      final todayActivities = activities?.where((item) => 
        item.date.day == now.day && 
        item.date.month == now.month && 
        item.date.year == now.year
      ).toList() ?? [];
      
      final todayTasks = tasks?.where((item) => 
        item.date.day == now.day && 
        item.date.month == now.month && 
        item.date.year == now.year
      ).toList() ?? [];
      
      debugPrint('🏠 Widget Service: After filtering - ${todayActivities.length} activities today, ${todayTasks.length} tasks today');
      
      final totalActivities = todayActivities.length;
      final totalTasks = todayTasks.length;
      final totalItems = totalActivities + totalTasks;
      
      // Combine and sort by time
      final allItems = <ScheduleItem>[];
      allItems.addAll(todayActivities);
      allItems.addAll(todayTasks);
      allItems.sort((a, b) => a.time.compareTo(b.time));
      
      // Update widget data
      await HomeWidget.saveWidgetData<String>('date', todayString);
      await HomeWidget.saveWidgetData<int>('totalActivities', totalActivities);
      await HomeWidget.saveWidgetData<int>('totalTasks', totalTasks);
      await HomeWidget.saveWidgetData<int>('totalItems', totalItems);
      await HomeWidget.saveWidgetData<bool>('isEmpty', totalItems == 0);
      
      // Save first 3 items for display
      for (int i = 0; i < 3; i++) {
        if (i < allItems.length) {
          final item = allItems[i];
          final timeFormat = DateFormat('HH:mm');
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_time', timeFormat.format(item.time));
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_title', item.getFormattedTitle());
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_type', item.type);
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_icon', item.getIcon());
        } else {
          // Clear unused slots
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_time', '');
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_title', '');
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_type', '');
          await HomeWidget.saveWidgetData<String>('item_${i + 1}_icon', '');
        }
      }
      
      // Update widget display
      await HomeWidget.updateWidget(
        name: 'AturinAppHomeWidget',
        androidName: 'AturinAppHomeWidget',
      );
      
      debugPrint('🏠 Widget updated: $totalActivities activities, $totalTasks tasks for today');
      
    } catch (e) {
      debugPrint('🏠 HomeWidget: Update error: $e');
    }
  }

  /// Handle widget interaction
  Future<void> handleWidgetInteraction(String? action) async {
    debugPrint('🏠 HomeWidget: Interaction received: $action');
    // Handle click actions from widget
  }

  /// Check for pending widget interactions
  Future<String?> checkPendingInteractions() async {
    try {
      return await HomeWidget.getWidgetData<String>('action');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Error checking interactions: $e');
      return null;
    }
  }

  /// Get current widget data
  Future<Map<String, dynamic>?> getWidgetData() async {
    try {
      return {
        'date': await HomeWidget.getWidgetData<String>('date'),
        'totalActivities': await HomeWidget.getWidgetData<int>('totalActivities') ?? 0,
        'totalTasks': await HomeWidget.getWidgetData<int>('totalTasks') ?? 0,
        'totalItems': await HomeWidget.getWidgetData<int>('totalItems') ?? 0,
        'isEmpty': await HomeWidget.getWidgetData<bool>('isEmpty') ?? true,
      };
    } catch (e) {
      debugPrint('🏠 HomeWidget: Error getting data: $e');
      return null;
    }
  }

  /// Manual refresh
  Future<void> forceRefresh() async {
    try {
      await HomeWidget.updateWidget(
        name: 'AturinAppHomeWidget',
        androidName: 'AturinAppHomeWidget',
      );
      debugPrint('🏠 HomeWidget: Force refresh completed');
    } catch (e) {
      debugPrint('🏠 HomeWidget: Force refresh error: $e');
    }
  }
}

/// Model untuk schedule item
class ScheduleItem {
  final String id;
  final String title;
  final DateTime date;
  final DateTime time;
  final String type; // 'activity' atau 'task'
  final String? category; // kategori aktivitas/tugas
  
  ScheduleItem({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.type,
    this.category,
  });
  
  String getIcon() {
    switch (type) {
      case 'activity':
        return 'Aktivitas';
      case 'task':
        return 'Tugas';
      default:
        return 'Item';
    }
  }
  
  /// Format title sederhana: hanya judul tanpa waktu (waktu ditampilkan terpisah)
  String getFormattedTitle() {
    return title;
  }
}
