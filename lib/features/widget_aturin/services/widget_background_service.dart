import 'package:aturin_app/features/home/presentation/providers/home_widget_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// Background service untuk auto-update widget
class WidgetBackgroundService {
  static Timer? _dailyTimer;
  static DateTime _lastUpdate = DateTime.now();
  
  /// Start background service untuk auto-update widget
  static void startDailyUpdate(HomeWidgetProvider provider) {
    // Cancel existing timer
    _dailyTimer?.cancel();
    
    // Calculate time until next midnight
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = nextMidnight.difference(now);
    
    debugPrint('🕒 Widget Background: Next update in ${timeUntilMidnight.inMinutes} minutes');
    
    // Set timer untuk update di tengah malam
    _dailyTimer = Timer(timeUntilMidnight, () {
      _performDailyUpdate(provider);
      
      // Set recurring timer setiap 24 jam
      _dailyTimer = Timer.periodic(const Duration(days: 1), (_) {
        _performDailyUpdate(provider);
      });
    });
  }
  
  /// Perform daily update
  static void _performDailyUpdate(HomeWidgetProvider provider) async {
    final now = DateTime.now();
    
    // Only update if it's a new day
    if (now.day != _lastUpdate.day || 
        now.month != _lastUpdate.month || 
        now.year != _lastUpdate.year) {
      
      debugPrint('🕒 Widget Background: Performing daily update - ${now.day}/${now.month}/${now.year}');
      
      try {
        await provider.forceRefresh();
        _lastUpdate = now;
        debugPrint('🕒 Widget Background: Daily update completed');
      } catch (e) {
        debugPrint('🕒 Widget Background: Daily update error: $e');
      }
    }
  }
  
  /// Stop background service
  static void stop() {
    _dailyTimer?.cancel();
    _dailyTimer = null;
    debugPrint('🕒 Widget Background: Service stopped');
  }
  
  /// Check if widget needs update (call this when app is opened)
  static void checkAndUpdate(HomeWidgetProvider provider) {
    final now = DateTime.now();
    
    // Update if it's a new day
    if (now.day != _lastUpdate.day || 
        now.month != _lastUpdate.month || 
        now.year != _lastUpdate.year) {
      
      debugPrint('🕒 Widget Background: App opened on new day, updating widget');
      provider.forceRefresh();
      _lastUpdate = now;
    }
  }
}
