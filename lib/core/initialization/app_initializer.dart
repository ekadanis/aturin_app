import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:aturin_app/core/initialization/permissions_service.dart';
import 'package:aturin_app/core/initialization/alarm_manager.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/features/home/services/home_widget_service.dart';

/// Central class for initializing all app components in the correct order
class AppInitializer {
  final AppRouter appRouter;
  late final AlarmManager _alarmManager;
  late final HomeWidgetService _homeWidgetService;
  
  AppInitializer(this.appRouter) {
    _alarmManager = AlarmManager(appRouter);
    _homeWidgetService = HomeWidgetService();
  }

  /// Main initialize method - lightweight initialization only
  Future<void> initialize() async {
    try {
      
      // Initialize core services
      await _initializeAlarmService();
      await _initializeHomeWidgetService();
      await _initializeSystemSettings();
      
    } catch (e) {
      rethrow;
    }
  }

  /// Initialize alarm service
  Future<void> _initializeAlarmService() async {
    try {
      await _alarmManager.initialize();
    } catch (e) {
      rethrow;
    }
  }

  /// Initialize home widget service
  Future<void> _initializeHomeWidgetService() async {
    try {
      await _homeWidgetService.initialize();
    } catch (e) {
      rethrow;
    }
  }

  /// Initialize system settings
  Future<void> _initializeSystemSettings() async {
    try {
      // Set up UI elements
      _setupSystemUI();
      
      // Request necessary permissions
      await PermissionsService.requestAllPermissions();
      
    } catch (e) {
      rethrow;
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
  
  /// Get access to the home widget service instance
  HomeWidgetService get homeWidgetService => _homeWidgetService;
}
