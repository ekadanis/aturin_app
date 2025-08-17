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

  final void Function(String)? onShowSuccess;
  final List<Map<String, dynamic>>? sectionTimeConfig;
  
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
    this.onShowSuccess,
    this.sectionTimeConfig,
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
      animationStyle: 'scale',
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
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutQuart,
        )
        .then((_) {
          if (mounted) {
            _isPageChanging = false;
            _currentPageIndex = targetPageIndex;
          }
        });
  }

  DateTime _getDateForPage(int pageIndex) {
    final daysDifference = pageIndex - _initialPageIndex;
    return _baseDate.add(Duration(days: daysDifference));
  }  

  List<AktivitasModel> _getSchedulesForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final filteredSchedules = widget.schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.activityDate.year,
        schedule.activityDate.month,
        schedule.activityDate.day,
      );

      bool categoryMatch = widget.selectedCategory == 'Semua';
      if (!categoryMatch) {
        final categoryName = schedule.activityCategory.displayName;
        categoryMatch = categoryName == widget.selectedCategory;
      }
      
      bool dateMatch = scheduleDate.isAtSameMomentAs(normalizedDate);

      return categoryMatch && dateMatch;
    }).toList();


    return filteredSchedules;
  }  

  List<Task> _getTasksForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final filteredTasks = widget.tasks.where((task) {
      final taskDate = DateTime(
        task.deadline.year,
        task.deadline.month,
        task.deadline.day,
      );

      bool categoryMatch = widget.selectedCategory == 'Semua';
      if (!categoryMatch) {
        final categoryOption = CategoryHelper.getCategoryOptionFromString(task.category);
        categoryMatch = categoryOption.name == widget.selectedCategory;
      }
      
      bool dateMatch = taskDate.isAtSameMomentAs(normalizedDate);

      return categoryMatch && dateMatch;
    }).toList();


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
    );    

    if (isAnimating) {
      return _animator.buildAnimatedItem(schedule, activityCard);
    } else {
      return activityCard;
    }
  }

  Widget _buildAnimatedTaskCard(Task task, List<Task> tasksForDate) {
    final isAnimating = _isAnimating && _animatingItem == task;
    
    final taskCard = TaskCardHomepage(
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
    );    

    if (isAnimating) {
      return _animator.buildAnimatedItem(task, taskCard);
    } else {
      return taskCard;
    }
  }

  Future<void> _handleDeleteAktivitas(AktivitasModel aktivitas) async {
    try {
      setState(() {
        _animatingItem = aktivitas;
        _isAnimating = true;
      });

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

  // FIXED: Improved time extraction for activities and tasks
  DateTime _getEffectiveDateTime(dynamic item, DateTime fallbackDate) {
    if (item is AktivitasModel) {
      // Check if activity has proper time information
      final activityDate = item.activityDate;
      
      // If time is 00:00:00, it likely means we need to extract time from separate fields
      if (activityDate.hour == 0 && activityDate.minute == 0 && activityDate.second == 0) {
        // Check if activity model has separate startTime and endTime fields
        // You might need to adjust this based on your actual AktivitasModel structure
        
        // For now, let's try to use the date but with a reasonable default time
        // You should modify this to use actual start time from your model
        
        // If your AktivitasModel has startTime field, use it like:
        // if (item.startTime != null) {
        //   return DateTime(
        //     activityDate.year,
        //     activityDate.month, 
        //     activityDate.day,
        //     item.startTime!.hour,
        //     item.startTime!.minute,
        //   );
        // }
        
        return activityDate; // Use as-is for now
      }
      
      return activityDate;
    } else if (item is Task) {
      return item.deadline;
    }
    
    return fallbackDate;
  }

  // FIXED: Improved section time checking
  int getSectionIndex(DateTime time) {
    final config = widget.sectionTimeConfig ?? [
      {'label': 'Pagi', 'start': 5, 'end': 10},
      {'label': 'Siang', 'start': 11, 'end': 14}, 
      {'label': 'Sore', 'start': 15, 'end': 18},
      {'label': 'Malam', 'start': 19, 'end': 4},
    ];
    
    final hour = time.hour;
    
    
    for (int i = 0; i < config.length; i++) {
      final start = config[i]['start'] as int;
      final end = config[i]['end'] as int;
      final label = config[i]['label'] as String;
      
      
      bool isInRange = false;
      
      if (start <= end) {
        // Normal range (e.g., 5-10, 11-14, 15-18)
        isInRange = hour >= start && hour <= end;
      } else {
        // Overnight range (e.g., 19-4) - crosses midnight
        isInRange = hour >= start || hour <= end;
      }
      
      if (isInRange) {
        return i;
      }
    }
    
    return 0; // Default to first section instead of -1
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.sectionTimeConfig ?? [
      {'label': 'Pagi', 'start': 5, 'end': 10},
      {'label': 'Siang', 'start': 11, 'end': 14},
      {'label': 'Sore', 'start': 15, 'end': 18},
      {'label': 'Malam', 'start': 19, 'end': 4},
    ];

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

        // Create items with improved time handling
        List<Map<String, dynamic>> allItems = [
          ...schedulesForDate.map((a) => {
                'type': 'aktivitas',
                'data': a,
                // Gunakan activityStartTime jika ada, fallback ke activityDate
                'time': (a.activityStartTime != null) ? a.activityStartTime : a.activityDate,
              }),
          ...tasksForDate.map((t) => {
                'type': 'task', 
                'data': t,
                'time': _getEffectiveDateTime(t, date),
              }),
        ];
        
        for (var item in allItems) {
          final DateTime time = item['time'] as DateTime;
          final String type = item['type'] as String;
          final dynamic data = item['data'];
          
          if (type == 'aktivitas') {
            final aktivitas = data as AktivitasModel;
          } else {
            final task = data as Task;
          }
        }

        // Sort by time
        allItems.sort((a, b) => (a['time'] as DateTime).compareTo(b['time'] as DateTime));

        // Group items by time sections
        List<List<Map<String, dynamic>>> sectioned = List.generate(config.length, (_) => []);
        for (final item in allItems) {
          final sectionIdx = getSectionIndex(item['time'] as DateTime);
          if (sectionIdx >= 0 && sectionIdx < config.length) {
            sectioned[sectionIdx].add(item);
          }
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(4),
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
                
                // Sectioned content
                for (int i = 0; i < config.length; i++) ...[
                  if (sectioned[i].isNotEmpty) ...[
                    // Section divider
                    Row(
                      children: [
                        const Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            config[i]['label'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Items in this section
                    ...sectioned[i].map((item) {
                      if (item['type'] == 'aktivitas') {
                        return _buildAnimatedActivityCard(item['data'], schedulesForDate);
                      } else {
                        return _buildAnimatedTaskCard(item['data'], tasksForDate);
                      }
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                ],
                
                // Empty state
                if (allItems.isEmpty) _buildEmptyState(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }
}