import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';

class ActivityApiService {
  static const String baseUrl = 'https://aturin-app.com/api/v1/activities';

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
        // Handle the response structure from Laravel API
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData = jsonResponse['data'];
          return activitiesData
              .map((json) {
                try {
                  return AktivitasModel.fromJson(json);
                } catch (e) {
                  print('DEBUG: Error parsing individual activity: $e');
                  print('DEBUG: Activity data: $json');
                  return null;
                }
              })
              .where((activity) => activity != null)
              .cast<AktivitasModel>()
              .toList();
        }
        return [];
      } else {
        print(
          'DEBUG: getAllActivities failed with status: ${response.statusCode}',
        );
        throw Exception('Failed to load activities: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: getAllActivities error: $e');
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

      print(
        'DEBUG: getTodayActivities response status: ${response.statusCode}',
      );
      print('DEBUG: getTodayActivities response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData = jsonResponse['data'];
          return activitiesData
              .map((json) {
                try {
                  return AktivitasModel.fromJson(json);
                } catch (e) {
                  print('DEBUG: Error parsing today activity: $e');
                  print('DEBUG: Activity data: $json');
                  return null;
                }
              })
              .where((activity) => activity != null)
              .cast<AktivitasModel>()
              .toList();
        }
        return [];
      } else {
        print(
          'DEBUG: getTodayActivities failed with status: ${response.statusCode}',
        );
        throw Exception(
          'Failed to load today activities: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('DEBUG: getTodayActivities error: $e');
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
      final activityData = {
        'user_id': userId,
        'activity_title': activity.activityTitle,
        'activity_date': activity.activityDate.toIso8601String().split('T')[0],
        'activity_start_time': startTimeFormatted,
        'activity_complete_time': endTimeFormatted,
        'activity_category': activity.activityCategory.apiName,
        'alarm_id': activity.alarmId,
      };

      // Debug: Print the data being sent
      print('Sending activity data: ${json.encode(activityData)}');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: json.encode(activityData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          // Handle nested data structure
          final activityJson =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          return AktivitasModel.fromJson(activityJson);
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

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final activityJson =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          return AktivitasModel.fromJson(activityJson);
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
          '${activity.activityCompleteTime.hour.toString().padLeft(2, '0')}:${activity.activityCompleteTime.minute.toString().padLeft(2, '0')}';      // Only send fields that can be updated (no user_id)
      final activityData = {
        'activity_title': activity.activityTitle,
        'activity_date': activity.activityDate.toIso8601String().split('T')[0],
        'activity_start_time': startTimeFormatted,
        'activity_complete_time': endTimeFormatted,
        'activity_category': activity.activityCategory.apiName,
        if (activity.alarmId != null) 'alarm_id': activity.alarmId,
      };

      // Debug logging
      print('DEBUG updateActivity: Updating activity with slug: $slug');
      print('DEBUG updateActivity: Full URL: $baseUrl/$slug');
      print('DEBUG updateActivity: Activity data: ${json.encode(activityData)}');

      final response = await http.patch(
        Uri.parse('$baseUrl/$slug'),
        headers: headers,
        body: json.encode(activityData),
      );

      print('DEBUG updateActivity: Response status: ${response.statusCode}');
      print('DEBUG updateActivity: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final activityJson =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          return AktivitasModel.fromJson(activityJson);
        }
      } else {
        throw Exception(
          'Failed to update activity: ${response.statusCode} - ${response.body}',
        );
      }
      return null;
    } catch (e) {
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

      if (response.statusCode == 200 || response.statusCode == 204) {
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

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          return activitiesData
              .map((json) => AktivitasModel.fromJson(json))
              .toList();
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

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          return activitiesData
              .map((json) => AktivitasModel.fromJson(json))
              .toList();
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

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          final List<dynamic> activitiesData =
              jsonResponse['data']['data'] ?? jsonResponse['data'];
          return activitiesData
              .map((json) => AktivitasModel.fromJson(json))
              .toList();
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
