import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import '../../../../../../core/widgets/style_category_card_jadwal.dart';
import '../../../../widgets/chip.dart';

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

  CategoryOptionJadwal _getCategoryDetails() {
    try {
      return categories.firstWhere(
        (item) => item.name.toLowerCase() == task.category.toLowerCase(),
        orElse: () => categories.first,
      );
    } catch (e) {
      return categories.first;
    }
  }

  // Simplified status text - only 2 options based on isCompleted
  String _getStatusText(Task task) {
    return task.isCompleted ? 'Selesai' : 'Belum Dikerjakan';
  }

  Color _getStatusColor(Task task) {
    return task.isCompleted
        ? const Color(0xFFC5E9CD) // Green for completed
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
    final categoryDetails = _getCategoryDetails();
    final normalWidth = 85.w;
    final normalHeight = 65.h;

    final width = isSelected ? normalWidth + 2.w : normalWidth;
    final height = isSelected ? normalHeight + 2.h : normalHeight;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: OverflowBox(
          maxHeight: height,
          minHeight: height,          child: Card(
            elevation: isSelected ? 8 : 0,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200, width: 0.3.w),
            ),
            child: Column(
              children: [
                // Header Section (1/3 of card height)
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: categoryDetails.color,
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

                          const SizedBox(height: 16),                          // Chips Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Category Chip
                                CustomChip(
                                  iconPath: categoryDetails.iconChip,
                                  label: categoryDetails.name,
                                  foregroundColor: categoryDetails.color,
                                  backgroundColor: categoryDetails.color.withOpacity(0.15),
                                ),

                                SizedBox(width: 3.w),

                                // Task Type Chip
                                CustomChip(
                                  iconPath: 'assets/icons/task-list.svg',
                                  label: 'Tugas',
                                  foregroundColor: Color(0xFF5263F3),
                                  backgroundColor: Color(0xFF5263F3).withOpacity(0.15),
                                ),

                                // Alarm Chip (if enabled)
                                if (task.isAlarmEnabled) ...[
                                  SizedBox(width: 3.w),
                                  CustomChip(
                                    iconPath: 'assets/activitycategory/chipicon/alarm2.svg',
                                    foregroundColor: Color(0xFF5263F3),
                                    backgroundColor: Color(0xFF5263F3).withOpacity(0.15),
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
                        _buildStatusRow(
                          'Status',
                          _getStatusText(task),
                          _getStatusColor(task),
                        ),
                        const SizedBox(height: 16),
                        // Other Detail Rows
                        _buildDetailRow(
                          'Batas waktu',
                          _formatDate(task.deadline),
                          categoryDetails.color,
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Estimasi',
                          _formatDuration(task.estimatedDuration),
                          categoryDetails.color,
                        ),

                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Deskripsi',
                            task.description!.length > 15
                                ? '${task.description!.substring(0, 15)}...'
                                : task.description!,
                            categoryDetails.color,
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

  Widget _buildDetailRow(String label, String value, Color categoryColor) {
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
              color: categoryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],    );
  }
}
