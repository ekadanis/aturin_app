import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aturin_app/core/initialization/permissions_service.dart';
import 'package:aturin_app/core/initialization/alarm_manager.dart';
import 'package:aturin_app/routers/app_router.dart';

/// Central class for initializing all app components in the correct order
class AppInitializer {
  final AppRouter appRouter;
  late final AlarmManager _alarmManager;

  AppInitializer(this.appRouter) {
    _alarmManager = AlarmManager(appRouter);
  }

  /// Initialize all required components for the app
  Future<void> initialize() async {
    try {
      // Set up UI elements first
      _setupSystemUI();
      
      // Initialize formatting and localization
      await initializeDateFormatting('id_ID', null);
      
      // Request necessary permissions
      await PermissionsService.requestAllPermissions();
      
      // Initialize alarm system
      await _alarmManager.initialize();
      
      debugPrint('App initialization completed successfully');
    } catch (e) {
      debugPrint('Error during app initialization: $e');
      rethrow; // Re-throw to let the caller handle it
    }
  }

  /// Configure system UI appearance
  void _setupSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  /// Get access to the alarm manager instance
  AlarmManager get alarmManager => _alarmManager;
}