// import '../../task/models/task.dart';
// import '../../task/ui/screens/categories.dart';

// class TaskService {
//   // Mock data storage
//   static List<Task> _mockTasks = [];
  
//   // Initialize with dummy data
//   static void initializeDummyData() {
//     if (_mockTasks.isNotEmpty) return; // Already initialized
    
//     final now = DateTime.now();
    
//     _mockTasks = [
//       // Tasks for today
//       Task(
//         id: '1',
//         title: 'Presentasi Proyek',
//         description: 'Menyiapkan dan mempresentasikan hasil proyek aplikasi mobile kepada tim dan stakeholder. Pastikan semua fitur sudah berfungsi dengan baik.',
//         deadline: DateTime(now.year, now.month, now.day, 14, 30),
//         estimatedDuration: const Duration(hours: 2),
//         category: 'Pekerjaan',
//         isAlarmEnabled: true,
//         alarmDateTime: DateTime(now.year, now.month, now.day, 13, 30),
//         isCompleted: false,
//       ),
//       Task(
//         id: '2',
//         title: 'Beli Groceries',
//         description: 'Membeli kebutuhan sehari-hari: beras, minyak goreng, sayuran, buah-buahan, dan susu.',
//         deadline: DateTime(now.year, now.month, now.day, 18, 0),
//         estimatedDuration: const Duration(hours: 1, minutes: 30),
//         category: 'Pribadi',
//         isAlarmEnabled: true,
//         alarmDateTime: DateTime(now.year, now.month, now.day, 17, 0),
//         isCompleted: false,
//       ),
//       Task(
//         id: '3',
//         title: 'Olahraga Pagi',
//         description: null,
//         deadline: DateTime(now.year, now.month, now.day, 7, 0),
//         estimatedDuration: const Duration(minutes: 45),
//         category: 'Kesehatan',
//         isAlarmEnabled: true,
//         alarmDateTime: DateTime(now.year, now.month, now.day, 6, 30),
//         isCompleted: true,
//       ),
      
//       // Tasks for tomorrow
//       Task(
//         id: '4',
//         title: 'Meeting Client',
//         description: 'Diskusi requirement baru untuk proyek website e-commerce. Persiapkan proposal dan timeline pengerjaan.',
//         deadline: DateTime(now.year, now.month, now.day + 1, 10, 0),
//         estimatedDuration: const Duration(hours: 1),
//         category: 'Pekerjaan',
//         isAlarmEnabled: true,
//         alarmDateTime: DateTime(now.year, now.month, now.day + 1, 9, 30),
//         isCompleted: false,
//       ),
//       Task(
//         id: '5',
//         title: 'Belajar Flutter',
//         description: 'Melanjutkan tutorial state management dengan Provider dan mempraktikkan implementasi pada project pribadi.',
//         deadline: DateTime(now.year, now.month, now.day + 1, 20, 0),
//         estimatedDuration: const Duration(hours: 2),
//         category: 'Pendidikan',
//         isAlarmEnabled: false,
//         alarmDateTime: null,
//         isCompleted: false,
//       ),
      
//       // Tasks for day after tomorrow
//       Task(
//         id: '6',
//         title: 'Dokter Gigi',
//         description: 'Kontrol rutin dan pembersihan karang gigi. Jangan lupa bawa kartu BPJS.',
//         deadline: DateTime(now.year, now.month, now.day + 2, 15, 30),
//         estimatedDuration: const Duration(hours: 1),
//         category: 'Kesehatan',
//         isAlarmEnabled: true,
//         alarmDateTime: DateTime(now.year, now.month, now.day + 2, 14, 30),
//         isCompleted: false,
//       ),
//       Task(
//         id: '7',
//         title: 'Deadline Tugas Kuliah',
//         description: 'Menyelesaikan tugas akhir mata kuliah Pemrograman Mobile. Pastikan semua requirement sudah terpenuhi dan dokumentasi lengkap.',
//         deadline: DateTime(now.year, now.month, now.day + 2, 23, 59),
//         estimatedDuration: const Duration(hours: 4),
//         category: 'Pendidikan',
//         isAlarmEnabled: true,
//         alarmDateTime: DateTime(now.year, now.month, now.day + 2, 19, 0),
//         isCompleted: false,
//       ),
      
//       // Tasks for next week
//       Task(
//         id: '8',
//         title: 'Liburan Keluarga',
//         description: 'Trip ke Bandung bersama keluarga. Sudah booking hotel dan tiket kereta. Jangan lupa siapkan kamera dan powerbank.',
//         deadline: DateTime(now.year, now.month, now.day + 7, 8, 0),
//         estimatedDuration: const Duration(days: 2),
//         category: 'Pribadi',
//         isAlarmEnabled: true,
//         alarmDateTime: DateTime(now.year, now.month, now.day + 6, 20, 0),
//         isCompleted: false,
//       ),
//       Task(
//         id: '9',
//         title: 'Review Code',
//         description: 'Melakukan code review untuk pull request dari tim developer. Fokus pada performance dan security.',
//         deadline: DateTime(now.year, now.month, now.day + 7, 16, 0),
//         estimatedDuration: const Duration(hours: 2),
//         category: 'Pekerjaan',
//         isAlarmEnabled: false,
//         alarmDateTime: null,
//         isCompleted: false,
//       ),
      
//       // Some overdue tasks
//       Task(
//         id: '10',
//         title: 'Bayar Tagihan Listrik',
//         description: 'Tagihan bulan ini sudah keluar, jangan sampai terlambat bayar.',
//         deadline: DateTime(now.year, now.month, now.day - 1, 17, 0),
//         estimatedDuration: const Duration(minutes: 30),
//         category: 'Pribadi',
//         isAlarmEnabled: false,
//         alarmDateTime: null,
//         isCompleted: false,
//       ),
//       Task(
//         id: '11',
//         title: 'Submit Report',
//         description: null,
//         deadline: DateTime(now.year, now.month, now.day - 2, 12, 0),
//         estimatedDuration: const Duration(hours: 1),
//         category: 'Pekerjaan',
//         isAlarmEnabled: false,
//         alarmDateTime: null,
//         isCompleted: false,
//       ),
//     ];
//   }
  
//   /// Get tasks by specific date (deadline on that date)
//   Future<List<Task>> getTasksByDate(DateTime date) async {
//     // Initialize dummy data if not already done
//     initializeDummyData();
    
//     try {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 500));
      
//       // Normalize the date to start and end of day for comparison
//       final startOfDay = DateTime(date.year, date.month, date.day);
//       final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
//       final filteredTasks = _mockTasks.where((task) {
//         return task.deadline.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
//                task.deadline.isBefore(endOfDay.add(const Duration(seconds: 1)));
//       }).toList();
      
//       // Sort by deadline time
//       filteredTasks.sort((a, b) => a.deadline.compareTo(b.deadline));
      
//       return filteredTasks;
//     } catch (e) {
//       throw Exception('Failed to load tasks for date: $e');
//     }
//   }
  
//   /// Mark task as complete
//   Future<void> markTaskComplete(String taskId) async {
//     try {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 300));
      
//       final taskIndex = _mockTasks.indexWhere((task) => task.id == taskId);
//       if (taskIndex != -1) {
//         _mockTasks[taskIndex] = _mockTasks[taskIndex].copyWith(isCompleted: true);
//       }
//     } catch (e) {
//       throw Exception('Failed to mark task as complete: $e');
//     }
//   }
  
//   /// Delete task
//   Future<void> deleteTask(String taskId) async {
//     try {
//       // Simulate network delay
//       await Future.delayed(const Duration(milliseconds: 300));
      
//       _mockTasks.removeWhere((task) => task.id == taskId);
//     } catch (e) {
//       throw Exception('Failed to delete task: $e');
//     }
//   }
  
//   /// Get all tasks
//   Future<List<Task>> getAllTasks() async {
//     initializeDummyData();
//     await Future.delayed(const Duration(milliseconds: 300));
//     return List.from(_mockTasks);
//   }
  
//   /// Add new task
//   Future<void> addTask(Task task) async {
//     try {
//       await Future.delayed(const Duration(milliseconds: 300));
      
//       final newTask = task.copyWith(
//         id: DateTime.now().millisecondsSinceEpoch.toString(),
//       );
//       _mockTasks.add(newTask);
//     } catch (e) {
//       throw Exception('Failed to add task: $e');
//     }
//   }
  
//   /// Update existing task
//   Future<void> updateTask(Task task) async {
//     try {
//       await Future.delayed(const Duration(milliseconds: 300));
      
//       final taskIndex = _mockTasks.indexWhere((t) => t.id == task.id);
//       if (taskIndex != -1) {
//         _mockTasks[taskIndex] = task;
//       }
//     } catch (e) {
//       throw Exception('Failed to update task: $e');
//     }
//   }
  
//   /// Get tasks summary for calendar
//   Future<Map<DateTime, List<Task>>> getTasksGroupedByDate() async {
//     initializeDummyData();
//     await Future.delayed(const Duration(milliseconds: 300));
    
//     final Map<DateTime, List<Task>> groupedTasks = {};
    
//     for (final task in _mockTasks) {
//       final dateKey = DateTime(
//         task.deadline.year,
//         task.deadline.month,
//         task.deadline.day,
//       );
      
//       if (groupedTasks[dateKey] == null) {
//         groupedTasks[dateKey] = [];
//       }
//       groupedTasks[dateKey]!.add(task);
//     }
    
//     return groupedTasks;
//   }
  
//   // Existing validation methods...
//   String? validateTitle(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Judul tugas tidak boleh kosong';
//     }
//     if (value.trim().length > 20) {
//       return 'Judul tugas maksimal 20 karakter';
//     }
//     return null;
//   }
  
//   String? validateDeadline(DateTime? deadline) {
//     if (deadline == null) {
//       return 'Deadline harus dipilih';
//     }
//     if (deadline.isBefore(DateTime.now())) {
//       return 'Deadline tidak boleh di masa lalu';
//     }
//     return null;
//   }
  
//   String? validateDuration(Duration? duration) {
//     if (duration == null) {
//       return 'Estimasi waktu harus dipilih';
//     }
//     if (duration.inMinutes < 15) {
//       return 'Estimasi waktu minimal 15 menit';
//     }
//     return null;
//   }
  
//   String? validateCategory(dynamic category) {
//     if (category == null) {
//       return 'Kategori harus dipilih';
//     }
//     return null;
//   }
  
//   String? validateAlarm(DateTime? deadline, DateTime? alarmDateTime) {
//     if (deadline == null || alarmDateTime == null) return null;
    
//     if (alarmDateTime.isAfter(deadline)) {
//       return 'Waktu alarm tidak boleh melebihi deadline';
//     }
    
//     final minAlarmTime = deadline.subtract(const Duration(hours: 1));
//     if (alarmDateTime.isAfter(minAlarmTime)) {
//       return 'Alarm harus diatur minimal 1 jam sebelum deadline';
//     }
    
//     return null;
//   }
  
//   bool isDeadlineValid(DateTime? deadline) {
//     if (deadline == null) return false;
//     final now = DateTime.now();
//     final oneHourFromNow = now.add(const Duration(hours: 1));
//     return deadline.isAfter(oneHourFromNow);
//   }
  
//   void handleSaveForm({
//     required GlobalKey<FormState> formKey,
//     required Task task,
//     required bool isEdit,
//     required VoidCallback onSuccess,
//     required Function(String) onError,
//   }) async {
//     try {
//       if (isEdit) {
//         await updateTask(task);
//       } else {
//         await addTask(task);
//       }
//       onSuccess();
//     } catch (e) {
//       onError('Gagal menyimpan tugas: $e');
//     }
//   }
// }
