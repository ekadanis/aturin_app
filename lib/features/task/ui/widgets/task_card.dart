import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/task.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleAlarm;
  final String currentFilter;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onViewDetails,
    required this.onToggleAlarm,
    required this.currentFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onViewDetails(),
            backgroundColor: const Color.fromARGB(212, 219, 217, 217),
            child: SvgPicture.asset(
              'assets/icons/info.svg',
              width: 24,
              height: 24,
            ),
          ),
          CustomSlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFFFCDD2),
            child: SvgPicture.asset(
              'assets/icons/sampah.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            ),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Checkbox atau indikator status
                  GestureDetector(
                    onTap: onToggleCompletion,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            task.isCompleted
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              task.isCompleted
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child:
                          task.isCompleted
                              ? const Icon(
                                Icons.check,
                                size: 16,
                                color: AppTheme.lightCardColor,
                              )
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Informasi tugas
                  // Informasi tugas
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Kategori
                        Row(
                          children: [
                            SvgPicture.asset(
                              _getCategoryIconPath(task.category),
                              width: 20,
                              height: 20,
                            ),

                            const SizedBox(width: 4),
                            Text(
                              _getCategoryName(task.category),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.lightSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Judul tugas
                        Text(
                          task.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Estimasi waktu
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Estimasi: ${task.estimatedDuration.inHours}:${(task.estimatedDuration.inMinutes % 60).toString().padLeft(2, '0')}',
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

                  // Status badge
                  Container(
                    alignment: Alignment.center,
                    width: 90,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getBadgeColor(task, currentFilter),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getBadgeText(task, currentFilter),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getBadgeTextColor(task, currentFilter),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Alarm indicator if active
            if (task.isAlarmActive)
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.alarm, size: 12, color: Colors.blue),
                    SizedBox(width: 4),
                    Text(
                      'Alarm aktif',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            if (task.isCompleted && task.previousStatus == TaskStatus.late)
              Container(
                height: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '* Diselesaikan terlambat',
                      style: TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getCategoryIconPath(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.name == category.toLowerCase(),
      );
      switch (taskCategory) {
        case TaskCategory.akademik:
          return 'assets/images/akademik.svg';
        case TaskCategory.hiburan:
          return 'assets/images/hiburan.svg';
        case TaskCategory.pekerjaan:
          return 'assets/images/pekerjaan.svg';
        case TaskCategory.olahraga:
          return 'assets/images/olahraga.svg';
        case TaskCategory.sosial:
          return 'assets/images/sosial.svg';
        case TaskCategory.spiritual:
          return 'assets/images/spiritual.svg';
        case TaskCategory.pribadi:
          return 'assets/images/pribadi.svg';
        case TaskCategory.istirahat:
          return 'assets/images/istirahat.svg';
      }
    } catch (_) {
      return 'assets/images/akademik.svg';
    }
  }

  String _getCategoryName(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString() == 'TaskCategory.$category',
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
    } catch (_) {
      return category;
    }
  }

  String _getStatusName(TaskStatus status, {Task? task}) {
    switch (status) {
      case TaskStatus.completed:
        return 'Selesai';
      case TaskStatus.late:
        return 'Terlambat';
      case TaskStatus.today:
        return 'Hari Ini';
      case TaskStatus.tomorrow:
        return 'Besok';
      case TaskStatus.upcoming:
        if (task != null) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final deadlineDay = DateTime(
            task.deadline.year,
            task.deadline.month,
            task.deadline.day,
          );
          final daysRemaining = deadlineDay.difference(today).inDays;
          return '$daysRemaining hari lagi';
        }
        return 'Mendatang';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFFE3F2E9);
      case TaskStatus.late:
        return const Color(0xFFFFDDDD);
      case TaskStatus.today:
        return const Color(0xFFE3F2F9);
      case TaskStatus.tomorrow:
        return const Color(0xFFFFF8E1);
      case TaskStatus.upcoming:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFF4CAF50);
      case TaskStatus.late:
        return const Color(0xFFFF6B6B);
      case TaskStatus.today:
        return const Color(0xFF2196F3);
      case TaskStatus.tomorrow:
        return const Color(0xFFFFC107);
      case TaskStatus.upcoming:
        return const Color(0xFF9E9E9E);
    }
  }

  String _getBadgeText(Task task, String currentFilter) {
    if (task.isCompleted && currentFilter == 'Selesai') {
      return 'Selesai';
    }
    return _getStatusName(task.status, task: task);
  }

  Color _getBadgeColor(Task task, String currentFilter) {
    if (task.isCompleted && currentFilter == 'Selesai') {
      return AppTheme.completedColor;
    }
    return _getStatusColor(task.status);
  }

  Color _getBadgeTextColor(Task task, String currentFilter) {
    if (task.isCompleted && currentFilter == 'Selesai') {
      return AppTheme.completedTextColor;
    }
    return _getStatusTextColor(task.status);
  }
}
