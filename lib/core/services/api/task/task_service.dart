import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aturin_app/features/task/model/task_model.dart';

class TaskService extends ChangeNotifier {
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

  void clearError() {
    _setError(null);
  }

  Future<TaskResult> createTask({
    required String token,
    required String title,
    String? description,
    required DateTime deadline,
    required String estimatedDuration,
    required String category,
    String? status,
    int? alarmId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: _headers(token),
        body: jsonEncode({
          'task_title': title,
          'task_description': description,
          'task_deadline': deadline.toIso8601String(),
          'estimated_task_duration': estimatedDuration,
          'task_category': category,
          'task_status': status,
          'alarm_id': alarmId,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final task = Task.fromMap(data['data']);
        _setLoading(false);
        return TaskResult.success(task: task, message: data['message']);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  Future<TaskResult> updateTask({
    required String token,
    required String slug,
    String? title,
    String? description,
    DateTime? deadline,
    String? estimatedDuration,
    String? status,
    String? category,
    int? alarmId,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final body = <String, dynamic>{
        if (title != null) 'task_title': title,
        if (description != null) 'task_description': description,
        if (deadline != null) 'task_deadline': deadline.toIso8601String(),
        if (estimatedDuration != null)
          'estimated_task_duration': estimatedDuration,
        if (status != null) 'task_status': status,
        if (category != null) 'task_category': category,
        if (alarmId != null) 'alarm_id': alarmId,
      };

      final response = await http.patch(
        Uri.parse('$baseUrl/tasks/$slug'),
        headers: _headers(token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final task = Task.fromMap(data['data']);
        _setLoading(false);
        return TaskResult.success(task: task, message: data['message']);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  Future<TaskResult> deleteTask({
    required String token,
    required String slug,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$slug'),
        headers: _headers(token, acceptJsonOnly: true),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        _setLoading(false);
        return TaskResult.success(message: data['message']);
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    }
  }

  Future<List<Task>> getAllTasks(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: _headers(token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return List<Task>.from(data['data'].map((t) => Task.fromMap(t)));
      } else {
        _handleErrorResponse(response);
        return [];
      }
    } catch (e) {
      _handleException(e);
      return [];
    }
  }

  Future<List<Task>> getTasksToday(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/today'),
        headers: _headers(token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return List<Task>.from(data['data'].map((t) => Task.fromMap(t)));
      } else {
        _handleErrorResponse(response);
        return [];
      }
    } catch (e) {
      _handleException(e);
      return [];
    }
  }

  Future<Task?> getTaskBySlug(String token, String slug) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$slug'),
        headers: _headers(token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Task.fromMap(data['data']);
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } catch (e) {
      _handleException(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDashboardSummary(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/dashboard/summary'),
        headers: _headers(token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data'];
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } catch (e) {
      _handleException(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> countLateTasks(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/dashboard/late-count'),
        headers: _headers(token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data'];
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } catch (e) {
      _handleException(e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getTasksByStatus(
    String token,
    String status,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/tasks/dashboard/by-status',
      ).replace(queryParameters: {'status': status});

      final response = await http.get(uri, headers: _headers(token));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data'];
      } else {
        _handleErrorResponse(response);
        return null;
      }
    } catch (e) {
      _handleException(e);
      return null;
    }
  }

  Map<String, String> _headers(String token, {bool acceptJsonOnly = false}) {
    return {
      if (!acceptJsonOnly) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  TaskResult _handleErrorResponse(http.Response response) {
    try {
      final errorData = jsonDecode(response.body);
      String message = errorData['message'] ?? 'Permintaan gagal';

      if (errorData['errors'] != null) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        final messages = errors.values.expand((e) => e as List).join('\n');
        message = messages;
      }

      _setError(message);
      _setLoading(false);
      return TaskResult.failure(message);
    } catch (_) {
      final msg = 'Gagal memproses error (Status: ${response.statusCode})';
      _setError(msg);
      _setLoading(false);
      return TaskResult.failure(msg);
    }
  }

  TaskResult _handleException(Object e) {
    String message = 'Terjadi kesalahan: ${e.toString()}';
    if (e.toString().contains('SocketException')) {
      message = 'Tidak dapat terhubung ke server. Periksa koneksi.';
    } else if (e.toString().contains('TimeoutException')) {
      message = 'Koneksi timeout. Coba lagi.';
    }

    debugPrint('Task error: $e');
    _setError(message);
    _setLoading(false);
    return TaskResult.failure(message);
  }
}

class TaskResult {
  final bool isSuccess;
  final Task? task;
  final String message;

  TaskResult.success({this.task, required this.message}) : isSuccess = true;
  TaskResult.failure(this.message) : isSuccess = false, task = null;
}
