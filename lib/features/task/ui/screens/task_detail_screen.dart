import 'package:aturin_app/features/task/ui/screens/add_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/task_services.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/flutter_svg.dart';

@RoutePage()
class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
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
            icon: SvgPicture.asset(
              'assets/icons/edit.svg', // Ganti dengan path asset yang kamu siapkan
              width: 20, // Sesuaikan ukuran ikon
              height: 20,
              color: Colors.black, 
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(existingTask: _task),
                ),
              );

              if (result == true) {
                final updatedTask = await TaskService().getTaskById(_task.id!);
                if (updatedTask != null) {
                  setState(() {
                    _task = updatedTask;
                  });
                  // Tandai bahwa ada perubahan untuk diteruskan ke halaman daftar
                  Navigator.pop(context, true);
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailField('Nama Tugas', _task.title),
            const SizedBox(height: 16),
            _buildDetailField('Deskripsi', (_task.description != null && _task.description!.isNotEmpty)
                ? _task.description!
                : 'Tidak ada deskripsi'),
            const SizedBox(height: 16),
            _buildDetailField(
              'Kategori Tugas',
              _getCategoryName(_task.category),
            ),
            const SizedBox(height: 16),
              _buildDetailField(
                'Estimasi Pengerjaan(Jam)',
                _formatDurationToHourDotMinute(_task.estimatedDuration),
              ),
            const SizedBox(height: 16),
            _buildDetailField('Deadline', _formatDateTime(_task.deadline)),
            const SizedBox(height: 16),
            _buildDetailField(
              'Pengingat',
              _task.alarmDateTime != null
                  ? _formatDateTime(_task.alarmDateTime!)
                  : 'Tidak diatur',
            ),
            const SizedBox(height: 16),
            _buildDetailField(
              'Diselesaikan pada',
              _task.isCompleted && _task.completedAt != null
                  ? _formatDateTime(_task.completedAt!)
                  : 'Belum diselesaikan',
            ),
          ],
        ),
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

  // Perbaiki fungsi _getCategoryName untuk menangani konversi kategori dengan lebih baik
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


  String _formatDurationToHourDotMinute(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;

  final minutesStr = minutes.toString().padLeft(2, '0');
  return '$hours.$minutesStr';
}

}
