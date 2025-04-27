import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // Implementasi edit tugas
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
            _buildDetailField('Kategori Tugas', _getCategoryName(_task.category)),
            const SizedBox(height: 16),
            _buildDetailField('Estimasi Pengerjaan(Jam)', _task.estimatedHours.toString()),
            const SizedBox(height: 16),
            _buildDetailField('Deadline', _formatDateTime(_task.deadline)),
            const SizedBox(height: 16),
            _buildDetailField(
              'Pengingat', 
              _task.alarmDateTime != null 
                ? _formatDateTime(_task.alarmDateTime!) 
                : 'Tidak diatur'
            ),
            const SizedBox(height: 16),
            _buildDetailField(
              'Diselesaikan pada', 
              _task.isCompleted && _task.completedAt != null
                ? _formatDateTime(_task.completedAt!)
                : 'Belum diselesaikan'
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  String _getCategoryName(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString() == 'TaskCategory.$category',
        orElse: () => TaskCategory.other,
      );
      
      switch (taskCategory) {
        case TaskCategory.academic:
          return 'Akademik';
        case TaskCategory.personal:
          return 'Pribadi';
        case TaskCategory.work:
          return 'Kerja';
        case TaskCategory.other:
          return 'Lainnya';
      }
    } catch (_) {
      return category;
    }
  }
}
