import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:alarm/alarm.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../model/task_model.dart';
import 'task_card.dart';
import '../../../../core/widgets/custom_snackbar_top.dart';
import 'task_animator.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

class TaskListView extends StatefulWidget {
  final void Function(String)? onShowSuccess;
  final void Function(Task)? onTapTask;
  final String currentFilter;
  final String animationStyle;

  const TaskListView({
    Key? key,
    this.onShowSuccess,
    this.onTapTask,
    required this.currentFilter,
    this.animationStyle = "slide",
  }) : super(key: key);

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView>
    with TickerProviderStateMixin {
  late TaskAnimator _animator;
  int? _animatingTaskId;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animator = TaskAnimator(
      vsync: this,
      animationStyle: widget.animationStyle,
    );
    // Remove automatic fetch here since it's already handled by parent (TaskListScreen)
    // Fetch initial data should be handled by parent component to avoid duplicate API calls
  }

  @override
  void didUpdateWidget(TaskListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationStyle != oldWidget.animationStyle) {
      _animator.updateAnimationStyle(widget.animationStyle);
    }
  }

  // Filter tasks based on current filter
  List<Task> _filterTasks(List<Task> allTasks) {
    final now = DateTime.now();

    if (widget.currentFilter == 'Semua') {
      List<Task> tasks = List.from(allTasks);
      tasks.sort(_compareTasksByPriority);
      return tasks;
    } else if (widget.currentFilter == 'Terlambat') {
      final filtered =
          allTasks
              .where((task) => task.deadline.isBefore(now) && !task.isCompleted)
              .toList();
      return filtered;
    } else if (widget.currentFilter == 'Belum Selesai') {
      // Hanya tampilkan tugas yang belum selesai DAN tidak terlambat
      final filtered =
          allTasks
              .where(
                (task) => !task.isCompleted && !task.deadline.isBefore(now),
              )
              .toList()
            ..sort((a, b) => a.deadline.compareTo(b.deadline));
      return filtered;
    } else if (widget.currentFilter == 'Selesai') {
      final filtered = allTasks.where((task) => task.isCompleted).toList();
      return filtered;
    }
    return [];
  }

  // Task sorting method based on priority order:
  // 1. Hari ini (Today)
  // 2. Besok (Tomorrow)
  // 3. Upcoming (Future tasks)
  // 4. Terlambat (Overdue) - hanya untuk filter "Semua"
  // 5. Selesai (Completed)
  int _compareTasksByPriority(Task a, Task b) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get priority for each task
    final priorityA = _getTaskPriority(a, today, now);
    final priorityB = _getTaskPriority(b, today, now);

    // Sort by priority first
    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB);
    }

    // Within same priority, sort by deadline (earliest first)
    return a.deadline.compareTo(b.deadline);
  }

  int _getTaskPriority(Task task, DateTime today, DateTime now) {
    // Completed tasks have lowest priority (5)
    if (task.isCompleted) return 5;

    final taskDate = DateTime(
      task.deadline.year,
      task.deadline.month,
      task.deadline.day,
    );

    // Today's tasks have highest priority (1)
    if (taskDate.isAtSameMomentAs(today)) return 1;

    // Tomorrow's tasks have priority 2
    final tomorrow = today.add(const Duration(days: 1));
    if (taskDate.isAtSameMomentAs(tomorrow)) return 2;

    // Future tasks have priority 3
    if (taskDate.isAfter(today)) return 3;

    // Overdue tasks have priority 4 (hanya untuk filter "Semua")
    if (taskDate.isBefore(today)) return 4;

    return 3; // default untuk upcoming
  }

  @override
  void dispose() {
    _animator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskApiService>(
      builder: (context, taskApiService, child) {
        // Debug: Log tasks data setiap rebuild

        // Get filtered tasks
        final filteredTasks = _filterTasks(taskApiService.tasks);

        // Show loading when initially loading and no cached data
        if (taskApiService.isLoading && taskApiService.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Show empty state
        if (filteredTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/icons/NoData.json',
                  height: 22.h,
                  width: 22.h,
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
                const SizedBox(height: 8),
                Text(
                  "Tidak ada Tugas",
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          );
        }

        // Reset animation if task no longer exists
        if (_isAnimating &&
            !filteredTasks.any((t) => t.id == _animatingTaskId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _isAnimating = false;
                _animatingTaskId = null;
              });
            }
          });
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 0, bottom: 80),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            final isAnimating = _animatingTaskId == task.id && _isAnimating;
            if (isAnimating) {
              return _animator.buildAnimatedTask(
                task,
                _buildTaskCard(task),
                onAnimationComplete: () {
                  setState(() {
                    if (_animatingTaskId == task.id) {
                      _isAnimating = false;
                      _animatingTaskId = null;
                    }
                  });
                },
              );
            } else {
              return _buildTaskCard(task);
            }
          },
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    final isSelesai =
        widget.currentFilter == 'Selesai' ||
        (widget.currentFilter == 'Semua' && task.isCompleted);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Hero(
        tag: 'task-${task.id}',
        child: TaskCard(
          task: task,
          currentFilter: widget.currentFilter,
          removeMargin: true,
          showCheckbox: !isSelesai,

          onToggleCompletion:
              isSelesai
                  ? () {}
                  : () async {
                    setState(() {
                      _animatingTaskId = task.id;
                      _isAnimating = true;
                    });

                    try {
                      final taskApiService = Provider.of<TaskApiService>(
                        context,
                        listen: false,
                      );

                      // Use updateTask method with status change
                      final newStatus =
                          task.isCompleted ? 'belum_selesai' : 'selesai';
                      final result = await taskApiService.updateTask(
                        slug: task.slug!,
                        status: newStatus,
                      );

                      if (!mounted) return;

                      if (result.isSuccess) {
                        // Stop alarm if task is completed
                        if (!task.isCompleted && task.alarmId != null) {
                          try {
                            await Alarm.stop(task.alarmId!);
                          } catch (e) {}
                        }

                        // Success - trigger refresh via callback (sama seperti aktivitas)
                        if (widget.onShowSuccess != null) {
                          widget.onShowSuccess!(
                            'Status tugas berhasil diperbarui',
                          );
                        }

                        showCustomTopSnackbar(
                          context: context,
                          message:
                              task.isCompleted
                                  ? 'Tugas dikembalikan ke status belum selesai'
                                  : 'Tugas berhasil diselesaikan!',
                          isError: false,
                        );
                      } else {
                        showCustomTopSnackbar(
                          context: context,
                          message: result.message,
                          isError: true,
                        );
                        setState(() {
                          _isAnimating = false;
                          _animatingTaskId = null;
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        showCustomTopSnackbar(
                          context: context,
                          message: 'Terjadi kesalahan: $e',
                          isError: true,
                        );
                        setState(() {
                          _isAnimating = false;
                          _animatingTaskId = null;
                        });
                      }
                    }
                  },
          onDelete: () async {
            try {
              final taskApiService = Provider.of<TaskApiService>(
                context,
                listen: false,
              );

              // Actually delete the task first
              final result = await taskApiService.deleteTask(task.slug!);

              if (!mounted) return;

              if (result.isSuccess) {
                // Success - trigger refresh via callback (sama seperti aktivitas)
                if (widget.onShowSuccess != null) {
                  widget.onShowSuccess!(result.message);
                }
              } else {
                // Error - show error message
                showCustomTopSnackbar(
                  context: context,
                  message: result.message,
                  isError: true,
                );
              }
            } catch (e) {
              if (mounted) {
                showCustomTopSnackbar(
                  context: context,
                  message: 'Gagal menghapus tugas: $e',
                  isError: true,
                );
              }
            }
          },
          onViewDetails: () {
            if (widget.onTapTask != null) {
              widget.onTapTask!(task);
            }
          },
          onToggleAlarm: () async {
            try {
              final taskApiService = Provider.of<TaskApiService>(
                context,
                listen: false,
              );
              await taskApiService.fetchTasks(forceRefresh: true);

              // Success - trigger refresh via callback (sama seperti aktivitas)
              if (widget.onShowSuccess != null) {
                widget.onShowSuccess!('Alarm berhasil diperbarui');
              }
            } catch (e) {}
          },
        ),
      ),
    );
  }
}
