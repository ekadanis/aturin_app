import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/home/widget/empty_task.dart';
import 'activity_card.dart';
import 'task_card.dart';
import 'package:intl/intl.dart';
import 'package:aturin_app/features/jadwal/screens/detailactivity/ui/activity_detail_list.dart';
import 'package:sizer/sizer.dart';

class InfiniteScheduleListWidget extends StatefulWidget {
  final DateTime selectedDate;
  final List<AktivitasModel> schedules;
  final List<Task> tasks;
  final String selectedCategory;
  final Function(DateTime) onDateChanged;
  final Function(AktivitasModel)? onEditSchedule;
  final Function(AktivitasModel)? onDeleteSchedule;
  final Function(Task)? onEditTask;
  final Function(Task)? onDeleteTask;
  final Function(Task)? onToggleTaskCompletion;

  const InfiniteScheduleListWidget({
    super.key,
    required this.selectedDate,
    required this.schedules,
    required this.tasks,
    required this.selectedCategory,
    required this.onDateChanged,
    this.onEditSchedule,
    this.onDeleteSchedule,
    this.onEditTask,
    this.onDeleteTask,
    this.onToggleTaskCompletion,
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
  }

  List<Task> _getTasksForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    
    return widget.tasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );
      
      bool categoryMatch = widget.selectedCategory == 'Semua' ||
          task.category == widget.selectedCategory;
      bool dateMatch = taskDate.isAtSameMomentAs(normalizedDate);
      
      return categoryMatch && dateMatch;
    }).toList();
  }

  String _formatDateHeader(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.isAtSameMomentAs(today);  }

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
        },
        itemBuilder: (context, pageIndex) {
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
                    ...schedulesForDate.map((schedule) => ActivityCard(
                      activity: schedule,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ActivityDetailListPage(
                              activities: schedulesForDate,
                              initialIndex: schedulesForDate.indexOf(schedule),
                            ),
                          ),
                        );
                      },
                      onEdit: widget.onEditSchedule != null
                          ? () => widget.onEditSchedule!(schedule)
                          : null,
                      onDelete: widget.onDeleteSchedule != null
                          ? () => widget.onDeleteSchedule!(schedule)
                          : null,
                    )),                    // Then display tasks
                    ...tasksForDate.map((task) => TaskCard(
                      task: task,
                      onToggleCompletion: widget.onToggleTaskCompletion != null
                          ? () => widget.onToggleTaskCompletion!(task)
                          : () {},
                      onDelete: widget.onDeleteTask != null
                          ? () => widget.onDeleteTask!(task)
                          : () {},
                      onViewDetails: () {
                        // Handle view details if needed
                      },
                      onToggleAlarm: () {
                        // Handle toggle alarm if needed
                      },
                      currentFilter: widget.selectedCategory,
                      showCheckbox: false,
                      showStatus: true,
                      margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 0),
                    )),
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