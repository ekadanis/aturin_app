import 'dart:async';

import 'package:flutter/material.dart';
import '../database/task_database.dart';
import '../model/task_model.dart';
import '../../../features/alarm/services/alarm_service.dart';

class TaskService extends ChangeNotifier {
  final taskDatabase = TaskDatabase();
  final alarmService = AlarmService();
  Timer? _statusChecker;
  List<Task> _tasks = [];

  final Map<String, List<Task>> _cachedFilteredTasks = {};
  DateTime _lastFetchTime = DateTime(1970);

  List<Task> get tasks => _tasks;

  // Fetch all tasks from the database
  Future<void> fetchTasks() async {
    final now = DateTime.now();
    if (now.difference(_lastFetchTime).inSeconds < 2 && _tasks.isNotEmpty) {
      debugPrint(
        'Using cached tasks (fetched ${now.difference(_lastFetchTime).inSeconds}s ago)',
      );
      return;
    }
    final result = await taskDatabase.queryAllWithRelations();
    _tasks = result.map((row) => Task.fromMapWithRelations(row)).toList();

    _lastFetchTime = now;

    _cachedFilteredTasks.clear();
    await _checkAndUpdateStatuses();
    notifyListeners();
  }

  // Get tasks filtered by the selected filter
  List<Task> getTasksByFilter(String filter) {
    if (_cachedFilteredTasks.containsKey(filter)) {
      return _cachedFilteredTasks[filter]!;
    }

    List<Task> filteredTasks;

    switch (filter) {
      case 'Terlambat':
        filteredTasks =
            _tasks
                .where(
                  (task) => task.status == TaskStatus.late && !task.isCompleted,
                )
                .toList();
        break;
      case 'Belum Selesai':
        filteredTasks =
            _tasks
                .where(
                  (task) => !task.isCompleted && task.status != TaskStatus.late,
                )
                .toList()
              ..sort((a, b) => a.deadline.compareTo(b.deadline));
        break;
      case 'Selesai':
        filteredTasks = _tasks.where((task) => task.isCompleted).toList();
        break;
      case 'Semua':
      default:
        final order = [
          TaskStatus.late,
          TaskStatus.today,
          TaskStatus.tomorrow,
          TaskStatus.upcoming,
          TaskStatus.completed,
        ];

        // Urutkan: belum selesai dulu, lalu yang sudah selesai
        filteredTasks = List<Task>.from(_tasks)..sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          return order.indexOf(a.status).compareTo(order.indexOf(b.status));
        });
    }

    _cachedFilteredTasks[filter] = filteredTasks;
    return filteredTasks;
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(int? id) async {
    if (id == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final now = DateTime.now();      final updatedTask = task.copyWith(
        userId: task.userId, // Preserve userId
        taskStatus:
            task.isCompleted
                ? TaskDatabaseStatus.belumSelesai
                : TaskDatabaseStatus.selesai,
        completedAt: !task.isCompleted ? now : null,
      );

      await taskDatabase.update(updatedTask.toMap());
      _tasks[index] = updatedTask;

      _cachedFilteredTasks.clear();

      notifyListeners();
    }
  }

  // Toggle alarm status
  Future<void> toggleAlarm(int? id) async {
    if (id == null) return;

    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final task = _tasks[index];      // If task has alarm, toggle it off by removing alarm relationship
      // If task has no alarm, would need to create one (requires AlarmService integration)
      final updatedTask = task.copyWith(
        userId: task.userId, // Preserve userId
        alarmId:
            task.alarmId != null
                ? null
                : task.alarmId, // Toggle alarm relationship
        alarm: task.alarm != null ? null : task.alarm, // Toggle alarm object
      );

      await taskDatabase.update(updatedTask.toMap());
      _tasks[index] = updatedTask;
      notifyListeners();
    }
  }

  // Get all tasks
  Future<List<Task>> getAllTasks() async {
    final result = await taskDatabase.queryAll();
    _tasks = result.map((row) => Task.fromMap(row)).toList();
    notifyListeners();
    return _tasks;
  }

  // Get task by ID
  Future<Task?> getTaskById(int id) async {
    final row = await taskDatabase.queryById(id);
    if (row != null) {
      return Task.fromMap(row);
    }
    return null;
  }
  // Add a new task
  Future<int> addTask(Task task) async {
    try {
      // Generate slug from title
      final slug = _generateSlug(task.title);
      
      // Set default userId (assuming user with ID 1 exists from seeder)
      final userId = task.userId ?? 1;
      
      // Set timestamps
      final now = DateTime.now();
      
      int? alarmId;
      
      // Handle alarm creation if enabled
      if (task.alarm != null && task.alarm!.alarmEnabled) {
        // Insert alarm first to get alarm ID
        final alarmData = task.alarm!.copyWith(
          slug: 'task-alarm-${DateTime.now().millisecondsSinceEpoch}',
          createdAt: now,
          updatedAt: now,
        );
        
        final db = await taskDatabase.databaseHelper.database;
        alarmId = await db.insert('alarms', alarmData.toMap());
        debugPrint('Alarm created with ID: $alarmId');
      }
      
      // Create updated task with all required fields
      final updatedTask = task.copyWith(
        userId: userId,
        slug: slug,
        alarmId: alarmId,
        createdAt: now,
        updatedAt: now,
      );
      
      // Insert task to database
      final id = await taskDatabase.insert(updatedTask.toMap());
      debugPrint('Task created with ID: $id');
      final finalTask = updatedTask.copyWith(id: id);
      if (finalTask.isAlarmEnabled && finalTask.alarmDateTime != null) {
        await alarmService.setAlarm(
          id,
          finalTask.alarmDateTime!,
          'Tugas: ${finalTask.title}',
          'Deadline: ${finalTask.deadline.toString()}',
        );
      }

      await fetchTasks();
      return id;
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }
  
  // Generate slug from title
  String _generateSlug(String title) {
    return 'task-' + title
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'-+'), '-') // Replace multiple dashes with single dash
        .replaceAll(RegExp(r'^-|-$'), ''); // Remove leading/trailing dashes
  }  // Update an existing task
  Future<int> updateTask(Task task) async {
    try {
      debugPrint('DEBUG: updateTask called with task.userId = ${task.userId}');
      
      // Validasi alarm sebelum update
      Task updatedTask = task;

      // Generate slug if title changed or slug is missing
      final slug = task.slug ?? _generateSlug(task.title);
      
      // Set timestamps
      final now = DateTime.now();// Jika task memiliki alarm, validasi deadline dan waktu alarm
      if (task.alarm != null && task.alarm!.alarmEnabled) {
        // Cek apakah deadline valid (minimal 1 jam dari sekarang)
        if (!isDeadlineValid(task.deadline)) {
          // Jika tidak valid, nonaktifkan alarm dengan menghapus relasi alarm
          updatedTask = task.copyWith(
            userId: task.userId, // Preserve userId
            alarmId: null, 
            alarm: null,
          );
          debugPrint('Alarm dinonaktifkan karena deadline terlalu dekat');
        }
        // Cek apakah alarm setidaknya 1 jam sebelum deadline
        else if (task.alarm!.alarmDateTime.isAfter(
          task.deadline.subtract(Duration(hours: 1)),
        )) {
          // Jika alarm terlalu dekat dengan deadline, sesuaikan waktunya
          final safeAlarmTime = task.deadline.subtract(Duration(hours: 1));
          final updatedAlarm = task.alarm!.copyWith(alarmDateTime: safeAlarmTime);
          updatedTask = task.copyWith(
            userId: task.userId, // Preserve userId
            alarm: updatedAlarm,
          );
          debugPrint('Alarm disesuaikan ke 1 jam sebelum deadline');
        }
      }      // Update task with slug and timestamp
      updatedTask = updatedTask.copyWith(
        userId: task.userId, // Preserve userId
        slug: slug,
        updatedAt: now,
      );
      
      debugPrint('DEBUG: Before database update, updatedTask.userId = ${updatedTask.userId}');
      debugPrint('DEBUG: updatedTask.toMap() = ${updatedTask.toMap()}');
        final result = await taskDatabase.update(updatedTask.toMap());
      
      // Use the original task for alarm management since it has the same ID
      final hasExistingAlarm = await alarmService.hasAlarm(task.id!);      if (hasExistingAlarm) {
        await alarmService.cancelAlarm(task.id!);
      }

      // Set new alarm if enabled
      if (updatedTask.isAlarmEnabled && updatedTask.alarmDateTime != null) {
        await alarmService.setAlarm(
          updatedTask.id!,
          updatedTask.alarmDateTime!,
          'Tugas: ${updatedTask.title}',
          'Deadline: ${updatedTask.deadline.toString()}',
        );
      }

      await fetchTasks(); // Refresh the task list
      return result;
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  // Delete a task
  Future<int> deleteTask(int? id) async {
    if (id == null) {
      debugPrint('Gagal menghapus: ID task adalah null');
      return 0;
    }

    try {      // Coba hapus alarm terlebih dahulu dengan penanganan error
      try {
        await alarmService.cancelAlarm(id);
        debugPrint('Alarm untuk task $id berhasil dihapus');
      } catch (e) {
        // Jika gagal menghapus alarm, tetap lanjutkan proses penghapusan task
        debugPrint('Gagal menghapus alarm untuk task $id: $e');
      }

      // Pastikan database melakukan penghapusan dengan benar
      final result = await taskDatabase.delete(id);
      debugPrint('Task dengan ID $id berhasil dihapus dari database: $result');

      if (result <= 0) {
        debugPrint(
          'Database mengembalikan hasil $result untuk penghapusan task $id',
        );
        throw Exception('Database gagal menghapus task');
      }

      // Perbarui cache dan UI
      _cachedFilteredTasks.clear();
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();

      // Fetch ulang task untuk memastikan data konsisten
      await fetchTasks();

      return result;
    } catch (e) {
      debugPrint('Error fatal saat menghapus task: $e');
      // Re-fetch tasks untuk memastikan tampilan konsisten dengan database
      await fetchTasks();
      rethrow; // Lempar kembali error untuk ditangani di UI
    }
  }

  // Clear all tasks
  Future<void> clearAllTasks() async {
    await taskDatabase.deleteAll();
    await fetchTasks(); // Refresh the task list
  }

  String? validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Judul wajib diisi';
    if (trimmed.length > 20) return 'Judul maksimal 20 karakter';
    return null;
  }

  String? validateDeadline(DateTime? deadline) {
    if (deadline == null) return 'Batas waktu wajib diisi';
    return null;
  }

  String? validateDuration(Duration? duration) {
    if (duration == null) return 'Estimasi waktu wajib diisi';
    return null;
  }

  String? validateCategory(dynamic category) {
    if (category == null) return 'Kategori wajib diisi';
    return null;
  }

  String? validateAlarm(DateTime? deadline, DateTime? alarm) {
    if (alarm == null) return 'Waktu alarm wajib diisi';
    if (deadline != null && alarm.isAfter(deadline)) {
      return 'Alarm harus sebelum deadline';
    }
    return null;
  }

  bool canEnableAlarm(DateTime? deadline) {
    return deadline != null &&
        deadline.isAfter(DateTime.now().add(Duration(hours: 1)));
  }

  bool isDeadlineValid(DateTime? deadline) {
    return deadline != null &&
        deadline.isAfter(DateTime.now().add(Duration(hours: 1)));
  }

  // Fungsi untuk memeriksa apakah waktu alarm masih valid (belum terlewati)
  bool isAlarmValid(DateTime? deadline) {
    if (deadline == null) return false;

    // Waktu alarm adalah 1 jam sebelum deadline
    final alarmTime = deadline.subtract(Duration(hours: 1));

    // Jika waktu sekarang sudah melewati waktu alarm, return false
    return alarmTime.isAfter(DateTime.now());
  }

  // Fungsi baru: Memeriksa apakah waktu alarm masih valid (belum terlewati oleh waktu sekarang)
  bool isAlarmTimeValid(DateTime? deadline) {
    if (deadline == null) return false;
    // Alarm diatur 1 jam sebelum deadline, jadi kita periksa apakah (deadline - 1 jam) masih di masa depan
    final alarmTime = deadline.subtract(const Duration(hours: 1));
    return alarmTime.isAfter(DateTime.now());
  }

  bool _isStatusCheckerStarted = false;

  Future<void> saveTaskForm({required bool isEdit, required Task task}) async {
    if (isEdit) {
      await updateTask(task);
    } else {
      await addTask(task);
    }
  }

  Future<void> handleSaveForm({
    required GlobalKey<FormState> formKey,
    required Task task,
    required bool isEdit,
    required VoidCallback onSuccess,
    required void Function(String message) onError,
  }) async {
    if (!formKey.currentState!.validate()) return;

    try {
      await saveTaskForm(isEdit: isEdit, task: task);
      onSuccess();
    } catch (e) {
      onError('Gagal menyimpan tugas');
    }
  }

  void startStatusChecker() {
    if (_isStatusCheckerStarted) return;
    _isStatusCheckerStarted = true;

    _statusChecker = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkAndUpdateStatuses();
    });
  }

  Future<void> _checkAndUpdateStatuses() async {
    bool updated = false;

    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];

      // Check if task is overdue and not completed
      if (!task.isCompleted && task.deadline.isBefore(DateTime.now())) {        // Mark as late if not already
        if (task.taskStatus != TaskDatabaseStatus.terlambat) {
          final updatedTask = task.copyWith(
            userId: task.userId, // Preserve userId
            taskStatus: TaskDatabaseStatus.terlambat,
          );
          await taskDatabase.update(updatedTask.toMap());
          _tasks[i] = updatedTask;
          updated = true;
        }
      }
    }

    if (updated) notifyListeners();
  }

  // Menonaktifkan semua alarm
  Future<void> disableAllAlarms() async {
    try {
      final activeAlarms = await alarmService.getActiveAlarms();
      bool changes = false;      for (var alarm in activeAlarms) {
        await alarmService.cancelAlarm(alarm.id);
        changes = true;
      }

      if (changes) {
        final result = await taskDatabase.queryAll();
        _tasks = result.map((row) => Task.fromMap(row)).toList();
        _cachedFilteredTasks.clear();
        notifyListeners();
      }

      debugPrint('Semua alarm berhasil dinonaktifkan');
    } catch (e) {
      debugPrint('Error saat menonaktifkan semua alarm: $e');
    }
  }

  Future<void> enableAllAlarms() async {
    try {
      final result = await taskDatabase.queryAll();
      final tasks = result.map((row) => Task.fromMap(row)).toList();

      int count = 0;
      bool changes = false;      for (var task in tasks) {
        if (task.isAlarmEnabled &&
            task.alarmDateTime != null &&
            task.alarmDateTime!.isAfter(DateTime.now())) {
          await alarmService.setAlarm(
            task.id!,
            task.alarmDateTime!,
            'Tugas: ${task.title}',
            'Batas waktu : ${task.deadline.toString()}',
          );
          count++;
          changes = true;
        }
      }

      // Refresh tugas setelah perubahan dan beri notifikasi hanya sekali
      if (changes) {
        _tasks = tasks;
        _cachedFilteredTasks.clear();
        notifyListeners();
      }

      debugPrint('Berhasil mengaktifkan kembali $count alarm');
    } catch (e) {
      debugPrint('Error saat mengaktifkan kembali alarm: $e');
    }
  }

  // Clear cache and force refresh
  Future<void> forceRefresh() async {
    _cachedFilteredTasks.clear();
    _lastFetchTime = DateTime(1970); // Reset last fetch time
    await fetchTasks();
  }

  @override
  void dispose() {
    // Bersihkan timer saat provider di-dispose untuk mencegah memory leak
    _statusChecker?.cancel();
    _statusChecker = null;
    _isStatusCheckerStarted = false;
    super.dispose();
  }
}
