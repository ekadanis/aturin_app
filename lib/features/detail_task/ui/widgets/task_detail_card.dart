import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../task/models/task.dart';

class TaskDetailCard extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback? onTap;

  const TaskDetailCard({
    Key? key,
    required this.task,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

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

  Color _getCategoryColor(String category) {
    const categoryColors = {
      'akademik': Color(0xFF3498DB),
      'hiburan': Color(0xFF9B59B6),
      'pekerjaan': Color(0xFF8E5C42),
      'olahraga': Color(0xFFE74C3C),
      'sosial': Color(0xFFE67E22),
      'spiritual': Color(0xFF27AE60),
      'pribadi': Color(0xFFF1C40F),
      'istirahat': Color(0xFF283593),
    };
    return categoryColors[category.toLowerCase()] ??
        categoryColors['akademik']!;
  }

  String _getCategoryName(String category) {
    try {
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
      return category;
    }
  }

  // Simplified status text - only 2 options based on isCompleted
  String _getStatusText(Task task) {
    return task.isCompleted ? 'Selesai' : 'Belum Dikerjakan';
  }

  // Simplified status color - only 2 options based on isCompleted
  Color _getStatusColor(Task task) {
    return task.isCompleted 
        ? const Color(0xFFC5E9CD)  // Green for completed
        : const Color(0xFFFFEDD9); // Orange for not completed
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '$hours jam $minutes menit';
      } else {
        return '$hours jam';
      }
    } else {
      return '$minutes menit';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(task.category);
    final normalWidth = 327.0;
    final normalHeight = 560.0;

    final width = isSelected ? normalWidth + 20 : normalWidth;
    final height = isSelected ? normalHeight + 20 : normalHeight;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: OverflowBox(
          maxHeight: height,
          minHeight: height,
          child: Card(
            elevation: isSelected ? 8 : 4,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Header Section (1/3 of card height)
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Task Title
                          Text(
                            task.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 16),

                          // Chips Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Category Chip
                                _buildChip(
                                  label: _getCategoryName(task.category),
                                  icon: SvgPicture.asset(
                                    _getCategoryIconPath(task.category),
                                    width: 14,
                                    height: 14,
                                    colorFilter: const ColorFilter.mode(
                                      Colors.white,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 8),
                                
                                // Task Type Chip
                                _buildChip(
                                  label: 'Tugas',
                                  icon: const Icon(
                                    Icons.assignment,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                
                                // Alarm Chip (if enabled)
                                if (task.isAlarmEnabled) ...[
                                  const SizedBox(width: 8),
                                  _buildChip(
                                    label: '',
                                    icon: const Icon(
                                      Icons.alarm,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    isIconOnly: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Section (2/3 of card height)
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Status Row with Badge
                        _buildStatusRow('Status', _getStatusText(task), _getStatusColor(task)),
                        const SizedBox(height: 16),
                        
                        // Other Detail Rows
                        _buildDetailRow('Batas waktu', _formatDate(task.deadline)),
                        const SizedBox(height: 16),
                        _buildDetailRow('Estimasi', _formatDuration(task.estimatedDuration)),

                        if (task.description != null && task.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Deskripsi',
                            task.description!.length > 15
                                ? '${task.description!.substring(0, 15)}...'
                                : task.description!,
                          ),
                        ],

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              color: _getCategoryColor(task.category),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    Widget? icon,
    bool isIconOnly = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isIconOnly ? 8 : 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon,
          if (!isIconOnly && label.isNotEmpty) ...[
            if (icon != null) const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}