import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/task/screens/ui/add_task_screen.dart';
import 'package:aturin_app/features/task/screens/ui/task_detail_screen.dart';
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
    this.showCheckbox = false, // default aktif
    this.showStatus = true, // default aktif
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
    });  }

  @override
  void dispose() {
    _actionThrottle.dispose();
    super.dispose();
  }  @override
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
            builder: (_) => TaskDetailScreen(task: widget.task),
          ),
        );
      },      child: Container(
        key: ValueKey(widget.task.id),
        margin: widget.margin ?? EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            12,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 0.4.h),
            ),
          ],
        ),

        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 4.w),

                    // checbox
                    if (widget.showCheckbox)
                      Padding(
                        padding: EdgeInsets.only(top: 3.5.h),
                        child: GestureDetector(
                          onTap: _handleToggleCompletion,
                          child: Container(
                            width: 6.w,
                            height: 2.7.h,
                            decoration: BoxDecoration(
                              color:
                                  widget.task.isCompleted
                                      ? AppTheme.primaryColor
                                      : Colors.transparent,
                              border: Border.all(
                                color: AppTheme.primaryColor,
                                width: 0.5.w,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child:
                                widget.task.isCompleted
                                    ? Icon(
                                      Icons.check,
                                      size: 4.5.w,
                                      color: AppTheme.lightCardColor,
                                    )
                                    : null,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 0),

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.5.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [                            Row(
                              children: [
                                // badge kategori
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

                                // badge tugas / aktivitas  
                                _buildBadge(
                                  icon: SvgPicture.asset(
                                    'assets/icons/tugas.svg',
                                    width: 3.w,
                                    height: 3.w,
                                    colorFilter: const ColorFilter.mode(
                                      AppTheme.primaryColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  label: 'Tugas',
                                  bgColor: const Color(0xFFDFEAFF),
                                  textColor: AppTheme.primaryColor,
                                ),

                                SizedBox(width: 1.5.w),

                                // badge alarm
                                if (hasAlarmIndicator)
                                  _buildBadge(
                                    icon: SvgPicture.asset(
                                      'assets/icons/alarm.svg',
                                      width: 3.w,
                                      height: 3.w,
                                      colorFilter: const ColorFilter.mode(
                                        AppTheme.primaryColor,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    label: '',
                                    bgColor: const Color(0xFFDFEAFF),
                                    textColor: AppTheme.primaryColor,
                                  ),
                              ],
                            ),
                            SizedBox(height: 0.7.h),
                            Text(
                              widget.task.title,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF131927),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled,
                                  size: 3.w,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Estimasi: ${widget.task.estimatedDuration.inHours}:${(widget.task.estimatedDuration.inMinutes % 60).toString().padLeft(2, '0')}',
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
                      ),                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 3.5.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Status dihilangkan sesuai permintaan
                        ],
                      ),
                    ),

                    // titik tiga, popup edit dan hapus
                    PopupMenuButton<String>(
                      offset: Offset(0, 1.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFFFCE73),
                          width: 1,
                        ),
                      ),
                      color: const Color(0xFFFFF9F0),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) =>
                                      AddTaskScreen(existingTask: widget.task),
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
                            builder:
                                (_) => ConfirmDialog(
                                  onConfirm: () {
                                    // Tutup dialog
                                    widget
                                        .onDelete(); // Panggil fungsi delete dari task_card
                                  },
                                ),
                          );
                        }
                      },
                      itemBuilder:
                          (context) => [
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
                                    color: Color(0xFFD93E39),
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Hapus',
                                    style: TextStyle(
                                      color: Color(0xFFD93E39),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],                      icon: Icon(Icons.more_vert, size: 5.w),
                    ),
                  ],
                ),
                // Indikator "diselesaikan terlambat" dihilangkan sesuai permintaan
              ],
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 2.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF5263F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
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
      ),    );
  }


}
