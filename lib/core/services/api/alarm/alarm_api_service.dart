import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../../features/alarm/model/alarm.dart';

class AlarmApiService {
  static const String baseUrl = 'https://aturin-app.com/api/v1';

  /// Get authentication token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Get common headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  /// Create a new alarm
  Future<AlarmModel?> createAlarm(AlarmModel alarm) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'alarm_date_time': alarm.alarmDateTime.toIso8601String(),
        'is_alarm_enabled': alarm.alarmEnabled, // use correct key
        'slug': alarm.slug,
      });

      debugPrint('Creating alarm: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/alarms'),
        headers: headers,
        body: body,
      );      debugPrint('Create alarm response: ${response.statusCode} - ${response.body}');      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final result = AlarmModel.fromJson(data['data']);
        
        // Enhanced debug logging
        print('=== ALARM CREATION SUCCESS ===');
        print('Created alarm ID: ${result.id}');
        print('Created alarm data: ${json.encode(data['data'])}');
        print('AlarmModel object: ${result.toString()}');
        
        return result;
      }
      return null;    } catch (e) {
      debugPrint('Error creating alarm: $e');
      return null;
    }
  }

  /// Get alarm by slug (backend only supports slug-based endpoints)
  Future<AlarmModel?> getAlarmBySlug(String slug) async {
    try {
      final headers = await _getHeaders();
      debugPrint('=== GET ALARM BY SLUG DEBUG ===');
      debugPrint('Requesting alarm with slug: $slug');
      debugPrint('URL: $baseUrl/alarms/$slug');
      
      final response = await http.get(
        Uri.parse('$baseUrl/alarms/$slug'),
        headers: headers,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final alarm = AlarmModel.fromJson(data['data']);
        debugPrint('✅ Found alarm:');
        debugPrint('  - ID: ${alarm.id}');
        debugPrint('  - DateTime: ${alarm.alarmDateTime}');
        debugPrint('  - Slug: ${alarm.slug}');
        debugPrint('  - Enabled: ${alarm.alarmEnabled}');
        return alarm;
      } else {
        debugPrint('❌ Failed to get alarm: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting alarm by slug: $e');
      return null;
    }
  }

  /// Get all alarms
  Future<List<AlarmModel>> getAllAlarms() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alarms'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> alarmsJson = data['data'];
        return alarmsJson.map((json) => AlarmModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting all alarms: $e');
      return [];
    }
  }

  /// Get enabled alarms only
  Future<List<AlarmModel>> getEnabledAlarms() async {
    try {
      final allAlarms = await getAllAlarms();
      return allAlarms.where((alarm) => alarm.alarmEnabled).toList();
    } catch (e) {
      debugPrint('Error getting enabled alarms: $e');
      return [];
    }
  }

  /// Get alarms for a specific date
  Future<List<AlarmModel>> getAlarmsByDate(DateTime date) async {
    try {
      final headers = await _getHeaders();
      final formattedDate = date.toIso8601String().split('T')[0];
      final response = await http.get(
        Uri.parse('$baseUrl/alarms?date=$formattedDate'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> alarmsJson = data['data'];
        return alarmsJson.map((json) => AlarmModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting alarms by date: $e');
      return [];
    }
  }  /// Update an existing alarm
  Future<AlarmModel?> updateAlarm(String slug, AlarmModel alarm) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'alarm_date_time': alarm.alarmDateTime.toIso8601String(),
        'is_alarm_enabled': alarm.alarmEnabled, // use correct key
        'slug': alarm.slug,
      });

      debugPrint('=== UPDATE ALARM API DEBUG ===');
      debugPrint('Input alarm object:');
      debugPrint('  - DateTime: ${alarm.alarmDateTime}');
      debugPrint('  - DateTime ISO: ${alarm.alarmDateTime.toIso8601String()}');
      debugPrint('  - Enabled: ${alarm.alarmEnabled}');
      debugPrint('  - Slug: ${alarm.slug}');
      debugPrint('  - ID: ${alarm.id}');      debugPrint('Request details:');
      debugPrint('  - URL: $baseUrl/alarms/$slug');
      debugPrint('  - Method: PATCH');
      debugPrint('  - Headers: $headers');
      debugPrint('  - Body: $body');final response = await http.patch(
        Uri.parse('$baseUrl/alarms/$slug'),
        headers: headers,
        body: body,
      );

      debugPrint('Response details:');
      debugPrint('  - Status: ${response.statusCode}');
      debugPrint('  - Headers: ${response.headers}');
      debugPrint('  - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Parsed response data: ${json.encode(data)}');
        
        if (data['data'] != null) {
          final updatedAlarm = AlarmModel.fromJson(data['data']);
          debugPrint('✅ Alarm berhasil diupdate via API:');
          debugPrint('  - New ID: ${updatedAlarm.id}');
          debugPrint('  - New DateTime: ${updatedAlarm.alarmDateTime}');
          debugPrint('  - New DateTime ISO: ${updatedAlarm.alarmDateTime.toIso8601String()}');
          debugPrint('  - New Enabled: ${updatedAlarm.alarmEnabled}');
          debugPrint('  - New Slug: ${updatedAlarm.slug}');
          
          // Compare with input
          debugPrint('Comparison with input:');
          debugPrint('  - DateTime match: ${alarm.alarmDateTime.isAtSameMomentAs(updatedAlarm.alarmDateTime)}');
          debugPrint('  - Enabled match: ${alarm.alarmEnabled == updatedAlarm.alarmEnabled}');
          debugPrint('  - Slug match: ${alarm.slug == updatedAlarm.slug}');
          
          return updatedAlarm;
        } else {
          debugPrint('❌ No data field in response');
        }
      } else {
        debugPrint('❌ API returned status ${response.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error updating alarm: $e');
      return null;
    }
  }

  /// Delete an alarm
  Future<bool> deleteAlarm(String slug) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/alarms/$slug'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting alarm: $e');
      return false;
    }
  }
  /// Toggle alarm enabled status
  Future<bool> toggleAlarmEnabled(String slug, bool enabled) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'is_alarm_enabled': enabled,
      });

      final response = await http.patch(
        Uri.parse('$baseUrl/alarms/$slug/toggle'),
        headers: headers,
        body: body,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error toggling alarm enabled: $e');
      return false;
    }
  }

  /// Get upcoming alarms (next 24 hours)
  Future<List<AlarmModel>> getUpcomingAlarms() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alarms/upcoming'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> alarmsJson = data['data'];
        return alarmsJson.map((json) => AlarmModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting upcoming alarms: $e');
      return [];
    }
  }

  /// Get overdue alarms
  Future<List<AlarmModel>> getOverdueAlarms() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alarms/overdue'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> alarmsJson = data['data'];
        return alarmsJson.map((json) => AlarmModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting overdue alarms: $e');
      return [];
    }
  }
}

