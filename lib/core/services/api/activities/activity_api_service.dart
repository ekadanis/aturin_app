import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';

class ActivityApiService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1/activities';

  // Instance for loading alarm relationships
  final AlarmApiService _alarmApiService = AlarmApiService();

  // State management properties
  List<AktivitasModel> _activities = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AktivitasModel> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setActivities(List<AktivitasModel> activities) {
    _activities = activities;
    notifyListeners();
  }

  // Fetch activities with automatic state management
  Future<void> fetchActivities() async {
    _setLoading(true);
    _setError(null);

    try {
      final activities = await getAllActivities();
      _setActivities(activities);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Get authorization token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get user ID from SharedPreferences
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('userId');
    if (userIdString != null) {
      return int.tryParse(userIdString);
    }
    return null;
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /activities → Get all activities
  Future<List<AktivitasModel>> getAllActivities() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData = jsonResponse['data'];
          final activities = activitiesData
              .map((json) {
                try {
                  return AktivitasModel.fromJson(json);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error parsing activity: $e');
                  }
                  return null;
                }
              })
              .where((activity) => activity != null)
              .cast<AktivitasModel>()
              .toList();

          // Load alarm relationships for activities that have alarmId
          try {
            final alarmsWithIds = activities
                .where((activity) => activity.alarmId != null)
                .toList();
            
            if (alarmsWithIds.isNotEmpty) {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarmMap = {for (var alarm in allAlarms) alarm.id: alarm};

              final activitiesWithAlarms = activities.map((activity) {
                if (activity.alarmId != null &&
                    alarmMap.containsKey(activity.alarmId)) {
                  return activity.copyWith(
                    alarm: alarmMap[activity.alarmId],
                  );
                }
                return activity;
              }).toList();

              return activitiesWithAlarms;
            }
          } catch (e) {
            // Silently continue if alarm loading fails
          }

          return activities;
        }
        return [];
      } else {
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching activities: $e');
    }
  }

  // GET /activities/today → Get today's activities
  Future<List<AktivitasModel>> getTodayActivities() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/today'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData = jsonResponse['data'];
          final activities = activitiesData
              .map((json) {
                try {
                  return AktivitasModel.fromJson(json);
                } catch (e) {
                  if (kDebugMode) {
                    print('Error parsing today activity: $e');
                  }
                  return null;
                }
              })
              .where((activity) => activity != null)
              .cast<AktivitasModel>()
              .toList();

          // Load alarm relationships for activities that have alarmId
          try {
            final activitiesWithIds = activities
                .where((activity) => activity.alarmId != null)
                .toList();
            
            if (activitiesWithIds.isNotEmpty) {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarmMap = {for (var alarm in allAlarms) alarm.id: alarm};

              final activitiesWithAlarms = activities.map((activity) {
                if (activity.alarmId != null &&
                    alarmMap.containsKey(activity.alarmId)) {
                  return activity.copyWith(
                    alarm: alarmMap[activity.alarmId],
                  );
                }
                return activity;
              }).toList();

              return activitiesWithAlarms;
            }
          } catch (e) {
            // Silently continue if alarm loading fails
          }

          return activities;
        }
        return [];
      } else {
        throw Exception('Failed to load today activities: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching today activities: $e');
    }
  }

  // POST /activities → Create new activity
  Future<AktivitasModel?> createActivity(AktivitasModel activity) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();

      // Prepare the activity data for API with proper formatting
      final startTimeFormatted =
          '${activity.activityStartTime.hour.toString().padLeft(2, '0')}:${activity.activityStartTime.minute.toString().padLeft(2, '0')}';
      final endTimeFormatted =
          '${activity.activityCompleteTime.hour.toString().padLeft(2, '0')}:${activity.activityCompleteTime.minute.toString().padLeft(2, '0')}';
      
      final activityData = <String, dynamic>{
        'user_id': userId,
        'activity_title': activity.activityTitle,
        'activity_date': activity.activityDate.toIso8601String().split('T')[0],
        'activity_start_time': startTimeFormatted,
        'activity_complete_time': endTimeFormatted,
        'activity_category': activity.activityCategory.apiName,
      };

      // Include slug if provided to override server-side generation
      if (activity.slug != null && activity.slug!.isNotEmpty) {
        activityData['slug'] = activity.slug;
      }

      // Only include alarm_id if it's not null to avoid validation errors
      if (activity.alarmId != null) {
        activityData['alarm_id'] = activity.alarmId;
      }

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(activityData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          // Handle nested data structure
          final activityJson = jsonResponse['data']['data'] ?? jsonResponse['data'];
          final result = AktivitasModel.fromJson(activityJson);

          // Load alarm relationship if activity has alarmId
          if (result.alarmId != null) {
            try {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarm = allAlarms
                  .where((alarm) => alarm.id == result.alarmId)
                  .firstOrNull;

              if (alarm != null) {
                return result.copyWith(alarm: alarm);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error loading alarm relationship: $e');
              }
            }
          }

          return result;
        }
      } else {
        throw Exception(
          'Failed to create activity: ${response.statusCode} - ${response.body}',
        );
      }
      return null;
    } catch (e) {
      throw Exception('Error creating activity: $e');
    }
  }

  // GET /activities/{slug} → Get activity detail
  Future<AktivitasModel?> getActivityBySlug(String slug) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/$slug'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          final activityJson = jsonResponse['data']['data'] ?? jsonResponse['data'];
          final activity = AktivitasModel.fromJson(activityJson);

          // Load alarm relationship if activity has alarmId
          if (activity.alarmId != null) {
            try {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarm = allAlarms
                  .where((alarm) => alarm.id == activity.alarmId)
                  .firstOrNull;

              if (alarm != null) {
                return activity.copyWith(alarm: alarm);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error loading alarm relationship: $e');
              }
            }
          }

          return activity;
        }
      } else {
        throw Exception('Failed to load activity: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching activity: $e');
    }
  }

  // PATCH /activities/{slug} → Update activity
  Future<AktivitasModel?> updateActivity(
    String slug,
    AktivitasModel activity,
  ) async {
    try {
      final headers = await _getHeaders();
      final startTimeFormatted =
          '${activity.activityStartTime.hour.toString().padLeft(2, '0')}:${activity.activityStartTime.minute.toString().padLeft(2, '0')}';
      final endTimeFormatted =
          '${activity.activityCompleteTime.hour.toString().padLeft(2, '0')}:${activity.activityCompleteTime.minute.toString().padLeft(2, '0')}';

      // Only send fields that can be updated (no user_id)
      final activityData = <String, dynamic>{
        'activity_title': activity.activityTitle,
        'activity_date': activity.activityDate.toIso8601String().split('T')[0],
        'activity_start_time': startTimeFormatted,
        'activity_complete_time': endTimeFormatted,
        'activity_category': activity.activityCategory.apiName,
      };

      // Only include alarm_id if it's not null to avoid validation errors
      if (activity.alarmId != null) {
        activityData['alarm_id'] = activity.alarmId;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/$slug'),
        headers: headers,
        body: json.encode(activityData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          final activityJson = jsonResponse['data']['data'] ?? jsonResponse['data'];
          final updatedActivity = AktivitasModel.fromJson(activityJson);

          // Load alarm relationship if activity has alarmId
          if (updatedActivity.alarmId != null) {
            try {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarm = allAlarms
                  .where((alarm) => alarm.id == updatedActivity.alarmId)
                  .firstOrNull;

              if (alarm != null) {
                return updatedActivity.copyWith(alarm: alarm);
              }
            } catch (e) {
              if (kDebugMode) {
                print('Error loading alarm relationship: $e');
              }
            }
          }

          return updatedActivity;
        }
      } else {
        // Provide specific error messages based on status code
        if (response.statusCode == 404) {
          throw Exception(
            'Activity not found: Aktivitas dengan slug "$slug" tidak ditemukan di server.',
          );
        } else if (response.statusCode == 422) {
          throw Exception('Validation error: ${response.body}');
        } else if (response.statusCode >= 500) {
          throw Exception(
            'Server error: ${response.statusCode} - ${response.body}',
          );
        } else {
          throw Exception(
            'Failed to update activity: ${response.statusCode} - ${response.body}',
          );
        }
      }
      return null;
    } catch (e) {
      // Re-throw with preserved error context
      if (e.toString().contains('Activity not found')) {
        rethrow;
      }
      throw Exception('Error updating activity: $e');
    }
  }

  // DELETE /activities/{slug} → Delete activity
  Future<bool> deleteActivity(String slug) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/$slug'),
        headers: headers,
      );

      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 404) {
        // Auto refresh data after successful deletion
        try {
          await fetchActivities();
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          if (kDebugMode) {
            print('Warning: Failed to refresh activities after deletion: $e');
          }
        }

        return true;
      } else {
        throw Exception('Failed to delete activity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting activity: $e');
    }
  }

  // Get activities by date range
  Future<List<AktivitasModel>> getActivitiesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(
          '$baseUrl?start_date=${startDate.toIso8601String().split('T')[0]}&end_date=${endDate.toIso8601String().split('T')[0]}',
        ),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          final activities = activitiesData
              .map((json) => AktivitasModel.fromJson(json))
              .toList();

          // Load alarm relationships for activities that have alarmId
          try {
            final activitiesWithIds = activities
                .where((activity) => activity.alarmId != null)
                .toList();
            
            if (activitiesWithIds.isNotEmpty) {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarmMap = {for (var alarm in allAlarms) alarm.id: alarm};

              final activitiesWithAlarms = activities.map((activity) {
                if (activity.alarmId != null &&
                    alarmMap.containsKey(activity.alarmId)) {
                  return activity.copyWith(
                    alarm: alarmMap[activity.alarmId],
                  );
                }
                return activity;
              }).toList();

              return activitiesWithAlarms;
            }
          } catch (e) {
            // Silently continue if alarm loading fails
          }

          return activities;
        }
        return [];
      } else {
        throw Exception(
          'Failed to load activities by date range: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching activities by date range: $e');
    }
  }

  // Get activities by category
  Future<List<AktivitasModel>> getActivitiesByCategory(
    ActivityCategory category,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl?category=${category.displayName}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          final activities = activitiesData
              .map((json) => AktivitasModel.fromJson(json))
              .toList();

          // Load alarm relationships for activities that have alarmId
          try {
            final activitiesWithIds = activities
                .where((activity) => activity.alarmId != null)
                .toList();
            
            if (activitiesWithIds.isNotEmpty) {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarmMap = {for (var alarm in allAlarms) alarm.id: alarm};

              final activitiesWithAlarms = activities.map((activity) {
                if (activity.alarmId != null &&
                    alarmMap.containsKey(activity.alarmId)) {
                  return activity.copyWith(
                    alarm: alarmMap[activity.alarmId],
                  );
                }
                return activity;
              }).toList();

              return activitiesWithAlarms;
            }
          } catch (e) {
            // Silently continue if alarm loading fails
          }

          return activities;
        }
        return [];
      } else {
        throw Exception(
          'Failed to load activities by category: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching activities by category: $e');
    }
  }

  // Helper method to get activities for a specific date
  Future<List<AktivitasModel>> getActivitiesByDate(DateTime date) async {
    try {
      final headers = await _getHeaders();
      final dateString = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl?date=$dateString'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if ((jsonResponse['status'] == 'success' ||
                jsonResponse['status'] == 'Berhasil') &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          final activities = activitiesData
              .map((json) => AktivitasModel.fromJson(json))
              .toList();

          // Load alarm relationships for activities that have alarmId
          try {
            final activitiesWithIds = activities
                .where((activity) => activity.alarmId != null)
                .toList();
            
            if (activitiesWithIds.isNotEmpty) {
              final allAlarms = await _alarmApiService.getAllAlarms();
              final alarmMap = {for (var alarm in allAlarms) alarm.id: alarm};

              final activitiesWithAlarms = activities.map((activity) {
                if (activity.alarmId != null &&
                    alarmMap.containsKey(activity.alarmId)) {
                  return activity.copyWith(
                    alarm: alarmMap[activity.alarmId],
                  );
                }
                return activity;
              }).toList();

              return activitiesWithAlarms;
            }
          } catch (e) {
            // Silently continue if alarm loading fails
          }

          return activities;
        }
        return [];
      } else {
        throw Exception(
          'Failed to load activities by date: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching activities by date: $e');
    }
  }
}