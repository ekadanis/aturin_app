// import 'package:flutter/foundation.dart';
// import 'package:aturin_app/features/task/services/task_services.dart';
// import 'package:aturin_app/features/home/services/home_service.dart' as home;

// /// Bridge yang menghubungkan TaskService utama dengan home.TaskService
// /// untuk memastikan konsistensi data di seluruh aplikasi
// class TaskServiceBridge {
//   final TaskService taskService;
//   final home.TaskService homeTaskService;

//   TaskServiceBridge(this.taskService, this.homeTaskService) {
//     _setupListeners();
//   }

//   void _setupListeners() {
//     taskService.addListener(_onTaskServiceChanged);
//   }

//   void _onTaskServiceChanged() {
//     homeTaskService.fetchTasks();
//   }

//   Future<void> syncServices() async {
//     await taskService.fetchTasks();
//     await homeTaskService.fetchTasks();
//   }

//   // Metode untuk membersihkan resource
//   void dispose() {
//     taskService.removeListener(_onTaskServiceChanged);
//   }
// }