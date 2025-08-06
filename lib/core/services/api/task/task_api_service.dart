import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aturin_app/core/services/cache/cache_service.dart';

class TaskApiService extends ChangeNotifier {
  static const String baseUrl = 'https://aturin-app.com/api/v1';
  bool _isLoading = false;
  String? _errorMessage;
  
  // Add AlarmApiService instance
  final AlarmApiService _alarmApiService = AlarmApiService();
  final CacheService _cacheService = CacheService();
  
  // Cache keys
  static const String _allTasksCacheKey = 'all_tasks';
  static const String _todayTasksCacheKey = 'today_tasks';
  static const String _uncompletedTodayCacheKey = 'uncompleted_today_tasks';
  static const String _tasksByStatusCacheKey = 'tasks_by_status_';
  static const String _dashboardSummaryCacheKey = 'dashboard_summary';
  static const String _lateTasksCountCacheKey = 'late_tasks_count';
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  
  // Untuk menandai apakah data telah berubah
  bool _dataChanged = false;

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
  
  // Metode untuk menandai data telah berubah (dipanggil setelah update/delete/create)
  void _markDataChanged() {
    _dataChanged = true;
    debugPrint('🗄️ Cache: Data telah ditandai berubah');
    // Tidak perlu clear cache di sini karena sudah di-handle di _updateCachesAfterChange
    // notifyListeners(); // Sudah dipanggil di method yang memanggil ini
  }
  
  // Metode untuk membersihkan cache yang terkait saat data berubah
  Future<void> _clearRelatedCaches() async {
    await _cacheService.removeData(_allTasksCacheKey);
    await _cacheService.removeData(_todayTasksCacheKey);
    await _cacheService.removeData(_uncompletedTodayCacheKey);
    await _cacheService.removeData(_dashboardSummaryCacheKey);
    await _cacheService.removeData(_lateTasksCountCacheKey);
    
    // Clear status-based caches
    await _cacheService.removeData('${_tasksByStatusCacheKey}terlambat');
    await _cacheService.removeData('${_tasksByStatusCacheKey}belum_selesai');
    await _cacheService.removeData('${_tasksByStatusCacheKey}selesai');
    
    debugPrint('🗄️ Cache: Semua cache terkait task telah dibersihkan');
  }
  
  // Metode untuk update cache setelah perubahan data (create/update/delete)
  Future<void> _updateCachesAfterChange() async {
    try {
      // Update cache _allTasksCacheKey dengan data lokal terbaru
      final List<Map<String, dynamic>> tasksAsMap = _tasks
          .map((task) => task.toMap())
          .toList();
      await _cacheService.saveData(
        key: _allTasksCacheKey, 
        data: tasksAsMap,
        maxAge: _cacheValidityDuration,
      );
      
      // Update cache untuk today tasks
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayTasks = _tasks.where((task) {
        final taskDate = DateTime(
          task.deadline.year,
          task.deadline.month,
          task.deadline.day,
        );
        return taskDate.isAtSameMomentAs(today);
      }).toList();
      
      final todayTasksAsMap = todayTasks.map((task) => task.toMap()).toList();
      await _cacheService.saveData(
        key: _todayTasksCacheKey, 
        data: todayTasksAsMap,
        maxAge: _cacheValidityDuration,
      );
      
      // Update cache untuk uncompleted today tasks
      final uncompletedTodayTasks = todayTasks.where((task) => !task.isCompleted).toList();
      final uncompletedTodayTasksAsMap = uncompletedTodayTasks.map((task) => task.toMap()).toList();
      await _cacheService.saveData(
        key: _uncompletedTodayCacheKey, 
        data: uncompletedTodayTasksAsMap,
        maxAge: _cacheValidityDuration,
      );
      
      // Update cache untuk late tasks count
      final lateTasks = _tasks.where((task) => 
        task.deadline.isBefore(now) && !task.isCompleted
      ).length;
      final lateTasksData = {
        'overdue_tasks': lateTasks,
        'completed_late_tasks': 0, // Will be calculated when needed
      };
      await _cacheService.saveData(
        key: _lateTasksCountCacheKey, 
        data: lateTasksData,
        maxAge: _cacheValidityDuration,
      );
      
      debugPrint('🗄️ Cache: Semua cache terkait telah diperbarui secara sinkron');
    } catch (e) {
      debugPrint('🗄️ Cache: Error updating caches after change: $e');
      // Fallback: clear caches if update fails
      await _clearRelatedCaches();
    }
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
          'task_status': 'belum_selesai',
          'alarm_id': alarmId,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final newTask = Task.fromMap(data['data']);
        
        // Update local cache dengan menambahkan task baru
        _tasks.add(newTask);
        debugPrint('🔄 TaskApiService: Task berhasil ditambahkan ke local cache. Total tasks: ${_tasks.length}');
        debugPrint('🔄 TaskApiService: Current _tasks IDs after add: ${_tasks.map((t) => t.id).toList()}');
        
        // IMMEDIATE UI UPDATE - panggil notifyListeners() SEBELUM update cache untuk responsivitas
        debugPrint('🔄 TaskApiService: Triggering IMMEDIATE UI update setelah create task');
        notifyListeners(); // Trigger UI update segera
        
        // Update all related caches secara asinkron di background
        _updateCachesAfterChange().then((_) {
          debugPrint('🗄️ Cache: Background cache update completed');
        }).catchError((e) {
          debugPrint('�️ Cache: Error updating background cache: $e');
        });
        
        // Reset data changed flag setelah local update berhasil
        _dataChanged = false;
        
        debugPrint('�️ Cache: Data task berhasil diperbarui setelah createTask');
        debugPrint('🔄 TaskApiService: notifyListeners() called successfully');
        
        return TaskResult.success(
          task: newTask,
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
        final updatedTask = Task.fromMap(data['data']);
        
        // Update local cache dengan task yang diupdate
        final index = _tasks.indexWhere((task) => task.slug == slug);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
        
        // IMMEDIATE UI UPDATE - panggil notifyListeners() SEBELUM update cache
        debugPrint('🔄 TaskApiService: Triggering IMMEDIATE UI update setelah update task');
        notifyListeners(); // Trigger UI update segera
        
        // Update all related caches secara asinkron di background
        _updateCachesAfterChange().then((_) {
          debugPrint('🗄️ Cache: Background cache update completed after updateTask');
        }).catchError((e) {
          debugPrint('🗄️ Cache: Error updating background cache after updateTask: $e');
        });
        
        // Reset data changed flag setelah local update berhasil
        _dataChanged = false;
        
        debugPrint('🗄️ Cache: Data task berhasil diperbarui setelah updateTask');
        debugPrint('🔄 TaskApiService: Triggering UI update setelah update task');
        // notifyListeners() sudah dipanggil di atas
        
        return TaskResult.success(
          task: updatedTask,
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
      
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Update local cache dengan menghapus task
        _tasks.removeWhere((task) => task.slug == slug);
        
        // IMMEDIATE UI UPDATE - panggil notifyListeners() SEBELUM update cache
        debugPrint('🔄 TaskApiService: Triggering IMMEDIATE UI update setelah delete task');
        notifyListeners(); // Trigger UI update segera
        
        // Update all related caches secara asinkron di background
        _updateCachesAfterChange().then((_) {
          debugPrint('🗄️ Cache: Background cache update completed after deleteTask');
        }).catchError((e) {
          debugPrint('🗄️ Cache: Error updating background cache after deleteTask: $e');
        });
        
        // Reset data changed flag setelah local update berhasil
        _dataChanged = false;
        
        debugPrint('🗄️ Cache: Data task berhasil diperbarui setelah deleteTask');
        // notifyListeners() sudah dipanggil di atas
        
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

  Future<void> fetchTasks({bool forceRefresh = false}) async {
    // Enhanced Debug info
    debugPrint('🗄️ Cache: fetchTasks called with forceRefresh=$forceRefresh, dataChanged=$_dataChanged');
    debugPrint('🗄️ Cache: Current _tasks.length = ${_tasks.length} before fetchTasks');
    
    // Jika _tasks sudah ada data dan tidak ada force refresh, gunakan data lokal
    if (!forceRefresh && _tasks.isNotEmpty) {
      debugPrint('🗄️ Cache: ✅ fetchTasks - Using existing _tasks data, no fetch needed');
      // Tidak perlu fetch, data lokal sudah ter-update
      return;
    }
    
    // Periksa jika cache valid dan data tidak berubah, gunakan cache
    // Skip cache jika forceRefresh = true atau data telah berubah (_dataChanged = true)
    if (!forceRefresh && !_dataChanged && await _cacheService.isCacheValid(_allTasksCacheKey)) {
      try {
        final cachedData = await _cacheService.getData(_allTasksCacheKey);
        if (cachedData != null) {
          final cachedTasks = List<Map<String, dynamic>>.from(cachedData)
              .map((taskMap) => Task.fromMap(taskMap))
              .toList();
          _tasks = cachedTasks;
          _dataChanged = false;
          debugPrint('🗄️ Cache: ⚠️ fetchTasks - Data berhasil diambil dari cache untuk key $_allTasksCacheKey');
          debugPrint('🗄️ Cache: Menggunakan data task dari cache (${_tasks.length} tasks)');
          notifyListeners();
          return;
        }
      } catch (e) {
        debugPrint('🗄️ Cache: Error menggunakan cache untuk tasks: $e');
      }
    }
    
    debugPrint('🗄️ Cache: 🌐 fetchTasks - Mengambil data task dari server (forceRefresh=$forceRefresh, dataChanged=$_dataChanged)');
    _setLoading(true);
    try {
      final tasks = await getAllTasks(forceRefresh: forceRefresh);
      // _tasks sudah di-update di getAllTasks(), tidak perlu assign lagi
      _setError(null);
      _dataChanged = false;
      debugPrint('🗄️ Cache: ✅ fetchTasks completed successfully via getAllTasks (${_tasks.length} tasks)');
    } catch (e) {
      _setError('Gagal mengambil data tugas');
      debugPrint('Error in fetchTasks: $e');
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> fetchTasksToday({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      final tasks = await getTasksToday(forceRefresh: forceRefresh);
      _tasks = tasks;
      _setError(null);
    } catch (e) {
      _setError('Gagal mengambil data tugas hari ini');
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<void> fetchUncompletedTasksToday({bool forceRefresh = false}) async {
    _setLoading(true);
    try {
      final tasks = await getUncompletedTasksToday(forceRefresh: forceRefresh);
      _tasks = tasks;
      _setError(null);
    } catch (e) {
      _setError('Gagal mengambil data tugas yang belum selesai hari ini');
    }
    _setLoading(false);
    notifyListeners();
  }

  Future<List<Task>> getAllTasks({bool forceRefresh = false}) async {
    // Enhanced Debug info
    debugPrint('🗄️ Cache: getAllTasks called with forceRefresh=$forceRefresh, dataChanged=$_dataChanged');
    debugPrint('🗄️ Cache: Current _tasks.length = ${_tasks.length}');
    debugPrint('🗄️ Cache: Current _tasks IDs = ${_tasks.map((t) => t.id).toList()}');
    
    // PRIORITAS 1: Jika _tasks sudah ter-populate dan tidak ada force refresh, gunakan data lokal
    if (!forceRefresh && _tasks.isNotEmpty) {
      debugPrint('🗄️ Cache: ✅ Using PRIORITAS 1 - Returning data from local _tasks (${_tasks.length} tasks)');
      return List<Task>.from(_tasks); // Return copy untuk safety
    }
    
    debugPrint('🗄️ Cache: ❌ PRIORITAS 1 tidak terpenuhi. Checking cache... (forceRefresh=$forceRefresh, _tasks.isEmpty=${_tasks.isEmpty})');
    
    // PRIORITAS 2: Periksa cache jika _tasks kosong dan tidak ada force refresh
    if (!forceRefresh && !_dataChanged && await _cacheService.isCacheValid(_allTasksCacheKey)) {
      try {
        final cachedData = await _cacheService.getData(_allTasksCacheKey);
        if (cachedData != null) {
          final List<Task> cachedTasks = List<Map<String, dynamic>>.from(cachedData)
              .map((taskMap) => Task.fromMap(taskMap))
              .toList();
          
          // Update _tasks dengan data dari cache
          _tasks = cachedTasks;
          debugPrint('🗄️ Cache: ⚠️ Using PRIORITAS 2 - Data berhasil diambil dari cache untuk key $_allTasksCacheKey');
          debugPrint('🗄️ Cache: Berhasil mendapatkan tasks dari cache dan update _tasks (${_tasks.length} tasks)');
          return List<Task>.from(cachedTasks);
        }
      } catch (e) {
        debugPrint('🗄️ Cache: Error mendapatkan tasks dari cache: $e');
      }
    }
    
    // PRIORITAS 3: Fetch dari server jika cache tidak valid atau force refresh
    debugPrint('🗄️ Cache: Mengambil semua task dari server (forceRefresh=$forceRefresh, dataChanged=$_dataChanged)');
    
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
        
        // Simpan ke cache
        final List<Map<String, dynamic>> tasksAsMap = tasksWithAlarms
            .map((task) => task.toMap())
            .toList();
        await _cacheService.saveData(
          key: _allTasksCacheKey, 
          data: tasksAsMap,
          maxAge: _cacheValidityDuration,
        );
        
        // Update _tasks dengan data terbaru dari server
        _tasks = tasksWithAlarms;
        _dataChanged = false; // Reset flag setelah data fresh dari server
        
        debugPrint('🗄️ Cache: Data tersimpan untuk key $_allTasksCacheKey');
        debugPrint('🗄️ Cache: _tasks updated with fresh data from server (${_tasks.length} tasks)');
        return tasksWithAlarms;
      }
    } catch (e) {
      debugPrint('Error in getAllTasks: $e');
      _handleException(e);
    }
    return [];
  }
  Future<List<Task>> getTasksToday({bool forceRefresh = false}) async {
    // Periksa apakah data sudah ada di cache
    // Skip cache jika forceRefresh = true atau data telah berubah (_dataChanged = true)
    if (!forceRefresh && !_dataChanged && await _cacheService.isCacheValid(_todayTasksCacheKey)) {
      try {
        final cachedData = await _cacheService.getData(_todayTasksCacheKey);
        if (cachedData != null) {
          final List<Task> cachedTasks = List<Map<String, dynamic>>.from(cachedData)
              .map((taskMap) => Task.fromMap(taskMap))
              .toList();
          debugPrint('🗄️ Cache: Berhasil mendapatkan tasks hari ini dari cache');
          return cachedTasks;
        }
      } catch (e) {
        debugPrint('🗄️ Cache: Error mendapatkan tasks hari ini dari cache: $e');
      }
    }
    
    debugPrint('🗄️ Cache: Mengambil tasks hari ini dari server (forceRefresh=$forceRefresh)');
    
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
        
        // Simpan ke cache
        final List<Map<String, dynamic>> tasksAsMap = tasksWithAlarms
            .map((task) => task.toMap())
            .toList();
        await _cacheService.saveData(
          key: _todayTasksCacheKey, 
          data: tasksAsMap,
          maxAge: _cacheValidityDuration,
        );
        
        return tasksWithAlarms;
      }
    } catch (e) {
      debugPrint('Error in getTasksToday: $e');
      _handleException(e);
    }
    return [];
  }

  Future<List<Task>> getUncompletedTasksToday({bool forceRefresh = false}) async {
    // Periksa apakah data sudah ada di cache
    // Skip cache jika forceRefresh = true atau data telah berubah (_dataChanged = true)
    if (!forceRefresh && !_dataChanged && await _cacheService.isCacheValid(_uncompletedTodayCacheKey)) {
      try {
        final cachedData = await _cacheService.getData(_uncompletedTodayCacheKey);
        if (cachedData != null) {
          final List<Task> cachedTasks = List<Map<String, dynamic>>.from(cachedData)
              .map((taskMap) => Task.fromMap(taskMap))
              .toList();
          debugPrint('🗄️ Cache: Berhasil mendapatkan tasks belum selesai hari ini dari cache');
          return cachedTasks;
        }
      } catch (e) {
        debugPrint('🗄️ Cache: Error mendapatkan tasks belum selesai hari ini dari cache: $e');
      }
    }
    
    debugPrint('🗄️ Cache: Mengambil tasks belum selesai hari ini dari server (forceRefresh=$forceRefresh)');
    
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
        
        // Simpan ke cache
        final List<Map<String, dynamic>> tasksAsMap = tasksWithAlarms
            .map((task) => task.toMap())
            .toList();
        await _cacheService.saveData(
          key: _uncompletedTodayCacheKey, 
          data: tasksAsMap,
          maxAge: _cacheValidityDuration,
        );
        
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

  Future<Map<String, dynamic>?> countLateTasks({bool forceRefresh = false}) async {
    // Debug info
    debugPrint('🗄️ Cache: countLateTasks called with forceRefresh=$forceRefresh, dataChanged=$_dataChanged');
    
    // Periksa apakah data sudah ada di cache
    // Skip cache jika forceRefresh = true atau data telah berubah (_dataChanged = true)
    if (!forceRefresh && !_dataChanged && await _cacheService.isCacheValid(_lateTasksCountCacheKey)) {
      try {
        final cachedData = await _cacheService.getData(_lateTasksCountCacheKey);
        if (cachedData != null) {
          debugPrint('🗄️ Cache: Data berhasil diambil dari cache untuk key $_lateTasksCountCacheKey');
          debugPrint('🗄️ Cache: Berhasil mendapatkan jumlah tasks terlambat dari cache');
          return cachedData as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('🗄️ Cache: Error mendapatkan jumlah tasks terlambat dari cache: $e');
      }
    }
    
    debugPrint('🗄️ Cache: Mengambil count late tasks dari server (forceRefresh=$forceRefresh, dataChanged=$_dataChanged)');
    
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
        // Simpan ke cache
        await _cacheService.saveData(
          key: _lateTasksCountCacheKey, 
          data: data['data'],
          maxAge: _cacheValidityDuration,
        );
        debugPrint('🗄️ Cache: Data tersimpan untuk key $_lateTasksCountCacheKey');
        return data['data'];
      }
    } catch (e) {
      _handleException(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getTasksByStatus(String status) async {
    // Periksa apakah data sudah ada di cache
    final cacheKey = '${_tasksByStatusCacheKey}$status';
    if (!_dataChanged && await _cacheService.isCacheValid(cacheKey)) {
      try {
        final cachedData = await _cacheService.getData(cacheKey);
        if (cachedData != null) {
          debugPrint('🗄️ Cache: Berhasil mendapatkan tasks dengan status $status dari cache');
          return cachedData as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('🗄️ Cache: Error mendapatkan tasks dengan status $status dari cache: $e');
      }
    }
    
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/tasks/dashboard/by-status',
      ).replace(queryParameters: {'status': status});
      final response = await http.get(uri, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Simpan ke cache
        await _cacheService.saveData(
          key: cacheKey, 
          data: data['data'],
          maxAge: _cacheValidityDuration,
        );
        return data['data'];
      }
    } catch (e) {
      _handleException(e);
    }
    return null;
  }

  /// Memaksa pembaruan UI dengan memancarkan notifikasi listener
  void forceRefreshUI() {
    debugPrint('🔄 TaskApiService: Memaksa pembaruan UI');
    notifyListeners();
  }
  
  /// Memaksa pembaruan data dan UI hanya jika diperlukan
  Future<void> refreshDataAndUI({bool force = false}) async {
    debugPrint('🔄 TaskApiService: Menyegarkan data dan UI (force=$force)');
    if (force) {
      await fetchTasks(forceRefresh: true);
    } else {
      await fetchTasks(forceRefresh: false);
    }
    notifyListeners();
  }
  
  /// Method untuk update task status tanpa full refresh
  void updateTaskStatusLocally(String slug, String newStatus) {
    final index = _tasks.indexWhere((task) => task.slug == slug);
    if (index != -1) {
      // Update task locally for immediate UI feedback
      _tasks[index] = _tasks[index].copyWith(
        taskStatus: TaskDatabaseStatus.values.firstWhere(
          (status) => status.value == newStatus,
          orElse: () => TaskDatabaseStatus.belumSelesai,
        ),
      );
      notifyListeners();
      
      // Update caches asynchronously
      _updateCachesAfterChange();
    }
  }
  
  /// Method untuk menambah task baru secara lokal
  void addTaskLocally(Task task) {
    _tasks.add(task);
    notifyListeners();
    _updateCachesAfterChange();
  }
  
  /// Method untuk remove task secara lokal
  void removeTaskLocally(String slug) {
    _tasks.removeWhere((task) => task.slug == slug);
    notifyListeners();
    _updateCachesAfterChange();
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
