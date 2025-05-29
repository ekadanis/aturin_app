import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/core/widgets/categories.dart';

class InfiniteScheduleListWidget extends StatefulWidget {
  final DateTime selectedDate;
  final List<AktivitasModel> schedules;
  final List<Task> tasks;
  final String selectedCategory;
  final Function(DateTime) onDateChanged;
  final Function(AktivitasModel)? onEditSchedule;
  final Function(AktivitasModel)? onDeleteSchedule;

  const InfiniteScheduleListWidget({
    super.key,
    required this.selectedDate,
    required this.schedules,
    required this.tasks,
    required this.selectedCategory,
    required this.onDateChanged,
    this.onEditSchedule,
    this.onDeleteSchedule,
  });

  @override
  State<InfiniteScheduleListWidget> createState() =>
      _InfiniteScheduleListWidgetState();
}

class _InfiniteScheduleListWidgetState
    extends State<InfiniteScheduleListWidget> {
  late PageController _pageController;
  late DateTime _baseDate;
  
  static const int _initialPageIndex = 100000;
  int _currentPageIndex = _initialPageIndex;
  bool _isPageChanging = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseDate = DateTime(now.year, now.month, now.day);
    
    final normalizedSelectedDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    
    final daysDifference = normalizedSelectedDate.difference(_baseDate).inDays;
    _currentPageIndex = _initialPageIndex + daysDifference;
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void didUpdateWidget(InfiniteScheduleListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final oldDate = DateTime(
      oldWidget.selectedDate.year,
      oldWidget.selectedDate.month, 
      oldWidget.selectedDate.day,
    );
    final newDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
    );
    
    if (newDate != oldDate && !_isPageChanging) {
      _animateToDate(widget.selectedDate);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToDate(DateTime targetDate) {
    if (!_pageController.hasClients) return;
    
    final normalizedDate = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    
    final daysDifference = normalizedDate.difference(_baseDate).inDays;
    final targetPageIndex = _initialPageIndex + daysDifference;
    
    _isPageChanging = true;
    
    _pageController
        .animateToPage(
          targetPageIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _isPageChanging = false;
          });
        });
  }

  DateTime _getDateForPage(int pageIndex) {
    final daysDifference = pageIndex - _initialPageIndex;
    return _baseDate.add(Duration(days: daysDifference));
  }
  List<AktivitasModel> _getSchedulesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    return widget.schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.activityDate.year,
        schedule.activityDate.month,
        schedule.activityDate.day,
      );
      
      bool categoryMatch = widget.selectedCategory == 'Semua' ||
          schedule.activityCategory.displayName == widget.selectedCategory;
      bool dateMatch = scheduleDate.isAtSameMomentAs(normalizedDate);
      
      return categoryMatch && dateMatch;
    }).toList();
  }  List<Task> _getTasksForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    return widget.tasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      
      return taskDate.isAtSameMomentAs(normalizedDate);
    }).toList();
  }

  String _formatDateHeader(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.isAtSameMomentAs(today);
  }  String _getTypeLabel(AktivitasModel schedule) {
    // Deteksi berdasarkan slug field - cek apakah mengandung kata kunci
    if (schedule.slug != null) {
      final slugLower = schedule.slug!.toLowerCase();
      if (slugLower.contains('tugas')) {
        return 'Tugas';
      } else if (slugLower.contains('aktivitas')) {
        return 'Aktivitas';
      }
    }
    
    // Fallback: jika slug null atau tidak mengandung keyword, gunakan logika lama
    if (schedule.activityTitle.toLowerCase().contains('tugas') ||
        schedule.activityCategory == ActivityCategory.akademik) {
      return 'Tugas';
    }
    return 'Aktivitas';
  }
  String _getDurationText(AktivitasModel schedule) {
    final duration = schedule.activityCompleteTime.difference(
      schedule.activityStartTime,
    );
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (_getTypeLabel(schedule) == 'Tugas') {
      if (hours > 0) {
        return 'Estimasi: ${hours} jam ${minutes} menit';
      } else {
        return 'Estimasi: ${minutes} menit';
      }
    } else {
      return '${DateFormat('HH:mm').format(schedule.activityStartTime)} - ${DateFormat('HH:mm').format(schedule.activityCompleteTime)}';
    }
  }

  String _getTaskTypeLabel(Task task) {
    // Deteksi berdasarkan slug field - cek apakah mengandung kata kunci
    if (task.slug != null) {
      final slugLower = task.slug!.toLowerCase();
      if (slugLower.contains('tugas')) {
        return 'Tugas';
      } else if (slugLower.contains('aktivitas')) {
        return 'Aktivitas';
      }
    }
    return 'Tugas';
  }

  String _getTaskDurationText(Task task) {
    final hours = task.estimatedDuration.inHours;
    final minutes = task.estimatedDuration.inMinutes % 60;

    if (hours > 0) {
      return 'Estimasi: ${hours} jam ${minutes} menit';
    } else {
      return 'Estimasi: ${minutes} menit';
    }
  }

  void _showActionMenu(BuildContext context, AktivitasModel schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF5263F3)),
                title: Text(
                  'Ubah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF131927),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  widget.onEditSchedule?.call(schedule);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Hapus',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF131927),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, schedule);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, AktivitasModel schedule) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hapus Jadwal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF131927),
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${schedule.activityTitle}"?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF131927),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onDeleteSchedule?.call(schedule);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScheduleCard(AktivitasModel schedule) {
    final category = categories.firstWhere(
      (c) => c.name == schedule.activityCategory.displayName,
      orElse: () => categories.first,
    );
    final typeLabel = _getTypeLabel(schedule);
    final durationText = _getDurationText(schedule);
    final hasAlarm = schedule.alarm != null;
    final typeIconPath = typeLabel == 'Tugas'
        ? 'assets/icons/task-list.svg'
        : 'assets/icons/activity.svg';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: category.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            category.iconPath,
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              category.textColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: category.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFEAFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(typeIconPath, width: 16, height: 16),
                          const SizedBox(width: 2),
                          Text(
                            typeLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5263F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Alarm badge
                    if (hasAlarm)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFEAFF),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/alarm.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                    const Spacer(),
                    // Menu button
                    GestureDetector(
                      onTap: () => _showActionMenu(context, schedule),
                      child: Icon(
                        Icons.more_vert,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  schedule.activityTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF131927),
                  ),
                ),
                // Duration
                if (durationText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/activitycategory/time.svg',
                        width: 14,
                        height: 14,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        durationText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Left indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF5263F3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final typeLabel = _getTaskTypeLabel(task);
    final durationText = _getTaskDurationText(task);
    final hasAlarm = task.isAlarmEnabled;
    final typeIconPath = typeLabel == 'Tugas'
        ? 'assets/icons/task-list.svg'
        : 'assets/icons/activity.svg';

    // Find matching category for task
    final category = categories.firstWhere(
      (c) => c.name == task.category,
      orElse: () => categories.first,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: category.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            category.iconPath,
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(
                              category.textColor,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            category.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: category.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFEAFF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(typeIconPath, width: 16, height: 16),
                          const SizedBox(width: 2),
                          Text(
                            typeLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5263F3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Alarm badge
                    if (hasAlarm)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFEAFF),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/alarm.svg',
                          width: 16,
                          height: 16,
                        ),
                      ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  task.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF131927),
                  ),
                ),
                // Duration
                if (durationText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/activitycategory/time.svg',
                        width: 14,
                        height: 14,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        durationText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Left indicator
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 10,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada jadwal',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada jadwal untuk hari ini',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          if (!_isPageChanging) {
            _currentPageIndex = pageIndex;
            final newDate = _getDateForPage(pageIndex);
            widget.onDateChanged(newDate);
          }
        },        itemBuilder: (context, pageIndex) {
          final date = _getDateForPage(pageIndex);
          final isToday = _isToday(date);
          final schedulesForDate = _getSchedulesForDate(date);
          final tasksForDate = _getTasksForDate(date);

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  if (isToday) ...[
                    Text(
                      'Hari ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    _formatDateHeader(date),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF5263F3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Schedule list and tasks or empty state
                  if (schedulesForDate.isEmpty && tasksForDate.isEmpty)
                    _buildEmptyState()
                  else ...[
                    // Display schedules first
                    ...schedulesForDate.map(_buildScheduleCard),
                    // Then display tasks
                    ...tasksForDate.map(_buildTaskCard),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}