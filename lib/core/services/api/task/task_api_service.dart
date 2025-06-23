import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskApiService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1';
  bool _isLoading = false;
  String? _errorMessage;
  
  // Add AlarmApiService instance
  final AlarmApiService _alarmApiService = AlarmApiService();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userIdString = prefs.getString('userId');
    if (userIdString != null) {
      return int.tryParse(userIdString);
    }
    return null;
  }

  // CRUD

  Future<TaskResult> createTask({
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
      final headers = await _getHeaders();
      final userId = await _getUserId();
      if (userId == null) {
        return TaskResult.failure(
          'User ID tidak ditemukan. Silakan login ulang.',
        );
      }
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: headers,
        body: jsonEncode({
          'user_id': userId,
          'task_title': title,
          'task_description': description,
          'task_deadline': deadline.toIso8601String(),
          'estimated_task_duration': estimatedDuration,
          'task_category': category,
          'task_status': status ?? 'belum_selesai',
          'alarm_id': alarmId,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return TaskResult.success(
          task: Task.fromMap(data['data']),
          message: data['message'],
        );
      } else {
        debugPrint(
          'TaskService.createTask failed: status=${response.statusCode}, body=${response.body}',
        );
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    } finally {
      _setLoading(false);
    }
  }

  Future<TaskResult> updateTask({
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
      final headers = await _getHeaders();
      final body = {
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
        headers: headers,
        body: jsonEncode(body),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return TaskResult.success(
          task: Task.fromMap(data['data']),
          message: data['message'],
        );
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    } finally {
      _setLoading(false);
    }
  }  Future<TaskResult> deleteTask(String slug) async {    try {
      _setLoading(true);
      final headers = await _getHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$slug'),
        headers: headers,
      );
      
      final data = jsonDecode(response.body);      if (response.statusCode == 200 || response.statusCode == 204) {
        // Auto refresh data after successful deletion with improved synchronization
        try {
          await fetchTasks();
          
          // Small delay to ensure UI has time to process the changes
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          debugPrint('Warning: Failed to refresh tasks after deletion: $e');
        }
        
        return TaskResult.success(message: data['message'] ?? 'Tugas berhasil dihapus');
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      return _handleException(e);
    } finally {
      _setLoading(false);
    }
  }
  // FETCH

  Future<void> fetchTasks() async {
    _setLoading(true);
    try {
      final tasks = await getAllTasks();
      _tasks = tasks;
      _setError(null);
    } catch (e) {
      _setError('Gagal mengambil data tugas');
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> fetchTasksToday() async {
    _setLoading(true);
    try {
      final tasks = await getTasksToday();
      _tasks = tasks;
      _setError(null);
    } catch (e) {
      _setError('Gagal mengambil data tugas hari ini');
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> fetchUncompletedTasksToday() async {
    _setLoading(true);
    try {
      final tasks = await getUncompletedTasksToday();
      _tasks = tasks;
      _setError(null);
    } catch (e) {
      _setError('Gagal mengambil data tugas yang belum selesai hari ini');
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<List<Task>> getAllTasks() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // First create tasks from API data
        List<Task> tasks = List<Task>.from(data['data'].map((e) => Task.fromMap(e)));
        
        // Get all alarms once to avoid multiple API calls
        List<AlarmModel> allAlarms = await _alarmApiService.getAllAlarms();
        
        // Create a map for quick alarm lookup by ID
        Map<int, AlarmModel> alarmMap = {
          for (AlarmModel alarm in allAlarms) 
            if (alarm.id != null) alarm.id!: alarm
        };
        
        // Populate alarm relationships for tasks that have alarmId
        List<Task> tasksWithAlarms = tasks.map((task) {
          if (task.alarmId != null && alarmMap.containsKey(task.alarmId)) {
            // Create a new task with the alarm relationship populated
            return task.copyWith(alarm: alarmMap[task.alarmId]);
          }
          return task;
        }).toList();
        
        return tasksWithAlarms;
      }
    } catch (e) {
      debugPrint('Error in getAllTasks: $e');
      _handleException(e);
    }
    return [];
  }
  Future<List<Task>> getTasksToday() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/today'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // First create tasks from API data
        List<Task> tasks = List<Task>.from(data['data'].map((e) => Task.fromMap(e)));
        
        // Get all alarms once to avoid multiple API calls
        List<AlarmModel> allAlarms = await _alarmApiService.getAllAlarms();
        
        // Create a map for quick alarm lookup by ID
        Map<int, AlarmModel> alarmMap = {
          for (AlarmModel alarm in allAlarms) 
            if (alarm.id != null) alarm.id!: alarm
        };
        
        // Populate alarm relationships for tasks that have alarmId
        List<Task> tasksWithAlarms = tasks.map((task) {
          if (task.alarmId != null && alarmMap.containsKey(task.alarmId)) {
            // Create a new task with the alarm relationship populated
            return task.copyWith(alarm: alarmMap[task.alarmId]);
          }
          return task;
        }).toList();
        
        return tasksWithAlarms;
      }
    } catch (e) {
      debugPrint('Error in getTasksToday: $e');
      _handleException(e);
    }
    return [];
  }

  Future<List<Task>> getUncompletedTasksToday() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/uncompleted-today'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // First create tasks from API data
        List<Task> tasks = List<Task>.from(data['data'].map((e) => Task.fromMap(e)));
        
        // Get all alarms once to avoid multiple API calls
        List<AlarmModel> allAlarms = await _alarmApiService.getAllAlarms();
        
        // Create a map for quick alarm lookup by ID
        Map<int, AlarmModel> alarmMap = {
          for (AlarmModel alarm in allAlarms) 
            if (alarm.id != null) alarm.id!: alarm
        };
        
        // Populate alarm relationships for tasks that have alarmId
        List<Task> tasksWithAlarms = tasks.map((task) {
          if (task.alarmId != null && alarmMap.containsKey(task.alarmId)) {
            // Create a new task with the alarm relationship populated
            return task.copyWith(alarm: alarmMap[task.alarmId]);
          }
          return task;
        }).toList();
        
        return tasksWithAlarms;
      }
    } catch (e) {
      debugPrint('Error in getUncompletedTasksToday: $e');
      _handleException(e);
    }
    return [];
  }

  Future<Task?> getTaskBySlug(String slug) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$slug'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Task.fromMap(data['data']);
      }
    } catch (e) {
      _handleException(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getDashboardSummary() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/dashboard/summary'),
        headers: headers,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data'];
      }
    } catch (e) {
      _handleException(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> countLateTasks() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/dashboard/late-count'),
        headers: headers,
      );
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data'];
      }
    } catch (e) {
      _handleException(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getTasksByStatus(String status) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/tasks/dashboard/by-status',
      ).replace(queryParameters: {'status': status});
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data['data'];
      }
    } catch (e) {
      _handleException(e);
    }
    return null;
  }

  // HANDLERS

  TaskResult _handleErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      String message = data['message'] ?? 'Permintaan gagal';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        message = errors.values.expand((e) => e as List).join('\n');
      }
      _setError(message);
      return TaskResult.failure(message);
    } catch (_) {
      const message = 'Gagal memproses error response.';
      _setError(message);
      return TaskResult.failure(message);
    }
  }

  TaskResult _handleException(Object e) {
    String message = 'Terjadi kesalahan: ${e.toString()}';
    if (e.toString().contains('SocketException')) {
      message = 'Tidak dapat terhubung ke server. Periksa koneksi.';
    } else if (e.toString().contains('TimeoutException')) {
      message = 'Koneksi timeout. Coba lagi.';
    }
    _setError(message);
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
