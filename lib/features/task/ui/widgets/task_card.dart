import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    return Container(
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
      child: Column(
        children: [
          // Header with status badge
          if (task.status == TaskStatus.late && !task.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppTheme.lateColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Text(
                  'Terlambat',
                  style: TextStyle(
                    color: AppTheme.lateTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          
          // Main content
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
                      color: task.isCompleted ? AppTheme.primaryColor.withOpacity(0.2) : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? AppTheme.primaryColor : AppTheme.primaryColor.withOpacity(0.5),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Informasi tugas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul tugas
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Estimasi waktu
                      Row(
                        children: [
                          _buildCategoryIcon(),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppTheme.lightSecondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Estimasi: ${task.estimatedHours} jam',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.lightSecondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Alarm indicator if active
                if (task.isAlarmActive)
                  const Text(
                    'Alarm Aktif',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.alarmActiveColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            children: [
              // Detail button
              Expanded(
                child: InkWell(
                  onTap: onViewDetails,
                  child: Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppTheme.detailBackgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.detailTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Detail',
                          style: TextStyle(
                            color: AppTheme.detailTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Delete button
              Expanded(
                child: InkWell(
                  onTap: onDelete,
                  child: Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppTheme.deleteBackgroundColor,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppTheme.deleteTextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: AppTheme.deleteTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Ubah fungsi _buildCategoryIcon() untuk menambahkan fallback icon
Widget _buildCategoryIcon() {
  TaskCategory taskCategory;

  try {
    taskCategory = TaskCategory.values.firstWhere(
      (e) => e.toString() == 'TaskCategory.${task.category}',
      orElse: () => TaskCategory.akademik,
    );
  } catch (_) {
    taskCategory = TaskCategory.akademik;
  }

  String? iconAssetPath;

  // Menentukan path ikon berdasarkan kategori
  switch (taskCategory) {
    case TaskCategory.akademik:
      iconAssetPath = 'assets/images/akademik.svg';
      break;
    case TaskCategory.hiburan:
      iconAssetPath = 'assets/images/hiburan.svg';
      break;
    case TaskCategory.pekerjaan:
      iconAssetPath = 'assets/images/pekerjaan.svg';
      break;
    case TaskCategory.olahraga:
      iconAssetPath = 'assets/images/olahraga.svg';
      break;
    case TaskCategory.sosial:
      iconAssetPath = 'assets/images/sosial.svg';
      break;
    case TaskCategory.spiritual:
      iconAssetPath = 'assets/images/spiritual.svg';
      break;
    case TaskCategory.pribadi:
      iconAssetPath = 'assets/images/pribadi.svg';
      break;
    case TaskCategory.istirahat:
      iconAssetPath = 'assets/images/istirahat.svg';
      break;
  }

  if (iconAssetPath != null) {
    // Kalau ada iconAssetPath, tampilkan SVG dengan fallback icon
    return SvgPicture.asset(
      iconAssetPath,
      width: 14,
      height: 14,
      placeholderBuilder: (BuildContext context) => _buildFallbackIcon(taskCategory),
    );
  }

  // Kalau tidak ada iconAssetPath, langsung tampilkan fallback icon
  return _buildFallbackIcon(taskCategory);
}

// Tambahkan fungsi _buildFallbackIcon untuk menampilkan ikon Material Design
Widget _buildFallbackIcon(TaskCategory taskCategory) {
  IconData iconData;
  
  switch (taskCategory) {
    case TaskCategory.akademik:
      iconData = Icons.school;
      break;
    case TaskCategory.hiburan:
      iconData = Icons.movie;
      break;
    case TaskCategory.pekerjaan:
      iconData = Icons.work;
      break;
    case TaskCategory.olahraga:
      iconData = Icons.fitness_center;
      break;
    case TaskCategory.sosial:
      iconData = Icons.people;
      break;
    case TaskCategory.spiritual:
      iconData = Icons.self_improvement;
      break;
    case TaskCategory.pribadi:
      iconData = Icons.person;
      break;
    case TaskCategory.istirahat:
      iconData = Icons.bedtime;
      break;
  }
  
  return Icon(
    iconData,
    size: 14,
    color: AppTheme.primaryColor,
  );
}
}
