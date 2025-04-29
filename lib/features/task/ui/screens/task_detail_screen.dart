import 'package:aturin_app/features/task/ui/screens/add_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late int _taskId;
  late Future<Task?> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskId = widget.task.id!;
    _refreshTaskData();
  }

  
  void _refreshTaskData() {
    final taskService = Provider.of<TaskService>(context, listen: false);
    setState(() {
      _taskFuture = taskService.getTaskById(_taskId);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm, EEEE, d MMMM y', 'id_ID');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.lightTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            color: AppTheme.lightTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.lightTextColor),
            onPressed: () async {
              // Get the current task from the provider
              final taskService = Provider.of<TaskService>(context, listen: false);
              final currentTask = await taskService.getTaskById(_taskId);
              if (currentTask != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTaskScreen(existingTask: currentTask),
                  ),
                );
                
                // Refresh data setelah kembali dari halaman edit
                if (result == true) {
                  _refreshTaskData();
                } else {
                  // Tetap refresh untuk jaga-jaga jika ada perubahan
                  _refreshTaskData();
                }
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Task?>(
        future: _taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Tugas tidak ditemukan'));
          }
          
          final task = snapshot.data!;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailField('Nama Tugas', task.title),
                const SizedBox(height: 16),
                _buildDetailField(
                  'Kategori Tugas',
                  _getCategoryName(task.category),
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  'Estimasi Pengerjaan',
                  '${task.estimatedDuration.inHours};${(task.estimatedDuration.inMinutes % 60).toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 16),
                _buildDetailField('Deadline', _formatDateTime(task.deadline)),
                const SizedBox(height: 16),
                _buildDetailField(
                  'Pengingat',
                  task.alarmDateTime != null
                      ? _formatDateTime(task.alarmDateTime!)
                      : 'Tidak diatur',
                ),
                const SizedBox(height: 16),
                _buildDetailField(
                  'Diselesaikan pada',
                  task.isCompleted && task.completedAt != null
                      ? _formatDateTime(task.completedAt!)
                      : 'Belum diselesaikan',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightDividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.lightTextColor,
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryName(String category) {
    try {
      // Pastikan format string kategori sesuai dengan nama enum
      final categoryString = category.toLowerCase();
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == categoryString,
        orElse: () => TaskCategory.akademik,
      );

      switch (taskCategory) {
        case TaskCategory.akademik:
          return 'Akademik';
        case TaskCategory.hiburan:
          return 'Hiburan';
        case TaskCategory.pekerjaan:
          return 'Pekerjaan';
        case TaskCategory.olahraga:
          return 'Olahraga';
        case TaskCategory.sosial:
          return 'Sosial';
        case TaskCategory.spiritual:
          return 'Spiritual';
        case TaskCategory.pribadi:
          return 'Pribadi';
        case TaskCategory.istirahat:
          return 'Istirahat';
      }
    } catch (e) {
      print('Error getting category name: ${e.toString()}');
      return category;
    }
  }
}