import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aturin_app/features/alarm/model/alarm.dart';

class AlarmService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() => _setError(null);

  // Get All Alarms
  Future<List<AlarmModel>> getAllAlarms(String token) async {
    try {
      _setLoading(true);
      final response = await http.get(
        Uri.parse('$baseUrl/alarms'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> alarms = data['data'];
        _setLoading(false);
        return alarms.map((json) => AlarmModel.fromJson(json)).toList();
      } else {
        _setLoading(false);
        _setError(data['message']);
        return [];
      }
    } catch (e) {
      _handleException(e);
      return [];
    }
  }

  // Get Alarm by Slug
  Future<AlarmResult> getAlarmBySlug({
    required String token,
    required String slug,
  }) async {
    try {
      _setLoading(true);
      final response = await http.get(
        Uri.parse('$baseUrl/alarms/$slug'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final alarm = AlarmModel.fromJson(data['data']);
        _setLoading(false);
        return AlarmResult.success(alarm: alarm, message: data['message']);
      } else {
        return _handleErrorResponse(data, response.statusCode);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  // Create Alarm
  Future<AlarmResult> createAlarm({
    required String token,
    required DateTime alarmDateTime,
    required bool isAlarmEnabled,
  }) async {
    try {
      _setLoading(true);
      final response = await http.post(
        Uri.parse('$baseUrl/alarms'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'alarm_date_time': alarmDateTime.toIso8601String(),
          'is_alarm_enabled': isAlarmEnabled,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final alarm = AlarmModel.fromJson(data['data']);
        _setLoading(false);
        return AlarmResult.success(alarm: alarm, message: data['message']);
      } else {
        return _handleErrorResponse(data, response.statusCode);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  // Update Alarm
  Future<AlarmResult> updateAlarm({
    required String token,
    required String slug,
    DateTime? alarmDateTime,
    bool? isAlarmEnabled,
  }) async {
    try {
      _setLoading(true);
      final body = <String, dynamic>{};
      if (alarmDateTime != null) {
        body['alarm_date_time'] = alarmDateTime.toIso8601String();
      }
      if (isAlarmEnabled != null) {
        body['is_alarm_enabled'] = isAlarmEnabled;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/alarms/$slug'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final alarm = AlarmModel.fromJson(data['data']);
        _setLoading(false);
        return AlarmResult.success(alarm: alarm, message: data['message']);
      } else {
        return _handleErrorResponse(data, response.statusCode);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  // Delete Alarm
  Future<AlarmResult> deleteAlarm({
    required String token,
    required String slug,
  }) async {
    try {
      _setLoading(true);
      final response = await http.delete(
        Uri.parse('$baseUrl/alarms/$slug'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _setLoading(false);
        return AlarmResult.success(message: data['message']);
      } else {
        return _handleErrorResponse(data, response.statusCode);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  AlarmResult _handleErrorResponse(Map<String, dynamic> data, int statusCode) {
    String message = data['message'] ?? 'Permintaan gagal';
    if (data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final messages = errors.values.expand((v) => v).join('\n');
      message = messages;
    }
    _setError(message);
    _setLoading(false);
    return AlarmResult.failure(message);
  }

  AlarmResult _handleException(Object e) {
    String errorMessage = 'Terjadi kesalahan jaringan';
    if (e.toString().contains('SocketException') ||
        e.toString().contains('Connection refused')) {
      errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi.';
    } else if (e.toString().contains('TimeoutException')) {
      errorMessage = 'Koneksi timeout. Coba lagi.';
    } else {
      errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    }

    debugPrint('Alarm error: $e');
    _setError(errorMessage);
    _setLoading(false);
    return AlarmResult.failure(errorMessage);
  }
}

class AlarmResult {
  final bool isSuccess;
  final AlarmModel? alarm;
  final String message;

  AlarmResult.success({this.alarm, required this.message}) : isSuccess = true;
  AlarmResult.failure(this.message) : isSuccess = false, alarm = null;
}
