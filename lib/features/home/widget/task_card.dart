import 'package:aturin_app/features/home/models/task_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(task.status);
    final statusLabel = getStatusLabel(task.status);
    final categoryIcon = getCategoryIcon(task.category);
    final categoryLabel = getCategoryLabel(task.category);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: Color(0xFFE4E4E7)),
              borderRadius: BorderRadius.circular(12),
            ),
            shadows: [
              const BoxShadow(
                color: Color(0x0C0C0C0D),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // LEFT SIDE (info tugas)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori + Icon
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: SvgPicture.asset(categoryIcon, width: 20),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          categoryLabel, //kategori
                          style: TextStyle(
                            color: const Color(0xFF999999),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.title, //judul
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled,
                          size: 16,
                          color: task.status == TaskStatus.terlambat
                                ? Colors.red
                                : const Color(0xFF1A1B4C),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.timeRange, //waktu
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: task.status == TaskStatus.terlambat
                                ? Colors.red
                                : const Color(0xFF1A1B4C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // RIGHT SIDE (Status badge)
              Container(
                width: 77,
                height: 26,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  statusLabel, //status
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Color getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.selesai:
        return const Color(0xFF3DA755); // Green
      case TaskStatus.terlambat:
        return const Color(0xFFD34141); // Red
      case TaskStatus.besok:
        return const Color(0xFFE6A73C); // Yellow
    }
  }

  static String getStatusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.selesai:
        return 'Selesai';
      case TaskStatus.terlambat:
        return 'Terlambat';
      case TaskStatus.besok:
        return 'Besok';
    }
  }

  static String getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.akademik:
        return 'assets/icons/graduation-cap.svg';
      case TaskCategory.hiburan:
        return 'assets/icons/gamepad.svg';
      case TaskCategory.istirahat:
        return 'assets/icons/half-moon.svg';
      case TaskCategory.olahraga:
        return 'assets/icons/gym.svg';
      case TaskCategory.pekerjaan:
        return 'assets/icons/handbag.svg';
      case TaskCategory.pribadi:
        return 'assets/icons/user-square.svg';
      case TaskCategory.sosial:
        return 'assets/icons/community.svg';
      case TaskCategory.spiritual:
        return 'assets/icons/pray.svg';
    }
  }

  static String getCategoryLabel(TaskCategory category) {
    switch (category) {
      case TaskCategory.akademik:
        return 'Akademik';
      case TaskCategory.hiburan:
        return 'Hiburan';
      case TaskCategory.istirahat:
        return 'Istirahat';
      case TaskCategory.olahraga:
        return 'Olahraga';
      case TaskCategory.pekerjaan:
        return 'Pekerjaan';
      case TaskCategory.pribadi:
        return 'Pribadi';
      case TaskCategory.sosial:
        return 'Sosial';
      case TaskCategory.spiritual:
        return 'Spiritual';
    }
  }
}
