import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/task/screens/ui/add_task_screen.dart';
import 'package:aturin_app/features/task/screens/ui/task_detail_screen.dart';
import 'package:aturin_app/features/jadwal/screens/detail_task/ui/screens/task_detail_list_screen.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/utils/debouncer.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/core/widgets/categories.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleAlarm;
  final String currentFilter;
  final bool showCheckbox;
  final bool showStatus;
  final EdgeInsetsGeometry? margin;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onViewDetails,
    required this.onToggleAlarm,
    required this.currentFilter,
    this.showCheckbox = false,
    this.showStatus = true,
    this.margin,
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  // Throttle untuk mencegah multiple tap
  final _actionThrottle = Throttle(milliseconds: 500);
  
  // Handler yang aman untuk onToggleCompletion
  void _handleToggleCompletion() {
    _actionThrottle.run(() {
      widget.onToggleCompletion();
    });
  }

  @override
  void dispose() {
    _actionThrottle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan apakah card memiliki alarm indicator
    final bool hasAlarmIndicator = widget.task.isAlarmActive;
    
    // Cari kategori dari categories.dart berdasarkan task category
    final category = categories.firstWhere(
      (c) => c.name.toLowerCase() == widget.task.category.toLowerCase(),
      orElse: () => categories.first,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailListScreen(
              tasks: [widget.task], // Pass the current task
              initialIndex: 0,
            ),
          ),
        );
      },
      child: Container(
        key: ValueKey(widget.task.id),
        margin: widget.margin ?? EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.35),
              blurRadius: 8,
              offset: Offset(0, 0.h),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              child: Row(
                children: [
                  // Checkbox
                  if (widget.showCheckbox)
                    Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: GestureDetector(
                        onTap: _handleToggleCompletion,
                        child: Container(
                          width: 6.w,
                          height: 2.7.h,
                          decoration: BoxDecoration(
                            color: widget.task.isCompleted
                                ? AppTheme.primaryColor
                                : Colors.transparent,
                            border: Border.all(
                              color: AppTheme.primaryColor,
                              width: 0.5.w,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: widget.task.isCompleted
                              ? Icon(
                                  Icons.check,
                                  size: 4.5.w,
                                  color: AppTheme.lightCardColor,
                                )
                              : null,
                        ),
                      ),
                    ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Category badge
                            _buildBadge(
                              icon: SvgPicture.asset(
                                category.iconPath,
                                width: 3.w,
                                height: 3.w,
                                colorFilter: ColorFilter.mode(
                                  category.textColor,
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: category.name,
                              bgColor: category.backgroundColor,
                              textColor: category.textColor,
                            ),
                            SizedBox(width: 1.5.w),

                            // Type badge
                            _buildBadge(
                              icon: SvgPicture.asset(
                                'assets/icons/tugas.svg',
                                width: 3.w,
                                height: 3.w,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF5263F3),
                                  BlendMode.srcIn,
                                ),
                              ),
                              label: 'Tugas',
                              bgColor: const Color(0xFFDFEAFF),
                              textColor: const Color(0xFF5263F3),
                            ),
                            SizedBox(width: 1.5.w),

                            // Alarm badge
                            if (hasAlarmIndicator)
                              _buildBadge(
                                icon: SvgPicture.asset(
                                  'assets/icons/alarm.svg',
                                  width: 3.w,
                                  height: 3.w,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF5263F3),
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: '',
                                bgColor: const Color(0xFFDFEAFF),
                                textColor: const Color(0xFF5263F3),
                              ),
                          ],
                        ),
                        SizedBox(height: 0.7.h),

                        // Title
                        Text(
                          widget.task.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF131927),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),

                        // Duration
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled,
                              size: 3.w,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Estimasi: ${widget.task.estimatedDuration.inHours} jam ${widget.task.estimatedDuration.inMinutes % 60} menit',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Left indicator
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF5263F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // Menu button di pojok kanan atas
            Positioned(
              top: 1.h,
              right: 4.w,
              child: PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF5263F3), width: 1.5),
                ),
                color: const Color.fromARGB(255, 249, 251, 255),
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(existingTask: widget.task),
                      ),
                    );

                    if (result == true) {
                      final updatedTask = widget.task.id;
                      if (updatedTask != null) {
                        setState(() {
                          // update jika perlu
                        });
                      }
                    }
                  } else if (value == 'delete') {
                    // Tampilkan DeletePopup
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmDialog(
                        onConfirm: () {
                          // Tutup dialog
                          widget.onDelete(); // Panggil fungsi delete dari task_card
                        },
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit,
                          color: Colors.black,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Ubah',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: const Color(0xFFD93E39),
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Hapus',
                          style: TextStyle(
                            color: const Color(0xFFD93E39),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: Icon(Icons.more_vert, size: 5.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required Widget icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.8.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          if (label.isNotEmpty) ...[
            SizedBox(width: 1.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}