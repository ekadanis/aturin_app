import 'dart:async';
import 'package:flutter/material.dart';
// import '../database/aktivitas_database.dart'; // DISABLED SQLite
import '../model/aktivitas_model.dart';
import '../../alarm/services/alarm_service.dart';
import '../../alarm/model/alarm.dart';
// import '../../alarm/database/alarm_database.dart'; // DISABLED SQLite
import '../../../core/services/api/activities/activity_api_service.dart';
import '../../../core/services/api/alarm/alarm_api_service.dart';

class AktivitasService extends ChangeNotifier {
  // final aktivitasDatabase = AktivitasDatabase(); // DISABLED SQLite
  final activityService = ActivityApiService(); // NEW API Service
  final alarmService = AlarmService();
  final alarmApiService = AlarmApiService(); // NEW Alarm API Service
  // final alarmDatabase = AlarmDatabase.instance; // DISABLED SQLite
  
  List<AktivitasModel> _aktivitasList = [];
  final Map<String, List<AktivitasModel>> _cachedFilteredAktivitas = {};
  DateTime _lastFetchTime = DateTime(1970);
  
  // Realtime updates
  final StreamController<List<AktivitasModel>> _aktivitasStreamController = 
      StreamController<List<AktivitasModel>>.broadcast();
  Timer? _periodicRefreshTimer;
  bool _isAutoRefreshEnabled = true;
  
  Stream<List<AktivitasModel>> get aktivitasStream => _aktivitasStreamController.stream;

  List<AktivitasModel> get aktivitasList => _aktivitasList;
  
  /// Initialize realtime updates
  void initializeRealtimeUpdates() {
    debugPrint('Initializing realtime updates for aktivitas');
    _startPeriodicRefresh();
  }
  
  /// Start periodic refresh every 30 seconds
  void _startPeriodicRefresh() {
    _periodicRefreshTimer?.cancel();
    if (_isAutoRefreshEnabled) {
      _periodicRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        debugPrint('Periodic refresh triggered');
        fetchAktivitas(forceRefresh: true);
      });
    }
  }
  
  /// Stop realtime updates
  void stopRealtimeUpdates() {
    debugPrint('Stopping realtime updates for aktivitas');
    _periodicRefreshTimer?.cancel();
    _isAutoRefreshEnabled = false;
  }
  
  /// Enable/disable auto refresh
  void setAutoRefresh(bool enabled) {
    _isAutoRefreshEnabled = enabled;
    if (enabled) {
      _startPeriodicRefresh();
    } else {
      _periodicRefreshTimer?.cancel();
    }
  }  /// Fetch all aktivitas from the API
  Future<void> fetchAktivitas({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh && now.difference(_lastFetchTime).inSeconds < 2 && _aktivitasList.isNotEmpty) {
      debugPrint('Using cached aktivitas (fetched ${now.difference(_lastFetchTime).inSeconds}s ago)');
      return;
    }

    try {
      debugPrint('Fetching aktivitas from API (forceRefresh: $forceRefresh)');
      final result = await activityService.getAllActivities();
      
      // Check if data has actually changed
      bool dataChanged = _aktivitasList.length != result.length;
      if (!dataChanged && _aktivitasList.isNotEmpty) {
        for (int i = 0; i < _aktivitasList.length; i++) {
          if (_aktivitasList[i].id != result[i].id ||
              _aktivitasList[i].activityTitle != result[i].activityTitle ||
              _aktivitasList[i].updatedAt != result[i].updatedAt) {
            dataChanged = true;
            break;
          }
        }
      }
      
      _aktivitasList = result;
      _lastFetchTime = now;
      _cachedFilteredAktivitas.clear();
      
      // Emit to stream
      _aktivitasStreamController.add(_aktivitasList);
      
      if (dataChanged || forceRefresh) {
        debugPrint('Data changed or force refresh - notifying listeners');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      // Keep the existing list if API call fails
    }
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
  /// Get aktivitas by user ID (using cached data)
  Future<List<AktivitasModel>> getAktivitasByUserId(int userId) async {
    try {
      // Since we're using token-based auth, all activities returned are for the current user
      await fetchAktivitas();
      return _aktivitasList;
    } catch (e) {
      debugPrint('Error getting activities by user ID: $e');
      return [];
    }
  }

  /// Get today's aktivitas for a user
  Future<List<AktivitasModel>> getTodayAktivitas(int userId) async {
    try {
      final result = await activityService.getTodayActivities();
      return result;
    } catch (e) {
      debugPrint('Error getting today activities: $e');
      return [];
    }
  }
  /// Get aktivitas by date range
  Future<List<AktivitasModel>> getAktivitasByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int? userId,
  }) async {
    try {
      final result = await activityService.getActivitiesByDateRange(startDate, endDate);
      return result;
    } catch (e) {
      debugPrint('Error getting activities by date range: $e');
      return [];
    }
  }

  /// Get aktivitas for a specific date
  Future<List<AktivitasModel>> getAktivitasByDate(DateTime date, {int? userId}) async {
    try {
      final result = await activityService.getActivitiesByDate(date);
      return result;
    } catch (e) {
      debugPrint('Error getting activities by date: $e');
      return [];
    }
  }

  /// Get aktivitas by ID (from cache or API)
  Future<AktivitasModel?> getAktivitasById(int id) async {
    try {
      // First try to find in cache
      await fetchAktivitas();
      final found = _aktivitasList.where((a) => a.id == id).firstOrNull;
      return found;
    } catch (e) {
      debugPrint('Error getting activity by ID: $e');
      return null;
    }
  }  /// Add a new aktivitas using API
  Future<int> addAktivitas(AktivitasModel aktivitas, DateTime? pickedAlarmDateTime) async {
    final slug = 'activity-' + aktivitas.activityTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '-');

    // Basic validation - let API handle detailed timing validation
    // This allows cross-midnight activities

    debugPrint('DEBUG addAktivitas: Starting - pickedAlarmDateTime: $pickedAlarmDateTime');
    debugPrint('DEBUG addAktivitas: Aktivitas title: ${aktivitas.activityTitle}');
    
    int? alarmId;
    if (pickedAlarmDateTime != null && pickedAlarmDateTime.isAfter(DateTime.now())) {
      debugPrint('DEBUG addAktivitas: Creating alarm via API...');
        try {        // Create alarm using AlarmApiService
        // Note: Backend auto-generates slug with timestamp, so we use a temporary slug
        final tempAlarmSlug = 'alarm-activity-${aktivitas.activityTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll(' ', '-')}';
        final newAlarm = AlarmModel(
          alarmDateTime: pickedAlarmDateTime,
          alarmEnabled: true,
          slug: tempAlarmSlug, // This will be replaced by backend-generated slug
        );
        
        final createdAlarm = await alarmApiService.createAlarm(newAlarm);
        if (createdAlarm != null) {
          alarmId = createdAlarm.id;
          debugPrint('DEBUG addAktivitas: ✅ Alarm berhasil dibuat dengan ID: $alarmId');
          debugPrint('DEBUG addAktivitas: Backend-generated slug: ${createdAlarm.slug}');
          
          // Set system alarm
          try {
            await alarmService.setAlarm(
              alarmId!,
              pickedAlarmDateTime,
              'Aktivitas: ${aktivitas.activityTitle}',
              'Aktivitas Anda akan dimulai sesuai pengaturan alarm',
            );
            debugPrint('DEBUG addAktivitas: ✅ System alarm berhasil diset untuk ID: $alarmId pada waktu: $pickedAlarmDateTime');
          } catch (e) {
            debugPrint('DEBUG addAktivitas: ❌ Gagal set system alarm: $e');
          }
        } else {
          debugPrint('DEBUG addAktivitas: ❌ Gagal membuat alarm via API');
        }
      } catch (e) {
        debugPrint('DEBUG addAktivitas: ❌ Error creating alarm via API: $e');
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
      try {
      final createdActivity = await activityService.createActivity(aktivitasWithTimestamps);
      if (createdActivity != null) {
        debugPrint('DEBUG addAktivitas: Aktivitas berhasil disimpan dengan ID: ${createdActivity.id}, alarmId: $alarmId');
        // Auto-refresh data after successful creation
        await fetchAktivitas(forceRefresh: true);
        return createdActivity.id ?? 0;
      } else {
        throw Exception('Failed to create activity');
      }    } catch (e) {
      debugPrint('DEBUG addAktivitas: Error creating activity: $e');
      
      // Check if it's a timing validation error
      if (e.toString().contains('activity complete time field must be a date after activity start time')) {
        throw Exception('Waktu selesai aktivitas harus setelah waktu mulai. Pastikan waktu selesai lebih besar dari waktu mulai.');
      }
      
      // Check for other validation errors
      if (e.toString().contains('422') || e.toString().contains('validation')) {
        throw Exception('Data aktivitas tidak valid. Periksa kembali waktu mulai dan waktu selesai.');
      }
      
      rethrow;
    }
  }  /// Update aktivitas using API
  Future<int> updateAktivitas(AktivitasModel aktivitas, DateTime? pickedAlarmDateTime) async {
    debugPrint('DEBUG updateAktivitas: Starting - ID: ${aktivitas.id}, pickedAlarmDateTime: $pickedAlarmDateTime');
    debugPrint('DEBUG updateAktivitas: Aktivitas title: ${aktivitas.activityTitle}');
    debugPrint('DEBUG updateAktivitas: Existing slug: ${aktivitas.slug}');
    
    if (aktivitas.id == null) {
      throw Exception('ID aktivitas tidak boleh null untuk update');
    }
    
    if (aktivitas.slug == null || aktivitas.slug!.isEmpty) {
      throw Exception('Slug tidak boleh kosong untuk update. Data mungkin rusak.');
    }    final slug = aktivitas.slug!; // Use existing slug from database
    debugPrint('DEBUG updateAktivitas: Using original slug from database: $slug');
    
    // Basic timing validation - allow cross-midnight activities
    // The API will handle detailed validation
    
    final existingAktivitas = await getAktivitasById(aktivitas.id!);
    debugPrint('DEBUG updateAktivitas: Existing aktivitas alarmId: ${existingAktivitas?.alarmId}');
    int? alarmId = aktivitas.alarmId;
      // Handle alarm logic based on pickedAlarmDateTime
    if (pickedAlarmDateTime != null && pickedAlarmDateTime.isAfter(DateTime.now())) {
      debugPrint('DEBUG updateAktivitas: Processing alarm - waktu valid');
      if (existingAktivitas?.alarmId != null) {
        debugPrint('DEBUG updateAktivitas: Updating existing alarm dengan ID: ${existingAktivitas!.alarmId}');
        alarmId = existingAktivitas.alarmId;        try {
          // Get existing alarm and update it via API
          // Since backend uses slug-based endpoints, we need to get all alarms and find by ID
          final allAlarms = await alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((alarm) => alarm.id == alarmId).firstOrNull;
          debugPrint('DEBUG updateAktivitas: Existing alarm details - ID: ${existingAlarm?.id}, DateTime: ${existingAlarm?.alarmDateTime}, Slug: ${existingAlarm?.slug}');
            if (existingAlarm != null) {
            debugPrint('DEBUG updateAktivitas: === ALARM UPDATE PROCESS ===');
            debugPrint('DEBUG updateAktivitas: Original alarm datetime: ${existingAlarm.alarmDateTime}');
            debugPrint('DEBUG updateAktivitas: New picked datetime: $pickedAlarmDateTime');
            debugPrint('DEBUG updateAktivitas: Alarm slug: ${existingAlarm.slug}');
            debugPrint('DEBUG updateAktivitas: Alarm ID: ${existingAlarm.id}');
            
            final updatedAlarm = existingAlarm.copyWith(
              alarmDateTime: pickedAlarmDateTime,
              alarmEnabled: true,
            );
            debugPrint('DEBUG updateAktivitas: Updated alarm object:');
            debugPrint('  - DateTime: ${updatedAlarm.alarmDateTime}');
            debugPrint('  - DateTime ISO: ${updatedAlarm.alarmDateTime.toIso8601String()}');
            debugPrint('  - Enabled: ${updatedAlarm.alarmEnabled}');
            debugPrint('  - Slug: ${updatedAlarm.slug}');
            debugPrint('  - ID: ${updatedAlarm.id}');
            
            final result = await alarmApiService.updateAlarm(existingAlarm.slug, updatedAlarm);
            if (result != null) {
              debugPrint('DEBUG updateAktivitas: ✅ Alarm berhasil diupdate via API');
              debugPrint('  - Result datetime: ${result.alarmDateTime}');
              debugPrint('  - Result datetime ISO: ${result.alarmDateTime.toIso8601String()}');
              debugPrint('  - Expected vs Actual: $pickedAlarmDateTime vs ${result.alarmDateTime}');
              debugPrint('  - Match: ${pickedAlarmDateTime.isAtSameMomentAs(result.alarmDateTime)}');
            } else {
              debugPrint('DEBUG updateAktivitas: ❌ Update alarm API returned null');
            }
          } else {          debugPrint('DEBUG updateAktivitas: ❌ Existing alarm not found for ID: $alarmId');
          }
          
          // Update system alarm
          if (alarmId != null) {
            await alarmService.setAlarm(
              alarmId,
              pickedAlarmDateTime,
              'Aktivitas: ${aktivitas.activityTitle}',
              'Aktivitas Anda akan dimulai sesuai pengaturan alarm',
            );
            debugPrint('DEBUG updateAktivitas: ✅ System alarm berhasil diupdate untuk ID: $alarmId pada waktu: $pickedAlarmDateTime');
          }
        } catch (e) {
          debugPrint('DEBUG updateAktivitas: ❌ Gagal update alarm: $e');
        }
      } else {
        debugPrint('DEBUG updateAktivitas: Creating new alarm via API...');
          try {
          // Create new alarm using AlarmApiService
          final alarmSlug = 'alarm-activity-${aktivitas.activityTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), '').replaceAll(' ', '-')}';
          final newAlarm = AlarmModel(
            alarmDateTime: pickedAlarmDateTime,
            alarmEnabled: true,
            slug: alarmSlug,
          );
          
          final createdAlarm = await alarmApiService.createAlarm(newAlarm);
          if (createdAlarm != null) {
            alarmId = createdAlarm.id;
            debugPrint('DEBUG updateAktivitas: ✅ New alarm berhasil dibuat dengan ID: $alarmId');
            
            // Set system alarm
            await alarmService.setAlarm(
              alarmId!,
              pickedAlarmDateTime,
              'Aktivitas: ${aktivitas.activityTitle}',
              'Aktivitas Anda akan dimulai sesuai pengaturan alarm',
            );
            debugPrint('DEBUG updateAktivitas: ✅ System alarm berhasil diset untuk new alarm ID: $alarmId pada waktu: $pickedAlarmDateTime');
          } else {
            debugPrint('DEBUG updateAktivitas: ❌ Gagal membuat alarm via API');
          }
        } catch (e) {
          debugPrint('DEBUG updateAktivitas: ❌ Gagal buat alarm via API: $e');
        }
      }
    } else {
      debugPrint('DEBUG updateAktivitas: Removing/skipping alarm - pickedAlarmDateTime: $pickedAlarmDateTime');
      // No alarm or invalid time - remove existing alarm if any
      if (existingAktivitas?.alarmId != null) {
        debugPrint('DEBUG updateAktivitas: Removing existing alarm dengan ID: ${existingAktivitas!.alarmId}');
          try {
          // Delete alarm via API
          // Since backend uses slug-based endpoints, we need to get all alarms and find by ID  
          final allAlarms = await alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((alarm) => alarm.id == existingAktivitas.alarmId).firstOrNull;
          if (existingAlarm != null) {
            await alarmApiService.deleteAlarm(existingAlarm.slug);
            debugPrint('DEBUG updateAktivitas: ✅ Alarm berhasil dihapus via API');
          }
          
          // Cancel system alarm
          await alarmService.cancelAlarm(existingAktivitas.alarmId!);
          debugPrint('DEBUG updateAktivitas: ✅ System alarm berhasil dihapus');
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
      try {
      final updatedActivity = await activityService.updateActivity(slug, aktivitasWithTimestamp);
      if (updatedActivity != null) {
        debugPrint('DEBUG updateAktivitas: ✅ Aktivitas berhasil diupdate dengan final alarmId: $alarmId');
        // Auto-refresh data after successful update
        await fetchAktivitas(forceRefresh: true);
        return 1; // Success
      } else {
        throw Exception('Failed to update activity');
      }    } catch (e) {
      debugPrint('DEBUG updateAktivitas: Error updating activity: $e');
      
      // Check if it's a timing validation error
      if (e.toString().contains('activity complete time field must be a date after activity start time')) {
        throw Exception('Waktu selesai aktivitas harus setelah waktu mulai. Pastikan waktu selesai lebih besar dari waktu mulai.');
      }
      
      // Check for other validation errors
      if (e.toString().contains('422') || e.toString().contains('validation')) {
        throw Exception('Data aktivitas tidak valid. Periksa kembali waktu mulai dan waktu selesai.');
      }
      
      rethrow;
    }
  }
  /// Delete an aktivitas using API
  Future<int> deleteAktivitas(int? id) async {
    if (id == null) {
      debugPrint('Gagal menghapus: ID aktivitas adalah null');
      return 0;
    }    try {
      // Get aktivitas to check for alarm
      final aktivitas = await getAktivitasById(id);
        // Cancel and delete alarm if exists
      if (aktivitas?.alarmId != null) {
        try {
          // Cancel system alarm first
          await alarmService.cancelAlarm(aktivitas!.alarmId!);
          debugPrint('System alarm berhasil dihapus untuk aktivitas ID: $id');
          
          // Delete alarm via API
          // Since backend uses slug-based endpoints, we need to get all alarms and find by ID
          final allAlarms = await alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((alarm) => alarm.id == aktivitas.alarmId).firstOrNull;
          if (existingAlarm != null) {
            await alarmApiService.deleteAlarm(existingAlarm.slug);
            debugPrint('Alarm berhasil dihapus via API untuk aktivitas ID: $id');
          }
        } catch (e) {
          debugPrint('Error menghapus alarm untuk aktivitas ID $id: $e');
        }
      }// Delete from API using slug
      if (aktivitas?.slug != null) {
        final success = await activityService.deleteActivity(aktivitas!.slug!);
        if (success) {
          debugPrint('Aktivitas berhasil dihapus dengan ID: $id');
          // Auto-refresh data after successful deletion
          await fetchAktivitas(forceRefresh: true);
          return 1;
        } else {
          throw Exception('Failed to delete activity from API');
        }
      } else {
        throw Exception('Activity slug is null');
      }
    } catch (e) {
      debugPrint('Error menghapus aktivitas: $e');
      rethrow;
    }
  }

  /// Delete an aktivitas without triggering notifyListeners (for local state management)
  Future<int> deleteAktivitasSilent(int? id) async {
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
          debugPrint('System alarm berhasil dihapus untuk aktivitas ID: $id (silent)');
            // Delete alarm via API
          // Since backend uses slug-based endpoints, we need to get all alarms and find by ID
          final allAlarms = await alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((alarm) => alarm.id == aktivitas.alarmId).firstOrNull;
          if (existingAlarm != null) {
            await alarmApiService.deleteAlarm(existingAlarm.slug);
            debugPrint('Alarm berhasil dihapus via API untuk aktivitas ID: $id (silent)');
          }
        } catch (e) {
          debugPrint('Error menghapus alarm untuk aktivitas ID $id: $e');
        }
      }

      // Delete from API using slug
      if (aktivitas?.slug != null) {
        final success = await activityService.deleteActivity(aktivitas!.slug!);
        if (success) {
          // Remove from local list
          _aktivitasList.removeWhere((aktivitas) => aktivitas.id == id);
          _cachedFilteredAktivitas.clear();
          
          // NOTE: notifyListeners() is NOT called here - caller should handle UI updates
          debugPrint('Aktivitas berhasil dihapus dengan ID: $id (silent mode)');
          return 1;
        } else {
          throw Exception('Failed to delete activity from API');
        }
      } else {
        throw Exception('Activity slug is null');
      }
    } catch (e) {
      debugPrint('Error menghapus aktivitas: $e');
      rethrow;
    }
  }
  /// Manually trigger notifyListeners (for use after silent operations)
  void notifyListenersManually() {
    notifyListeners();
  }

  /// Delete all aktivitas (clear local cache)
  Future<void> deleteAllAktivitas() async {
    // For API-based implementation, we don't have a delete all endpoint
    // So we'll just clear the local cache
    _aktivitasList.clear();
    _cachedFilteredAktivitas.clear();
    notifyListeners();
  }

  /// Get total count of aktivitas (from cached list)
  Future<int> getTotalCount() async {
    await fetchAktivitas();
    return _aktivitasList.length;
  }
  /// Get count of aktivitas by user (from cached list)
  Future<int> getCountByUserId(int userId) async {
    await fetchAktivitas();
    return _aktivitasList.length; // All activities are for current user in token-based auth
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