import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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
      );

      debugPrint('Create alarm response: \\${response.statusCode} - \\${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        debugPrint('Alarm API response data: \\${data['data']}');
        return AlarmModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating alarm: $e');
      return null;
    }
  }

  /// Get alarm by ID
  Future<AlarmModel?> getAlarmById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/alarms/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AlarmModel.fromJson(data['data']);
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
  }

  /// Update an existing alarm
  Future<AlarmModel?> updateAlarm(String slug, AlarmModel alarm) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'alarm_date_time': alarm.alarmDateTime.toIso8601String(),
        'is_alarm_enabled': alarm.alarmEnabled, // use correct key
        'slug': alarm.slug,
      });

      final response = await http.put(
        Uri.parse('$baseUrl/alarms/$slug'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AlarmModel.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating alarm: $e');
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
        'alarm_enabled': enabled,
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

class AlarmModel {
  final int? id; // id is nullable for creation
  final DateTime alarmDateTime;
  final bool alarmEnabled;
  final String slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AlarmModel({
    this.id,
    required this.alarmDateTime,
    required this.alarmEnabled,
    required this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      alarmDateTime: json['alarm_date_time'] != null ? DateTime.parse(json['alarm_date_time']) : DateTime.now(),
      alarmEnabled: json['is_alarm_enabled'] == 1 || json['is_alarm_enabled'] == true || json['alarm_enabled'] == 1 || json['alarm_enabled'] == true,
      slug: json['slug'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alarm_date_time': alarmDateTime.toIso8601String(),
      'is_alarm_enabled': alarmEnabled,
      'slug': slug,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}