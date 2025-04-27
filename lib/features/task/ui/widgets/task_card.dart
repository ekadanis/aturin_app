import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleAlarm;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onViewDetails,
    required this.onToggleAlarm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (_) => onViewDetails(),
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey.shade600,
            icon: Icons.info_outline,
            label: 'Detail',
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFFFCDD2),
            foregroundColor: Colors.red,
            icon: Icons.delete_outline,
            label: 'Hapus',
          ),
        ],
      ),
      child: Container(
        height: 84, // Sesuai dengan ukuran di Figma
        width: 330, // Sesuai dengan ukuran di Figma
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: task.status == TaskStatus.late && !task.isCompleted
            ? _buildLateTaskCard(context)
            : _buildNormalTaskCard(context),
      ),
    );
  }

  Widget _buildNormalTaskCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          _buildCategoryIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Estimasi: ${task.estimatedHours}jam',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    if (task.isAlarmActive) ...[
                      const SizedBox(width: 8),
                      const Text(
                        'Alarm Aktif',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _buildStatusBadge(context),
        ],
      ),
    );
  }

  Widget _buildLateTaskCard(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              _buildCategoryIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Estimasi: ${task.estimatedHours}jam',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDDDD),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Terlambat',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Container(
          height: 16,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 16),
          child: Text(
            task.isAlarmActive ? 'Alarm Aktif' : '',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon() {
    IconData iconData;
    // Mengkonversi string kategori ke enum TaskCategory jika perlu
    TaskCategory taskCategory;
    
    try {
      // Mencoba mengkonversi string ke enum
      taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString() == 'TaskCategory.${task.category}',
        orElse: () => TaskCategory.other,
      );
    } catch (_) {
      // Jika gagal, gunakan kategori default
      taskCategory = TaskCategory.other;
    }
    
    // Menentukan ikon berdasarkan kategori
    switch (taskCategory) {
      case TaskCategory.academic:
        iconData = Icons.school;
        break;
      case TaskCategory.personal:
        iconData = Icons.person;
        break;
      case TaskCategory.work:
        iconData = Icons.work;
        break;
      case TaskCategory.other:
      default:
        iconData = Icons.more_horiz;
        break;
    }

    return GestureDetector(
      onTap: onToggleCompletion,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.blue.shade100 : Colors.transparent,
          border: Border.all(
            color: task.isCompleted ? Colors.blue : Colors.blue.shade200,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: task.isCompleted
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.blue,
              )
            : null,
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (task.status) {
      case TaskStatus.completed:
        bgColor = const Color(0xFFE3F2E9);
        textColor = const Color(0xFF4CAF50);
        label = 'Selesai';
        break;
      case TaskStatus.late:
        bgColor = const Color(0xFFFFDDDD);
        textColor = const Color(0xFFFF6B6B);
        label = 'Terlambat';
        break;
      case TaskStatus.today:
        bgColor = const Color(0xFFE3F2F9);
        textColor = const Color(0xFF2196F3);
        label = 'Hari Ini';
        break;
      case TaskStatus.tomorrow:
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFFFC107);
        label = 'Besok';
        break;
      case TaskStatus.upcoming:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF9E9E9E);
        label = 'Mendatang';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
