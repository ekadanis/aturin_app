import 'package:aturin_app/core/database/database_helper.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class AlarmDatabase {
  static final AlarmDatabase instance = AlarmDatabase._init();
  
  AlarmDatabase._init();

  // Table name
  static const String tableName = 'alarms';

  // Column names
  static const String columnId = 'id';
  static const String columnAlarmDateTime = 'alarm_date_time';
  static const String columnAlarmEnabled = 'alarm_enabled';
  static const String columnSlug = 'slug';
  static const String columnCreatedAt = 'created_at';
  static const String columnUpdatedAt = 'updated_at';

  /// Get database instance
  Future<Database> get database async {
    return await DatabaseHelper.instance.database;
  }

  /// Create a new alarm
  Future<AlarmModel?> createAlarm(AlarmModel alarm) async {
    try {
      final db = await database;
      
      final now = DateTime.now();
      final alarmData = alarm.copyWith(
        createdAt: now,
        updatedAt: now,
      ).toMap();
      
      // Remove id from insert data
      alarmData.remove('id');
      
      final id = await db.insert(tableName, alarmData);
      
      debugPrint('Alarm created with ID: $id');
      
      return alarm.copyWith(
        id: id,
        createdAt: now,
        updatedAt: now,
      );
    } catch (e) {
      debugPrint('Error creating alarm: $e');
      return null;
    }
  }

  /// Get alarm by ID
  Future<AlarmModel?> getAlarmById(int id) async {
    try {
      final db = await database;
      
      final results = await db.query(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      
      if (results.isNotEmpty) {
        return AlarmModel.fromMap(results.first);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting alarm by ID: $e');
      return null;
    }
  }

  /// Get all alarms
  Future<List<AlarmModel>> getAllAlarms() async {
    try {
      final db = await database;
      
      final results = await db.query(
        tableName,
        orderBy: '$columnAlarmDateTime ASC',
      );
      
      return results.map((map) => AlarmModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting all alarms: $e');
      return [];
    }
  }

  /// Get enabled alarms only
  Future<List<AlarmModel>> getEnabledAlarms() async {
    try {
      final db = await database;
      
      final results = await db.query(
        tableName,
        where: '$columnAlarmEnabled = ?',
        whereArgs: [1],
        orderBy: '$columnAlarmDateTime ASC',
      );
      
      return results.map((map) => AlarmModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting enabled alarms: $e');
      return [];
    }
  }

  /// Get alarms for a specific date
  Future<List<AlarmModel>> getAlarmsByDate(DateTime date) async {
    try {
      final db = await database;
      
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final results = await db.query(
        tableName,
        where: '$columnAlarmDateTime >= ? AND $columnAlarmDateTime <= ?',
        whereArgs: [
          startOfDay.toIso8601String(),
          endOfDay.toIso8601String(),
        ],
        orderBy: '$columnAlarmDateTime ASC',
      );
      
      return results.map((map) => AlarmModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting alarms by date: $e');
      return [];
    }
  }

  /// Update an existing alarm
  Future<bool> updateAlarm(AlarmModel alarm) async {
    try {
      final db = await database;
      
      if (alarm.id == null) {
        debugPrint('Cannot update alarm: ID is null');
        return false;
      }
      
      final alarmData = alarm.copyWith(
        updatedAt: DateTime.now(),
      ).toMap();
      
      final count = await db.update(
        tableName,
        alarmData,
        where: '$columnId = ?',
        whereArgs: [alarm.id],
      );
      
      debugPrint('Updated $count alarm(s)');
      return count > 0;
    } catch (e) {
      debugPrint('Error updating alarm: $e');
      return false;
    }
  }

  /// Delete an alarm
  Future<bool> deleteAlarm(int id) async {
    try {
      final db = await database;
      
      final count = await db.delete(
        tableName,
        where: '$columnId = ?',
        whereArgs: [id],
      );
      
      debugPrint('Deleted $count alarm(s)');
      return count > 0;
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
      return false;
    }
  }

  /// Enable/disable an alarm
  Future<bool> toggleAlarmEnabled(int id, bool enabled) async {
    try {
      final db = await database;
      
      final count = await db.update(
        tableName,
        {
          columnAlarmEnabled: enabled ? 1 : 0,
          columnUpdatedAt: DateTime.now().toIso8601String(),
        },
        where: '$columnId = ?',
        whereArgs: [id],
      );
      
      debugPrint('Toggled alarm enabled status for $count alarm(s)');
      return count > 0;
    } catch (e) {
      debugPrint('Error toggling alarm enabled: $e');
      return false;
    }
  }

  /// Delete all alarms (useful for cleanup)
  Future<bool> deleteAllAlarms() async {
    try {
      final db = await database;
      
      final count = await db.delete(tableName);
      
      debugPrint('Deleted all $count alarm(s)');
      return true;
    } catch (e) {
      debugPrint('Error deleting all alarms: $e');
      return false;
    }
  }

  /// Get upcoming alarms (next 24 hours)
  Future<List<AlarmModel>> getUpcomingAlarms() async {
    try {
      final db = await database;
      final now = DateTime.now();
      final next24Hours = now.add(const Duration(hours: 24));
      
      final results = await db.query(
        tableName,
        where: '$columnAlarmEnabled = ? AND $columnAlarmDateTime >= ? AND $columnAlarmDateTime <= ?',
        whereArgs: [
          1,
          now.toIso8601String(),
          next24Hours.toIso8601String(),
        ],
        orderBy: '$columnAlarmDateTime ASC',
      );
      
      return results.map((map) => AlarmModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting upcoming alarms: $e');
      return [];
    }
  }

  /// Get overdue alarms (past alarms that are still enabled)
  Future<List<AlarmModel>> getOverdueAlarms() async {
    try {
      final db = await database;
      final now = DateTime.now();
      
      final results = await db.query(
        tableName,
        where: '$columnAlarmEnabled = ? AND $columnAlarmDateTime < ?',
        whereArgs: [
          1,
          now.toIso8601String(),
        ],
        orderBy: '$columnAlarmDateTime DESC',
      );
      
      return results.map((map) => AlarmModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting overdue alarms: $e');
      return [];
    }
  }
}