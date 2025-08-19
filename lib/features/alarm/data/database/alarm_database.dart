// SQLite imports disabled for API-based implementation
// import 'package:aturin_app/core/database/database_helper.dart';
// import 'package:sqflite/sqflite.dart';

import 'package:aturin_app/features/alarm/data/model/alarm.dart';
import 'package:aturin_app/shared/core/services/api/alarm/alarm_api_service.dart';
import 'package:flutter/material.dart';

class AlarmDatabase {
  static final AlarmDatabase instance = AlarmDatabase._init();
  
  AlarmDatabase._init();

  // API service instance
  final AlarmApiService _apiService = AlarmApiService();

  // SQLite constants disabled for API implementation
  // static const String tableName = 'alarms';
  // static const String columnId = 'id';
  // static const String columnAlarmDateTime = 'alarm_date_time';
  // static const String columnAlarmEnabled = 'alarm_enabled';
  // static const String columnSlug = 'slug';
  // static const String columnCreatedAt = 'created_at';
  // static const String columnUpdatedAt = 'updated_at';

  // Database instance disabled for API implementation
  // Future<Database> get database async {
  //   return await DatabaseHelper.instance.database;
  // }

  /// Create a new alarm using API
  Future<AlarmModel?> createAlarm(AlarmModel alarm) async {
    try {
      
      final result = await _apiService.createAlarm(alarm);
      
      return result;
    } catch (e) {
      return null;
    }
  }
  /// Get alarm by ID using API
  Future<AlarmModel?> getAlarmById(int id) async {
    try {
      final allAlarms = await _apiService.getAllAlarms();
      return allAlarms.where((alarm) => alarm.id == id).firstOrNull;
    } catch (e) {
      return null;
    }
  }

  /// Get all alarms using API
  Future<List<AlarmModel>> getAllAlarms() async {
    try {
      return await _apiService.getAllAlarms();
    } catch (e) {
      return [];
    }
  }

  /// Get enabled alarms only using API
  Future<List<AlarmModel>> getEnabledAlarms() async {
    try {
      return await _apiService.getEnabledAlarms();
    } catch (e) {
      return [];
    }
  }

  /// Get alarms for a specific date using API
  Future<List<AlarmModel>> getAlarmsByDate(DateTime date) async {
    try {
      return await _apiService.getAlarmsByDate(date);
    } catch (e) {
      return [];
    }
  }
  /// Update an existing alarm using API
  Future<bool> updateAlarm(AlarmModel alarm) async {
    try {
      if (alarm.slug.isEmpty) {
        return false;
      }
      
      final result = await _apiService.updateAlarm(alarm.slug, alarm);
      
      return result != null;
    } catch (e) {
      return false;
    }
  }

  /// Delete an alarm using API
  Future<bool> deleteAlarm(int id) async {
    try {
      // First get the alarm to get its slug
      final alarm = await getAlarmById(id);
      if (alarm == null || alarm.slug.isEmpty) {
        return false;
      }
      
      final result = await _apiService.deleteAlarm(alarm.slug);
      
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Enable/disable an alarm using API
  Future<bool> toggleAlarmEnabled(int id, bool enabled) async {
    try {
      // First get the alarm to get its slug
      final alarm = await getAlarmById(id);
      if (alarm == null || alarm.slug.isEmpty) {
        return false;
      }
      
      final result = await _apiService.toggleAlarmEnabled(alarm.slug, enabled);
      
      return result;
    } catch (e) {
      return false;
    }
  }

  /// Delete all alarms (useful for cleanup) - NOT IMPLEMENTED for API
  Future<bool> deleteAllAlarms() async {
    try {
      // For safety, this method is not implemented for API
      // Individual alarms should be deleted one by one
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get upcoming alarms (next 24 hours) using API
  Future<List<AlarmModel>> getUpcomingAlarms() async {
    try {
      return await _apiService.getUpcomingAlarms();
    } catch (e) {
      return [];
    }
  }

  /// Get overdue alarms (past alarms that are still enabled) using API
  Future<List<AlarmModel>> getOverdueAlarms() async {
    try {
      return await _apiService.getOverdueAlarms();
    } catch (e) {
      return [];
    }
  }
}