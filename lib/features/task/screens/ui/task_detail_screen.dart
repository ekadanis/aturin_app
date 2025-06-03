// import 'package:aturin_app/features/task/screens/ui/add_task_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../model/task_model.dart';
// import '../../../../../../core/theme/app_theme.dart';
// import 'package:auto_route/auto_route.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:aturin_app/core/services/api/task/task_api_service.dart';
// import 'package:aturin_app/core/utils/category_helper.dart';

// @RoutePage()
// class TaskDetailScreen extends StatefulWidget {
//   final Task task;

//   const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

//   @override
//   State<TaskDetailScreen> createState() => _TaskDetailScreenState();
// }

// class _TaskDetailScreenState extends State<TaskDetailScreen> {
//   late Task _task;

//   @override
//   void initState() {
//     super.initState();
//     _task = widget.task;
//   }

//   String _formatDateTime(DateTime dateTime) {
//     final formatter = DateFormat('HH:mm, EEEE, d MMMM y', 'id_ID');
//     return formatter.format(dateTime);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.lightBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: AppTheme.lightBackgroundColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppTheme.lightTextColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Detail Tugas',
//           style: TextStyle(
//             color: AppTheme.lightTextColor,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: false,
//         actions: [
//           if (_task.taskStatus != TaskDatabaseStatus.selesai) // hanya tampil jika belum selesai
//             IconButton(
//               icon: SvgPicture.asset(
//                 'assets/icons/edit.svg',
//                 width: 20,
//                 height: 20,
//                 color: Colors.black,
//               ),
//               onPressed: () async {
//                 final result = await Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => AddTaskScreen(existingTask: _task),
//                   ),
//                 );

//                 if (result == true) {
//                   final updatedTask = _task.slug != null
//                       ? await TaskApiService().getTaskBySlug(_task.slug!)
//                       : null;
//                   if (updatedTask != null) {
//                     setState(() {
//                       _task = updatedTask;
//                     });
//                     Navigator.pop(context, true);
//                   }
//                 }
//               },
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailField('Nama Tugas', _task.title),
//             const SizedBox(height: 16),
//             _buildDetailField(
//               'Deskripsi',
//               (_task.description != null && _task.description!.isNotEmpty)
//                   ? _task.description!
//                   : 'Tidak ada deskripsi',
//             ),
//             const SizedBox(height: 16),            _buildDetailField(
//               'Kategori Tugas',
//               CategoryHelper.getCategoryOptionFromString(_task.category).name,
//             ),
//             const SizedBox(height: 16),
//             _buildDetailField(
//               'Estimasi Pengerjaan(Jam)',
//               _formatDurationToHourDotMinute(_task.estimatedDuration),
//             ),
//             const SizedBox(height: 16),
//             _buildDetailField('Batas Waktu', _formatDateTime(_task.deadline)),
//             const SizedBox(height: 16),
//             _buildDetailField(
//               'Pengingat',
//               _task.alarm != null
//                   ? _formatDateTime(_task.alarm!.alarmDateTime)
//                   : 'Tidak diatur',
//             ),
//             const SizedBox(height: 16),
//             _buildDetailField(
//               'Diselesaikan pada',
//               _task.taskStatus == TaskDatabaseStatus.selesai &&
//                       _task.completedAt != null
//                   ? _formatDateTime(_task.completedAt!)
//                   : 'Belum diselesaikan',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailField(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: AppTheme.lightTextColor,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: AppTheme.lightDividerColor),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Text(
//             value,
//             style: const TextStyle(
//               fontSize: 16,
//               color: AppTheme.lightTextColor,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//   String _formatDurationToHourDotMinute(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes % 60;

//     final minutesStr = minutes.toString().padLeft(2, '0');
//     return '$hours.$minutesStr';
//   }
// }
