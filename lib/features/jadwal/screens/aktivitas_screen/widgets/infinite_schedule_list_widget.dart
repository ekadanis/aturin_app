import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/core/utils/category_helper.dart';
import 'activity_card.dart';
import 'task_card.dart';
import 'package:intl/intl.dart';
import 'package:aturin_app/features/jadwal/screens/detailactivity/ui/activity_detail_list.dart';
import 'package:aturin_app/features/jadwal/screens/detail_task/ui/screens/task_detail_list_screen.dart';
import 'package:sizer/sizer.dart';
import '../../../services/schedule_api_service.dart';
import '../../widgets/schedule_animator.dart';

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

  final void Function(String)? onShowSuccess; // Add callback like TaskService
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
    // NOTE: onToggleTaskCompletion removed - schedule context doesn't support completion
    this.onShowSuccess, // Add this
  });

  @override
  State<InfiniteScheduleListWidget> createState() =>
      _InfiniteScheduleListWidgetState();
}

class _InfiniteScheduleListWidgetState
    extends State<InfiniteScheduleListWidget> with TickerProviderStateMixin {
  late PageController _pageController;
  late DateTime _baseDate;
  late ScheduleAnimator _animator;

  static const int _initialPageIndex = 100000;
  int _currentPageIndex = _initialPageIndex;
  bool _isPageChanging = false;
  
  // Animation tracking
  dynamic _animatingItem;
  bool _isAnimating = false;

  // Service instance
  final ScheduleApiService _scheduleService = ScheduleApiService();
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
    
    // Initialize animator
    _animator = ScheduleAnimator(
      vsync: this,
      animationStyle: 'scale', // Default animation style
    );
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
    _animator.dispose();
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
  }  List<AktivitasModel> _getSchedulesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final filteredSchedules = widget.schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.activityDate.year,
        schedule.activityDate.month,
        schedule.activityDate.day,
      );

      bool categoryMatch = widget.selectedCategory == 'Semua';
      if (!categoryMatch) {
        // Konversi ActivityCategory enum ke CategoryOption name untuk perbandingan yang konsisten
        final categoryName = schedule.activityCategory.displayName;
        categoryMatch = categoryName == widget.selectedCategory;
      }
      
      bool dateMatch = scheduleDate.isAtSameMomentAs(normalizedDate);

      return categoryMatch && dateMatch;
    }).toList();

    // Debug logging
    print('📋 InfiniteScheduleList - Schedule filtering for ${date.toString().split(' ')[0]}:');
    print('   Total schedules available: ${widget.schedules.length}');
    print('   Selected category: ${widget.selectedCategory}');
    print('   Filtered schedules: ${filteredSchedules.length}');
    if (filteredSchedules.isNotEmpty) {
      for (final schedule in filteredSchedules) {
        print('   - ${schedule.activityTitle} (${schedule.activityCategory.displayName}) on ${schedule.activityDate.toString().split(' ')[0]}');
      }
    }

    return filteredSchedules;
  }  List<Task> _getTasksForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final filteredTasks = widget.tasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );

      bool categoryMatch = widget.selectedCategory == 'Semua';
      if (!categoryMatch) {
        // Konversi task category string ke CategoryOption name untuk perbandingan yang konsisten
        final categoryOption = CategoryHelper.getCategoryOptionFromString(task.category);
        categoryMatch = categoryOption.name == widget.selectedCategory;
      }
      
      bool dateMatch = taskDate.isAtSameMomentAs(normalizedDate);

      return categoryMatch && dateMatch;
    }).toList();

    // Debug logging
    print('📋 InfiniteScheduleList - Task filtering for ${date.toString().split(' ')[0]}:');
    print('   Total tasks available: ${widget.tasks.length}');
    print('   Selected category: ${widget.selectedCategory}');
    print('   Filtered tasks: ${filteredTasks.length}');
    if (filteredTasks.isNotEmpty) {
      for (final task in filteredTasks) {
        print('   - ${task.title} (${task.category}) deadline: ${task.deadline.toString().split(' ')[0]}');
      }
    }

    return filteredTasks;
  }

  String _formatDateHeader(DateTime date) {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    return targetDate.isAtSameMomentAs(today);
  }
  Widget _buildEmptyState() {
    String message;
    String subtitle;
    
    if (widget.selectedCategory == 'Semua') {
      message = 'Tidak ada jadwal';
      subtitle = 'Belum ada aktivitas atau tugas untuk hari ini';
    } else {
      message = 'Tidak ada jadwal';
      subtitle = 'Belum ada aktivitas atau tugas kategori "${widget.selectedCategory}" untuk hari ini';
    }
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
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

  // Helper methods for building animated cards
  Widget _buildAnimatedActivityCard(AktivitasModel schedule, List<AktivitasModel> schedulesForDate) {
    final isAnimating = _isAnimating && _animatingItem == schedule;
    
    final activityCard = ActivityCard(
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
          ? () => _handleDeleteAktivitas(schedule)
          : null,
    );    if (isAnimating) {
      return _animator.buildAnimatedItem(schedule, activityCard);
    } else {
      return activityCard;
    }
  }
  Widget _buildAnimatedTaskCard(Task task, List<Task> tasksForDate) {
    final isAnimating = _isAnimating && _animatingItem == task;
    
    final taskCard = TaskCard(
      task: task,
      onToggleCompletion: () {},
      onDelete: widget.onDeleteTask != null
          ? () => _handleDeleteTask(task)
          : () {},
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TaskDetailListScreen(
              tasks: tasksForDate,
              initialIndex: tasksForDate.indexOf(task),
            ),
          ),
        );
      },
      currentFilter: widget.selectedCategory,
      showCheckbox: false,
      showStatus: true,
      margin: EdgeInsets.symmetric(
        vertical: 0.5.h,
        horizontal: 0,
      ),
    );    if (isAnimating) {
      return _animator.buildAnimatedItem(task, taskCard);
    } else {
      return taskCard;
    }
  }
  // Delete handlers with animation support
  Future<void> _handleDeleteAktivitas(AktivitasModel aktivitas) async {
    try {
      setState(() {
        _animatingItem = aktivitas;
        _isAnimating = true;
      });

      // Use ScheduleAnimator for deletion animation
      _animator.prepareItemDeletion(
        aktivitas, 
        () async {
          if (aktivitas.slug != null) {
            await _scheduleService.deleteAktivitas(aktivitas.slug!);
            widget.onShowSuccess?.call('Aktivitas berhasil dihapus');
          } else {
            throw Exception('Slug aktivitas tidak valid');
          }
        },
        () {
          // Animation completion callback
          if (mounted) {
            setState(() {
              _isAnimating = false;
              _animatingItem = null;
            });
          }
        },
      );
    } catch (e) {
      widget.onShowSuccess?.call('Gagal menghapus aktivitas');
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _animatingItem = null;
        });
      }
    }
  }
  Future<void> _handleDeleteTask(Task task) async {
    try {
      setState(() {
        _animatingItem = task;
        _isAnimating = true;
      });

      // Use ScheduleAnimator for deletion animation
      _animator.prepareItemDeletion(
        task, 
        () async {
          if (task.slug != null) {
            await _scheduleService.deleteTask(task.slug!);
            widget.onShowSuccess?.call('Tugas berhasil dihapus');
          } else {
            throw Exception('Slug tugas tidak valid');
          }
        },
        () {
          // Animation completion callback
          if (mounted) {
            setState(() {
              _isAnimating = false;
              _animatingItem = null;
            });
          }
        },
      );
    } catch (e) {
      widget.onShowSuccess?.call('Gagal menghapus tugas');
      if (mounted) {
        setState(() {
          _isAnimating = false;
          _animatingItem = null;
        });
      }
    }
  }

  // NOTE: _handleToggleTaskCompletion removed - schedule context doesn't support completion

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
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
                const SizedBox(height: 16),                // Schedule list and tasks or empty state
                if (schedulesForDate.isEmpty && tasksForDate.isEmpty)
                  _buildEmptyState()
                else ...[
                  // Debug logging
                  () {
                    print('📋 InfiniteScheduleList - Build: schedules=${schedulesForDate.length}, tasks=${tasksForDate.length} for ${date.toString().split(' ')[0]}');
                    return const SizedBox.shrink();
                  }(),
                  
                  // Display schedules first
                  ...schedulesForDate.map(
                    (schedule) => _buildAnimatedActivityCard(schedule, schedulesForDate),
                  ), 
                  // Then display tasks
                  ...tasksForDate.map(
                    (task) => _buildAnimatedTaskCard(task, tasksForDate),
                  ),
                ],
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}
