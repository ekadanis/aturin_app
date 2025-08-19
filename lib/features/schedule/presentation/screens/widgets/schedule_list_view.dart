import 'package:flutter/material.dart';
import 'package:aturin_app/features/schedule/data/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/data/model/task_model.dart';
import 'package:aturin_app/features/schedule/presentation/services/schedule_api_service.dart';
import 'package:aturin_app/features/schedule/presentation/screens/detail_task/ui/screens/task_detail_list_screen.dart';
import 'package:alarm/alarm.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/shared/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/shared/core/services/api/task/task_api_service.dart';
import '../aktivitas_screen/widgets/activity_card.dart';
import '../aktivitas_screen/widgets/task_card.dart';
import 'schedule_animator.dart';
import 'package:lottie/lottie.dart';

class ScheduleListView extends StatefulWidget {
  final void Function(String)? onShowSuccess;
  final void Function(AktivitasModel)? onTapAktivitas;
  final void Function(Task)? onTapTask;
  final DateTime selectedDate;
  final String currentFilter;
  final String animationStyle;

  const ScheduleListView({
    Key? key,
    this.onShowSuccess,
    this.onTapAktivitas,
    this.onTapTask,
    required this.selectedDate,
    required this.currentFilter,
    this.animationStyle = "slide",
  }) : super(key: key);

  @override
  State<ScheduleListView> createState() => _ScheduleListViewState();
}

class _ScheduleListViewState extends State<ScheduleListView>
    with TickerProviderStateMixin {
  late ScheduleAnimator _animator;
  String? _animatingItemSlug;
  bool _isAnimating = false;

  List<AktivitasModel> _aktivitasList = [];
  List<Task> _tasksList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animator = ScheduleAnimator(
      vsync: this,
      animationStyle: widget.animationStyle,
    );
    _fetchSchedule();
  }

  Future<void> _fetchSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final scheduleData = await ScheduleApiService().getScheduleByDate(widget.selectedDate);
      
      setState(() {
        _aktivitasList = scheduleData['aktivitas'] ?? [];
        _tasksList = scheduleData['tasks'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat jadwal';
        _isLoading = false;
      });
    }
  }

  @override
  void didUpdateWidget(ScheduleListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate || 
        widget.currentFilter != oldWidget.currentFilter) {
      _fetchSchedule();
    }
    if (widget.animationStyle != oldWidget.animationStyle) {
      _animator.updateAnimationStyle(widget.animationStyle);
    }
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  List<AktivitasModel> get _filteredAktivitas {
    if (widget.currentFilter == 'Semua') return _aktivitasList;
    return _aktivitasList.where((aktivitas) => 
      aktivitas.activityCategory.displayName == widget.currentFilter
    ).toList();
  }

  List<Task> get _filteredTasks {
    if (widget.currentFilter == 'Semua') return _tasksList;
    return _tasksList.where((task) => 
      task.category == widget.currentFilter
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    
    final filteredAktivitas = _filteredAktivitas;
    final filteredTasks = _filteredTasks;
    
    if (filteredAktivitas.isEmpty && filteredTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/icons/NoData.json',
              height: 150,
              width: 150,
              fit: BoxFit.contain,
              repeat: true,
              animate: true,
            ),
            const SizedBox(height: 16),
            Text('Tidak ada jadwal untuk hari ini'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 0, bottom: 80),
      children: [
        // Aktivitas List
        ...filteredAktivitas.map((aktivitas) => _buildAktivitasCard(aktivitas)),
        
        // Tasks List
        ...filteredTasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  Widget _buildAktivitasCard(AktivitasModel aktivitas) {
    final isAnimating = _animatingItemSlug == aktivitas.slug && _isAnimating;
    
    Widget card = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Hero(
        tag: 'aktivitas-${aktivitas.id}',
        child: ActivityCard(
          activity: aktivitas,
          onTap: () => widget.onTapAktivitas?.call(aktivitas),
          onEdit: () {
            // Handle edit - navigate to edit screen
            widget.onTapAktivitas?.call(aktivitas);
          },
          onDelete: () async {
            // Following TaskService delete pattern
            setState(() {
              _animatingItemSlug = aktivitas.slug;
              _isAnimating = true;
            });
            
            final aktivitasSlug = aktivitas.slug;            
            try {
              _animator.prepareItemDeletion(
                aktivitas, 
                () async {
                  // Delete alarm if exists - same as TaskService
                  if (aktivitas.alarmId != null) {
                    try {
                      await Alarm.stop(aktivitas.alarmId!);
                    } catch (e) {
                    }
                  }
                  
                  // Use Provider for consistent API response handling
                  if (aktivitasSlug != null && mounted) {
                    final activityApiService = Provider.of<ActivityApiService>(context, listen: false);
                    final success = await activityApiService.deleteActivity(aktivitasSlug);
                    
                    if (success && mounted) {
                      // Refresh data and notify parent with success message
                      await _fetchSchedule();
                      widget.onShowSuccess?.call('Aktivitas berhasil dihapus');
                    } else if (mounted) {
                      widget.onShowSuccess?.call('Gagal menghapus aktivitas');
                    }
                  }
                },
                () {
                  // Animation completion callback
                  if (mounted) {
                    setState(() {
                      _isAnimating = false;
                      _animatingItemSlug = null;
                    });
                  }
                },
              );
            } catch (e) {
              if (mounted) {
                setState(() {
                  _animatingItemSlug = null;
                  _isAnimating = false;
                });
                widget.onShowSuccess?.call('Gagal menghapus aktivitas: ${e.toString()}');
              }
            }
          },
        ),
      ),
    );    if (isAnimating) {
      return _animator.buildAnimatedItem(aktivitas, card);
    }
    
    return card;
  }

  Widget _buildTaskCard(Task task) {
    final isAnimating = _animatingItemSlug == task.slug && _isAnimating;
    
    Widget card = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Hero(
        tag: 'task-${task.id}',
        child: TaskCardHomepage(
          task: task,
          currentFilter: widget.currentFilter,
          showCheckbox: false, // Schedule context doesn't support completion
          onToggleCompletion: () {}, // Empty - no completion in schedule context
          onTap: () {
            // Navigate to TaskDetailListScreen with all tasks for the date
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskDetailListScreen(
                  tasks: _filteredTasks,
                  initialIndex: _filteredTasks.indexOf(task),
                ),
              ),
            );
          },
          onDelete: () async {
            // Following TaskService delete pattern
            setState(() {
              _animatingItemSlug = task.slug;
              _isAnimating = true;
            });
            
            final taskSlug = task.slug;            
            try {
              _animator.prepareItemDeletion(
                task, 
                () async {
                  // Delete alarm if exists - same as TaskService
                  if (task.alarmId != null) {
                    try {
                      await Alarm.stop(task.alarmId!);
                    } catch (e) {
                    }
                  }
                  
                  // Use Provider for consistent API response handling
                  if (taskSlug != null && mounted) {
                    final taskApiService = Provider.of<TaskApiService>(context, listen: false);
                    final result = await taskApiService.deleteTask(taskSlug);
                    
                    if (result.isSuccess && mounted) {
                      // Refresh data and notify parent with API response message
                      await _fetchSchedule();
                      widget.onShowSuccess?.call(result.message);
                    } else if (mounted) {
                      widget.onShowSuccess?.call(result.message);
                    }
                  }
                },
                () {
                  // Animation completion callback
                  if (mounted) {
                    setState(() {
                      _isAnimating = false;
                      _animatingItemSlug = null;
                    });
                  }
                },
              );
            } catch (e) {
              if (mounted) {
                setState(() {
                  _animatingItemSlug = null;
                  _isAnimating = false;
                });
                widget.onShowSuccess?.call('Gagal menghapus tugas: ${e.toString()}');
              }
            }
          },
        ),
      ),
    );    if (isAnimating) {
      return _animator.buildAnimatedItem(task, card);
    }
    
    return card;
  }
}
