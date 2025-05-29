import 'dart:async';
import 'package:flutter/material.dart';
import '../database/aktivitas_database.dart';
import '../model/aktivitas_model.dart';
import '../../alarm/services/alarm_service.dart';
import '../../alarm/model/alarm.dart';
import '../../alarm/database/alarm_database.dart';

class AktivitasService extends ChangeNotifier {
  final aktivitasDatabase = AktivitasDatabase();
  final alarmService = AlarmService();
  final alarmDatabase = AlarmDatabase.instance;
  
  List<AktivitasModel> _aktivitasList = [];
  final Map<String, List<AktivitasModel>> _cachedFilteredAktivitas = {};
  DateTime _lastFetchTime = DateTime(1970);

  List<AktivitasModel> get aktivitasList => _aktivitasList;

  /// Fetch all aktivitas from the database
  Future<void> fetchAktivitas() async {
    final now = DateTime.now();
    if (now.difference(_lastFetchTime).inSeconds < 2 && _aktivitasList.isNotEmpty) {
      debugPrint('Using cached aktivitas (fetched ${now.difference(_lastFetchTime).inSeconds}s ago)');
      return;
    }

    final result = await aktivitasDatabase.queryAllWithRelations();
    _aktivitasList = result.map((row) => AktivitasModel.fromMap(row)).toList();
    _lastFetchTime = now;

    _cachedFilteredAktivitas.clear();
    notifyListeners();
  }

  /// Get aktivitas filtered by category
  List<AktivitasModel> getAktivitasByCategory(ActivityCategory? category) {
    if (category == null) return _aktivitasList;
    
    final filterKey = category.displayName;
    if (_cachedFilteredAktivitas.containsKey(filterKey)) {
      return _cachedFilteredAktivitas[filterKey]!;
    }

    final filteredAktivitas = _aktivitasList
        .where((aktivitas) => aktivitas.activityCategory == category)
        .toList();

    _cachedFilteredAktivitas[filterKey] = filteredAktivitas;
    return filteredAktivitas;
  }

  /// Get aktivitas by user ID
  Future<List<AktivitasModel>> getAktivitasByUserId(int userId) async {
    final result = await aktivitasDatabase.queryByUserId(userId);
    return result.map((row) => AktivitasModel.fromMap(row)).toList();
  }

  /// Get today's aktivitas for a user
  Future<List<AktivitasModel>> getTodayAktivitas(int userId) async {
    final result = await aktivitasDatabase.queryTodayByUserId(userId);
    return result.map((row) => AktivitasModel.fromMap(row)).toList();
  }

  /// Get aktivitas by date range
  Future<List<AktivitasModel>> getAktivitasByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? userId,
  }) async {
    final result = userId != null
        ? await aktivitasDatabase.queryByUserIdAndDateRange(userId, startDate, endDate)
        : await aktivitasDatabase.queryByDateRange(startDate, endDate);
    
    return result.map((row) => AktivitasModel.fromMap(row)).toList();
  }

  /// Get aktivitas for a specific date
  Future<List<AktivitasModel>> getAktivitasByDate(DateTime date, {int? userId}) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return getAktivitasByDateRange(startOfDay, endOfDay, userId: userId);
  }

  /// Get aktivitas by ID
  Future<AktivitasModel?> getAktivitasById(int id) async {
    final row = await aktivitasDatabase.queryById(id);
    if (row != null) {
      return AktivitasModel.fromMap(row);
    }
    return null;
  }  /// Add a new aktivitas dengan alarm yang benar-benar tersimpan di database
  Future<int> addAktivitas(AktivitasModel aktivitas, DateTime? pickedAlarmDateTime) async {
    final slug = 'aktivitas-' + aktivitas.activityTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '-');

    if (!_isValidTiming(aktivitas)) {
      throw Exception('Waktu mulai harus sebelum waktu selesai');
    }    debugPrint('DEBUG addAktivitas: Starting - pickedAlarmDateTime: $pickedAlarmDateTime');
    debugPrint('DEBUG addAktivitas: Aktivitas title: ${aktivitas.activityTitle}');
    
    int? alarmId;
    if (pickedAlarmDateTime != null && pickedAlarmDateTime.isAfter(DateTime.now())) {
      debugPrint('DEBUG addAktivitas: Creating alarm in database...');
      final alarm = AlarmModel(
        alarmDateTime: pickedAlarmDateTime,
        alarmEnabled: true,
        slug: '$slug-alarm',
      );
      final createdAlarm = await alarmDatabase.createAlarm(alarm);
      if (createdAlarm != null) {
        alarmId = createdAlarm.id;
        debugPrint('DEBUG addAktivitas: ✅ Alarm berhasil dibuat di database dengan ID: $alarmId');
      } else {
        debugPrint('DEBUG addAktivitas: ❌ Gagal membuat alarm di database');
      }
    } else {
      debugPrint('DEBUG addAktivitas: Tidak membuat alarm - waktu null atau sudah lewat');
    }

    final now = DateTime.now();
    final aktivitasWithTimestamps = aktivitas.copyWith(
      alarmId: alarmId,
      slug: slug,
      createdAt: now,
      updatedAt: now,
    );
    final id = await aktivitasDatabase.insert(aktivitasWithTimestamps.toMap());
    debugPrint('DEBUG addAktivitas: Aktivitas berhasil disimpan dengan ID: $id, alarmId: $alarmId');

    // Set system alarm jika alarm berhasil dibuat dan waktu alarm valid
    if (alarmId != null && pickedAlarmDateTime != null && pickedAlarmDateTime.isAfter(DateTime.now())) {
      debugPrint('DEBUG addAktivitas: Setting system alarm...');
      try {
        await alarmService.setAlarm(
          alarmId,
          pickedAlarmDateTime,
          'Aktivitas: ${aktivitas.activityTitle}',
          'Aktivitas Anda akan dimulai sesuai pengaturan alarm',
        );
        debugPrint('DEBUG addAktivitas: ✅ System alarm berhasil diset untuk ID: $alarmId pada waktu: $pickedAlarmDateTime');
      } catch (e) {
        debugPrint('DEBUG addAktivitas: ❌ Gagal set system alarm: $e');
      }
    } else {
      debugPrint('DEBUG addAktivitas: Tidak set system alarm - alarmId: $alarmId, pickedAlarmDateTime: $pickedAlarmDateTime');
    }

    await fetchAktivitas();
    return id;
  }  /// Update aktivitas dan alarm di database
  Future<int> updateAktivitas(AktivitasModel aktivitas, DateTime? pickedAlarmDateTime) async {
    debugPrint('DEBUG updateAktivitas: Starting - ID: ${aktivitas.id}, pickedAlarmDateTime: $pickedAlarmDateTime');
    debugPrint('DEBUG updateAktivitas: Aktivitas title: ${aktivitas.activityTitle}');
    
    final slug = 'aktivitas-' + aktivitas.activityTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '-');
    
    if (aktivitas.id == null) {
      throw Exception('ID aktivitas tidak boleh null untuk update');
    }
    
    if (!_isValidTiming(aktivitas)) {
      throw Exception('Waktu mulai harus sebelum waktu selesai');
    }
    
    final existingAktivitas = await getAktivitasById(aktivitas.id!);
    debugPrint('DEBUG updateAktivitas: Existing aktivitas alarmId: ${existingAktivitas?.alarmId}');
    int? alarmId = aktivitas.alarmId;
    
    // Handle alarm logic based on pickedAlarmDateTime
    if (pickedAlarmDateTime != null && pickedAlarmDateTime.isAfter(DateTime.now())) {
      debugPrint('DEBUG updateAktivitas: Processing alarm - waktu valid');
      if (existingAktivitas?.alarmId != null) {
        debugPrint('DEBUG updateAktivitas: Updating existing alarm dengan ID: ${existingAktivitas!.alarmId}');
        // Update existing alarm
        final existingAlarm = await alarmDatabase.getAlarmById(existingAktivitas.alarmId!);
        if (existingAlarm != null) {
          final updatedAlarm = existingAlarm.copyWith(
            alarmDateTime: pickedAlarmDateTime,
            slug: '$slug-alarm',
            updatedAt: DateTime.now(),
          );
          await alarmDatabase.updateAlarm(updatedAlarm);
          alarmId = existingAlarm.id;
          debugPrint('DEBUG updateAktivitas: ✅ Alarm berhasil diupdate di database');
          
          // Update system alarm
          try {
            await alarmService.setAlarm(
              alarmId!,
              pickedAlarmDateTime,
              'Aktivitas: ${aktivitas.activityTitle}',
              'Aktivitas Anda akan dimulai sesuai pengaturan alarm',
            );
            debugPrint('DEBUG updateAktivitas: ✅ System alarm berhasil diupdate untuk ID: $alarmId pada waktu: $pickedAlarmDateTime');
          } catch (e) {
            debugPrint('DEBUG updateAktivitas: ❌ Gagal update system alarm: $e');
          }
        }
      } else {
        debugPrint('DEBUG updateAktivitas: Creating new alarm...');
        // Create new alarm
        final alarm = AlarmModel(
          alarmDateTime: pickedAlarmDateTime,
          alarmEnabled: true,
          slug: '$slug-alarm',
        );        final createdAlarm = await alarmDatabase.createAlarm(alarm);
        if (createdAlarm != null) {
          alarmId = createdAlarm.id;
          debugPrint('DEBUG updateAktivitas: ✅ New alarm berhasil dibuat di database dengan ID: $alarmId');
          
          // Set system alarm
          try {
            await alarmService.setAlarm(
              alarmId!,
              pickedAlarmDateTime,
              'Aktivitas: ${aktivitas.activityTitle}',
              'Aktivitas Anda akan dimulai sesuai pengaturan alarm',
            );
            debugPrint('DEBUG updateAktivitas: ✅ System alarm berhasil diset untuk new alarm ID: $alarmId pada waktu: $pickedAlarmDateTime');
          } catch (e) {
            debugPrint('DEBUG updateAktivitas: ❌ Gagal set system alarm: $e');
          }
        } else {
          debugPrint('DEBUG updateAktivitas: ❌ Gagal membuat alarm baru di database');
        }
      }
    } else {
      debugPrint('DEBUG updateAktivitas: Removing/skipping alarm - pickedAlarmDateTime: $pickedAlarmDateTime');
      // No alarm or invalid time - remove existing alarm if any
      if (existingAktivitas?.alarmId != null) {
        debugPrint('DEBUG updateAktivitas: Removing existing alarm dengan ID: ${existingAktivitas!.alarmId}');
        try {
          // Cancel system alarm first
          await alarmService.cancelAlarm(existingAktivitas.alarmId!);
          debugPrint('DEBUG updateAktivitas: ✅ System alarm berhasil dihapus');
          // Delete from database
          await alarmDatabase.deleteAlarm(existingAktivitas.alarmId!);
          debugPrint('DEBUG updateAktivitas: ✅ Alarm berhasil dihapus dari database');
          alarmId = null;
        } catch (e) {
          debugPrint('DEBUG updateAktivitas: ❌ Gagal hapus alarm: $e');
        }
      } else {
        debugPrint('DEBUG updateAktivitas: No existing alarm to remove');
      }
    }
      final aktivitasWithTimestamp = aktivitas.copyWith(
      alarmId: alarmId,
      slug: slug,
      updatedAt: DateTime.now(),
    );
    
    final result = await aktivitasDatabase.update(aktivitasWithTimestamp.toMap());
    debugPrint('DEBUG updateAktivitas: ✅ Aktivitas berhasil diupdate dengan final alarmId: $alarmId');
    await fetchAktivitas();
    return result;
  }
  /// Delete an aktivitas dengan penghapusan alarm yang benar
  Future<int> deleteAktivitas(int? id) async {
    if (id == null) {
      debugPrint('Gagal menghapus: ID aktivitas adalah null');
      return 0;
    }

    try {
      // Get aktivitas to check for alarm
      final aktivitas = await getAktivitasById(id);
      
      // Cancel and delete alarm if exists
      if (aktivitas?.alarmId != null) {
        try {
          // Cancel system alarm first
          await alarmService.cancelAlarm(aktivitas!.alarmId!);
          // Delete from alarm database
          await alarmDatabase.deleteAlarm(aktivitas.alarmId!);
          debugPrint('Alarm berhasil dihapus untuk aktivitas ID: $id');
        } catch (e) {
          debugPrint('Error menghapus alarm untuk aktivitas ID $id: $e');
        }
      }

      final result = await aktivitasDatabase.delete(id);
      
      // Remove from local list
      _aktivitasList.removeWhere((aktivitas) => aktivitas.id == id);
      _cachedFilteredAktivitas.clear();
      
      notifyListeners();
      debugPrint('Aktivitas berhasil dihapus dengan ID: $id');
      return result;
    } catch (e) {
      debugPrint('Error menghapus aktivitas: $e');
      rethrow;
    }
  }

  /// Delete all aktivitas
  Future<void> deleteAllAktivitas() async {
    await aktivitasDatabase.deleteAll();
    _aktivitasList.clear();
    _cachedFilteredAktivitas.clear();
    notifyListeners();
  }

  /// Get total count of aktivitas
  Future<int> getTotalCount() async {
    return await aktivitasDatabase.getTotalCount();
  }

  /// Get count of aktivitas by user
  Future<int> getCountByUserId(int userId) async {
    return await aktivitasDatabase.getCountByUserId(userId);
  }
  /// Validate aktivitas timing
  bool _isValidTiming(AktivitasModel aktivitas) {
    // Allow activities that span across midnight
    // If end time is earlier than start time, it means the activity continues to the next day
    final startTime = TimeOfDay.fromDateTime(aktivitas.activityStartTime);
    final endTime = TimeOfDay.fromDateTime(aktivitas.activityCompleteTime);
    
    // Convert to minutes for comparison
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    
    // If end time is earlier, it means activity spans to next day - this is valid
    // If start and end are the same, it's invalid (0 duration)
    return startMinutes != endMinutes;
  }  /// Get aktivitas statistics for a user
  Future<Map<String, dynamic>> getAktivitasStats(int userId) async {
    final allAktivitas = await getAktivitasByUserId(userId);
    final todayAktivitas = await getTodayAktivitas(userId);
    
    // Count by category
    final categoryCount = <ActivityCategory, int>{};
    for (final category in ActivityCategory.values) {
      categoryCount[category] = allAktivitas
          .where((aktivitas) => aktivitas.activityCategory == category)
          .length;
    }

    // Calculate total duration
    final totalDuration = allAktivitas.fold<Duration>(
      Duration.zero,
      (sum, aktivitas) => sum + aktivitas.estimatedDuration,
    );

    return {
      'totalAktivitas': allAktivitas.length,
      'todayAktivitas': todayAktivitas.length,
      'categoryCount': categoryCount,
      'totalDuration': totalDuration,
      'averageDuration': allAktivitas.isNotEmpty 
          ? Duration(milliseconds: totalDuration.inMilliseconds ~/ allAktivitas.length)
          : Duration.zero,
    };
  }

  /// Clear cache
  void clearCache() {
    _cachedFilteredAktivitas.clear();
    _lastFetchTime = DateTime(1970);
  }

  /// Refresh aktivitas data
  Future<void> refreshAktivitas() async {
    clearCache();
    await fetchAktivitas();
  }
}
