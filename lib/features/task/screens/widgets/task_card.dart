import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/features/task/screens/ui/add_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/task_model.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/utils/debouncer.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/utils/category_helper.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onToggleCompletion;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;
  final VoidCallback onToggleAlarm;
  final String currentFilter;
  final bool showCheckbox;
  final bool showStatus;
  final bool showPopupMenu;
   final bool removeMargin;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onToggleCompletion,
    required this.onDelete,
    required this.onViewDetails,
    required this.onToggleAlarm,
    required this.currentFilter,
      required this.removeMargin,
    this.showCheckbox = true, // default aktif
    this.showStatus = true, // default aktif
    this.showPopupMenu = true, // <-- tambahkan ini
  
  }) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  // Throttle untuk mencegah multiple tap
  final _actionThrottle = Throttle(milliseconds: 500);
  
  // Check if task is completed
  bool _isCompleted() {
    return widget.task.isCompleted;
  }
    // Handler yang aman untuk onToggleCompletion dengan provider pattern
  void _handleToggleCompletion() async {
    _actionThrottle.run(() async {
      try {
        final taskApiService = Provider.of<TaskApiService>(
          context,
          listen: false,
        );
        
        // Toggle completion status through provider service
        final newStatus = widget.task.isCompleted ? 'belum_selesai' : 'selesai';
        final result = await taskApiService.updateTask(
          slug: widget.task.slug!,
          status: newStatus,
        );
        
        if (result.isSuccess) {
          // Refresh tasks through provider
          await taskApiService.fetchTasks();
        }
        // Also call the original callback for parent widget compatibility
        widget.onToggleCompletion();      } catch (e) {
        // Handle error and fall back to original callback
        // Log error in debug mode only
        assert(() {
          print('Error toggling task completion: $e');
          return true;
        }());
        widget.onToggleCompletion();
      }
    });
  }

  @override
  void dispose() {
    _actionThrottle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLateIndicator =
        widget.task.isCompleted && widget.task.status == TaskStatus.late;

    return GestureDetector(
      onTap: () {
        widget.onViewDetails();
      },
      child: Container(
        key: ValueKey(widget.task.id),
         margin: widget.removeMargin 
            ? EdgeInsets.zero 
            : EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.35), // Ubah di sini
              blurRadius: 8,
              offset: Offset(0, 0),
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
                    SizedBox(width: 6.w),

                    // checbox
                    if (widget.showCheckbox)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h, bottom: 4.h),
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
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 0,
                              children: [                                // badge category
                                _buildBadge(
                                  icon: SvgPicture.asset(
                                    CategoryHelper.getCategoryOptionFromString(widget.task.category).iconPath,
                                    width: 3.w,
                                    height: 3.w,
                                  ),                                  label: CategoryHelper.getCategoryOptionFromString(widget.task.category).name,
                                  bgColor: CategoryHelper.getCategoryOptionFromString(widget.task.category).backgroundColor,
                                  textColor: CategoryHelper.getCategoryOptionFromString(widget.task.category).textColor,
                                ),
                                SizedBox(width: 1.5.w),
                                // badge alarm
                                if (widget.task.alarm != null &&
                                    widget.task.alarm!.alarmEnabled == true)
                                  _buildBadge(
                                    icon: SvgPicture.asset(
                                      'assets/activitycategory/chipicon/alarm2.svg',
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
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.showStatus)
                            // badge status
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 1.h,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    widget.task.isCompleted
                                        ? const Color(
                                          0xFFC5E9CD,
                                        ) // Hijau untuk selesai
                                        : _getStatusColor(widget.task.status),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.task.isCompleted
                                    ? 'Selesai'
                                    : _getStatusName(
                                      widget.task.status,
                                      task: widget.task,
                                    ),
                                style: TextStyle(
                                  color:
                                      widget.task.isCompleted
                                          ? const Color(
                                            0xFF3DA755,
                                          ) // Teks hijau
                                          : _getStatusTextColor(
                                            widget.task.status,
                                          ),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),                    // titik tiga, popup edit dan hapus
                    if (widget.showPopupMenu)
                      PopupMenuButton<String>(
                        offset: Offset(0, 1.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFF5263F3),
                            width: 1.5,
                          ),
                        ),
                        color: const Color.fromARGB(255, 249, 251, 255),                        onSelected: (value) async {
                          if (value == 'edit') {
                            // Use TaskApiService from provider
                            final taskApiService = Provider.of<TaskApiService>(
                              context,
                              listen: false,
                            );
                            
                            // Store context to avoid async gap warning
                            final navigator = Navigator.of(context);
                            
                            // Get latest task data from provider service
                            final latestTask = widget.task.slug != null
                                ? await taskApiService.getTaskBySlug(
                                    widget.task.slug!,
                                  )
                                : null;
                            
                            final result = await navigator.push(
                              MaterialPageRoute(
                                builder: (_) => AddTaskScreen(
                                  existingTask: latestTask ?? widget.task,
                                ),
                              ),
                            );
                            
                            if (result == true) {
                              // Refresh tasks through provider
                              await taskApiService.fetchTasks();
                            }
                          } else if (value == 'delete') {
                            // Tampilkan DeletePopup
                            showDialog(
                              context: context,
                              builder:
                                  (_) => ConfirmDialog(
                                    isTask:
                                        true, // Set isTask ke true untuk tugas
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
                                      color: AppTheme.primaryColor,
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
                            ],
                        icon: Icon(Icons.more_vert, size: 5.w),
                      ) else

                      const SizedBox(width: 40),
                  ],
                ),
                if (hasLateIndicator)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 0.5.h,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDECEC),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Diselesaikan terlambat',
                        style: TextStyle(
                          color: Color(0xFFD93E39),
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
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
        return const Color(0xFFE4E4E7);
      case TaskStatus.today:
        return const Color(0xFFE6F4FF);
      case TaskStatus.tomorrow:
        return const Color(0xFFFFE5B0);
      case TaskStatus.upcoming:
        return const Color(0xFFFFE5B0);
    }
  }

  Color _getStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFF4CAF50);
      case TaskStatus.late:
        return const Color(0xFF999999);
      case TaskStatus.today:
        return const Color(0xFF0077CC);
      case TaskStatus.tomorrow:
        return const Color(0xFFE89B00);
      case TaskStatus.upcoming:
        return const Color(0xFFE89B00);
    }
  }
}
