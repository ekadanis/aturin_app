import 'package:flutter/material.dart';
import '../model/aktivitas_model.dart';
import '../../alarm/services/alarm_service.dart';
import '../../alarm/model/alarm.dart';
import '../../../core/services/api/activities/activity_api_service.dart';
import '../../../core/services/api/alarm/alarm_api_service.dart';

class AktivitasService extends ChangeNotifier {
  final ActivityApiService activityApiService = ActivityApiService();
  final AlarmService alarmService = AlarmService();
  final AlarmApiService alarmApiService = AlarmApiService();
  
  List<AktivitasModel> _aktivitasList = [];
  
  List<AktivitasModel> get aktivitasList => _aktivitasList;  /// Fetch all aktivitas from the API
  Future<void> fetchAktivitas() async {
    try {
      final result = await activityApiService.getAllActivities();
      _aktivitasList = result;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching aktivitas: $e');
      // Don't modify the list if there's an error, keep existing data
      // Only rethrow if the list is empty (first load)
      if (_aktivitasList.isEmpty) {
        rethrow;
      }
    }
  }

  /// Get aktivitas by slug (from local cache)
  AktivitasModel? getAktivitasBySlugFromCache(String slug) {
    return _aktivitasList.where((a) => a.slug == slug).firstOrNull;
  }

  /// Get aktivitas by slug (from API)
  Future<AktivitasModel?> getAktivitasBySlug(String slug) async {
    try {
      return await activityApiService.getActivityBySlug(slug);
    } catch (e) {
      debugPrint('Error getting activity by slug: $e');
      return null;
    }
  }

  /// Convert ID to slug (helper method for transition)
  String? getSlugById(int id) {
    final aktivitas = _aktivitasList.where((a) => a.id == id).firstOrNull;
    return aktivitas?.slug;
  }

  /// Generate slug from title
  String _generateSlug(String title) {
    return 'activity-' + title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '-');
  }

  /// Add aktivitas
  Future<String?> addAktivitas(AktivitasModel aktivitas, DateTime? alarmDateTime) async {
    try {
      final slug = _generateSlug(aktivitas.activityTitle);
      int? alarmId;

      // Create alarm if needed
      if (alarmDateTime != null && alarmDateTime.isAfter(DateTime.now())) {
        try {
          final newAlarm = AlarmModel(
            alarmDateTime: alarmDateTime,
            alarmEnabled: true,
            slug: 'alarm-$slug',
          );
          
          final createdAlarm = await alarmApiService.createAlarm(newAlarm);
          if (createdAlarm != null) {
            alarmId = createdAlarm.id;
            await alarmService.setAlarm(
              alarmId!,
              alarmDateTime,
              'Aktivitas: ${aktivitas.activityTitle}',
              'Aktivitas Anda akan dimulai',
            );
          }
        } catch (e) {
          debugPrint('Error creating alarm: $e');
        }
      }

      final now = DateTime.now();
      final newAktivitas = aktivitas.copyWith(
        alarmId: alarmId,
        slug: slug,
        createdAt: now,
        updatedAt: now,
      );

      final created = await activityApiService.createActivity(newAktivitas);
      if (created != null) {
        await fetchAktivitas();
        return created.slug;
      }
      throw Exception('Failed to create activity');
    } catch (e) {
      debugPrint('Error adding aktivitas: $e');
      rethrow;
    }
  }

  /// Update aktivitas by slug
  Future<bool> updateAktivitasBySlug(String slug, AktivitasModel aktivitas, DateTime? alarmDateTime) async {
    try {
      if (slug.isEmpty || aktivitas.slug == null) {
        throw Exception('Slug tidak boleh kosong');
      }

      // Get existing data using slug
      final existing = await getAktivitasBySlug(slug);
      int? alarmId = aktivitas.alarmId;      // Handle alarm based on isAlarmEnabled status
      if (existing?.alarmId != null) {
        // Aktivitas sudah punya alarm, update status enabled/disabled
        try {
          final allAlarms = await alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((a) => a.id == existing!.alarmId).firstOrNull;
          
          if (existingAlarm != null) {
            if (alarmDateTime != null && alarmDateTime.isAfter(DateTime.now())) {
              // Enable alarm dengan waktu baru
              final updatedAlarm = existingAlarm.copyWith(
                alarmDateTime: alarmDateTime,
                alarmEnabled: true,
              );
              await alarmApiService.updateAlarm(existingAlarm.slug, updatedAlarm);              await alarmService.setAlarm(
                existing!.alarmId!,
                alarmDateTime,
                'Aktivitas: ${aktivitas.activityTitle}',
                'Aktivitas Anda akan dimulai',
              );
              debugPrint('✅ Alarm enabled and updated');
            } else {
              // Disable alarm (set alarmEnabled = false)
              final updatedAlarm = existingAlarm.copyWith(
                alarmEnabled: false,
              );
              await alarmApiService.updateAlarm(existingAlarm.slug, updatedAlarm);
              await alarmService.cancelAlarm(existing!.alarmId!);
              debugPrint('✅ Alarm disabled (alarmEnabled = false)');
            }            // Keep the same alarmId
            alarmId = existing.alarmId;
          }        } catch (e) {
          debugPrint('Error updating alarm status: $e');
          alarmId = existing?.alarmId; // Keep existing alarmId if available
        }
      } else if (alarmDateTime != null && alarmDateTime.isAfter(DateTime.now())) {
        // Aktivitas belum punya alarm, buat alarm baru
        try {
          final newAlarm = AlarmModel(
            alarmDateTime: alarmDateTime,
            alarmEnabled: true,
            slug: 'alarm-$slug',
          );
          
          final created = await alarmApiService.createAlarm(newAlarm);
          if (created != null) {
            alarmId = created.id;
            await alarmService.setAlarm(
              alarmId!,
              alarmDateTime,
              'Aktivitas: ${aktivitas.activityTitle}',
              'Aktivitas Anda akan dimulai',
            );
            debugPrint('✅ New alarm created');
          }
        } catch (e) {
          debugPrint('Error creating new alarm: $e');
        }
      }

      final updated = aktivitas.copyWith(
        alarmId: alarmId,
        updatedAt: DateTime.now(),
      );

      final result = await activityApiService.updateActivity(slug, updated);
      if (result != null) {
        await fetchAktivitas();
        return true;
      }
      throw Exception('Failed to update activity');
    } catch (e) {
      debugPrint('Error updating aktivitas: $e');
      rethrow;
    }
  }

  /// Delete aktivitas by ID (convert to slug first)
  Future<bool> deleteAktivitas(int? id) async {
    if (id == null) return false;

    try {
      // Convert ID to slug
      final slug = getSlugById(id);
      if (slug == null) {
        debugPrint('❌ Tidak dapat menemukan slug untuk ID: $id');
        // Refresh data dan coba lagi
        await fetchAktivitas();
        final refreshedSlug = getSlugById(id);
        if (refreshedSlug == null) {
          throw Exception('Aktivitas tidak ditemukan');
        }
        return await deleteAktivitasBySlug(refreshedSlug);
      }
      
      return await deleteAktivitasBySlug(slug);
    } catch (e) {
      debugPrint('Error deleting aktivitas by ID: $e');
      rethrow;
    }
  }

  /// Delete aktivitas by slug
  Future<bool> deleteAktivitasBySlug(String slug) async {
    if (slug.isEmpty) return false;

    try {
      debugPrint('🗑️ Deleting aktivitas with slug: $slug');
      
      // Get aktivitas info first for alarm cleanup
      final aktivitas = await getAktivitasBySlug(slug);
      
      // Delete alarm if exists
      if (aktivitas?.alarmId != null) {
        try {
          await alarmService.cancelAlarm(aktivitas!.alarmId!);
          
          final allAlarms = await alarmApiService.getAllAlarms();
          final existingAlarm = allAlarms.where((a) => a.id == aktivitas.alarmId).firstOrNull;
          if (existingAlarm != null) {
            await alarmApiService.deleteAlarm(existingAlarm.slug);
            debugPrint('✅ Alarm deleted successfully');
          }
        } catch (e) {
          debugPrint('❌ Error deleting alarm: $e');
        }
      }      // Delete activity using slug
      final success = await activityApiService.deleteActivity(slug);
      if (success) {
        debugPrint('✅ Activity deleted successfully from API');
        
        // Update local cache immediately and notify listeners once
        _aktivitasList.removeWhere((a) => a.slug == slug);
        notifyListeners();
        
        return true;
      }
      throw Exception('Failed to delete activity from API');
    } catch (e) {
      debugPrint('❌ Error deleting aktivitas by slug: $e');
      rethrow;
    }
  }

  /// Get today's aktivitas
  Future<List<AktivitasModel>> getTodayAktivitas() async {
    try {
      return await activityApiService.getTodayActivities();
    } catch (e) {
      debugPrint('Error getting today activities: $e');
      return [];
    }
  }

  /// Get aktivitas by date range
  Future<List<AktivitasModel>> getAktivitasByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      return await activityApiService.getActivitiesByDateRange(startDate, endDate);
    } catch (e) {
      debugPrint('Error getting activities by date range: $e');
      return [];
    }
  }

  /// Get aktivitas by date
  Future<List<AktivitasModel>> getAktivitasByDate(DateTime date) async {
    try {
      return await activityApiService.getActivitiesByDate(date);
    } catch (e) {
      debugPrint('Error getting activities by date: $e');
      return [];
    }
  }

  /// Get aktivitas by category
  Future<List<AktivitasModel>> getAktivitasByCategory(ActivityCategory category) async {
    try {
      return await activityApiService.getActivitiesByCategory(category);
    } catch (e) {
      debugPrint('Error getting activities by category: $e');
      return [];
    }
  }

  /// Get aktivitas filtered by category (from local cache)
  List<AktivitasModel> getAktivitasByCategoryFromCache(ActivityCategory? category) {
    if (category == null) return _aktivitasList;
    return _aktivitasList.where((aktivitas) => aktivitas.activityCategory == category).toList();
  }
}