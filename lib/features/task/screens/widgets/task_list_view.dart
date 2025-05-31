import 'package:flutter/material.dart';
import 'package:aturin_app/core/services/api/task/task_service.dart';
import 'package:aturin_app/core/services/api/alarm/alarm_api_service.dart';
import 'package:alarm/alarm.dart';
import '../../model/task_model.dart';
import 'task_card.dart';
import 'snackbar.dart';
import 'task_animator.dart';
import 'package:provider/provider.dart';

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

  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animator = TaskAnimator(
      vsync: this,
      animationStyle: widget.animationStyle,
    );
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final taskService = Provider.of<TaskService>(context, listen: false);
      List<Task> filteredTasks = [];

      if (widget.currentFilter == 'Hari Ini') {
        filteredTasks = await taskService.getTasksToday();
      } else if (widget.currentFilter == 'Terlambat') {
        final data = await taskService.getTasksByStatus('terlambat');
        filteredTasks = data != null && data['tasks'] != null
            ? List<Task>.from(data['tasks'].map((e) => Task.fromMap(e)))
            : [];
      } else if (widget.currentFilter == 'Belum Selesai') {
        final data = await taskService.getTasksByStatus('belum_selesai');
        filteredTasks = data != null && data['tasks'] != null
            ? List<Task>.from(data['tasks'].map((e) => Task.fromMap(e)))
            : [];
      } else if (widget.currentFilter == 'Selesai') {
        final data = await taskService.getTasksByStatus('selesai');
        filteredTasks = data != null && data['tasks'] != null
            ? List<Task>.from(data['tasks'].map((e) => Task.fromMap(e)))
            : [];
      } else {
        // Semua
        await taskService.fetchTasks();
        filteredTasks = taskService.tasks;
      }

      // Setelah dapat filteredTasks, urutkan berdasarkan deadline
      filteredTasks.sort((a, b) {
        final pa = _taskPriority(a);
        final pb = _taskPriority(b);
        if (pa != pb) return pa.compareTo(pb);
        // Jika prioritas sama, urutkan berdasarkan jam deadline
        return a.deadline.compareTo(b.deadline);
      });

      setState(() {
        _tasks = filteredTasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat tugas';
        _isLoading = false;
      });
    }
  }

  int _taskPriority(Task t) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadline = DateTime(t.deadline.year, t.deadline.month, t.deadline.day);

    if (t.taskStatus == TaskDatabaseStatus.selesai) return 1000; // Paling bawah
    if (deadline.isBefore(today)) return 900; // Terlambat, setelah semua yang akan datang

    final diff = deadline.difference(today).inDays;
    return diff; // 0: hari ini, 1: besok, 2: lusa, dst
  }

  @override
  void didUpdateWidget(covariant TaskListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentFilter != oldWidget.currentFilter) {
      _fetchTasks();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!));
    }
    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/https___lottiefiles.com_animations_no-data-bt8EDsKmcr.gif',
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }
    if (_isAnimating && !_tasks.any((t) => t.id == _animatingTaskId)) {
      _isAnimating = false;
      _animatingTaskId = null;
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 80),
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
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
  }

  Widget _buildTaskCard(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Hero(
        tag: 'task-${task.id}',
        child: TaskCard(
          task: task,
          currentFilter: widget.currentFilter,
          onToggleCompletion: () async {
            setState(() {
              _animatingTaskId = task.id;
              _isAnimating = true;
            });
            _animator.prepareTaskAnimation(task, task.taskStatus != TaskDatabaseStatus.selesai);
            try {
              final taskService = Provider.of<TaskService>(context, listen: false);
              final newStatus = task.taskStatus == TaskDatabaseStatus.selesai
                  ? 'belum_selesai'
                  : 'selesai';
              await taskService.updateTask(
                slug: task.slug!,
                status: newStatus,
              );
              setState(() {
                final idx = _tasks.indexWhere((t) => t.id == task.id);
                if (idx != -1) {
                  _tasks[idx] = _tasks[idx].copyWith(
                    taskStatus: newStatus == 'selesai'
                        ? TaskDatabaseStatus.selesai
                        : TaskDatabaseStatus.belumSelesai,
                  );
                }
                // Urutkan ulang berdasarkan prioritas
                _tasks.sort((a, b) {
                  final pa = _taskPriority(a);
                  final pb = _taskPriority(b);
                  if (pa != pb) return pa.compareTo(pb);
                  return a.deadline.compareTo(b.deadline);
                });
                _isAnimating = false;
                _animatingTaskId = null;
              });
              showCustomTopSnackbar(
                context: context,
                message: task.taskStatus != TaskDatabaseStatus.selesai
                    ? 'Berhasil Menyelesaikan Tugas'
                    : 'Tugas kembali ke status awal',
              );
            } catch (e) {
              showCustomTopSnackbar(
                context: context,
                message: 'Gagal mengubah status tugas',
              );
            }
          },
          onDelete: () async {
            setState(() {
              _animatingTaskId = task.id;
              _isAnimating = true;
            });
            final taskSlug = task.slug;
            try {
              final taskService = Provider.of<TaskService>(context, listen: false);
              _animator.prepareTaskDeletion(task, () async {
                // Hapus alarm jika ada
                if (task.alarmId != null) {
                  try {
                    // Hapus alarm lokal
                    await Alarm.stop(task.alarmId!);
                  } catch (e) {
                    debugPrint('Gagal menghapus alarm lokal: $e');
                  }
                  try {
                    // Ambil data alarm dari server lalu hapus berdasarkan slug
                    final alarm = await AlarmApiService().getAlarmById(
                      task.alarmId!,
                    );
                    if (alarm != null && alarm.slug.isNotEmpty) {
                      await AlarmApiService().deleteAlarm(alarm.slug);
                    }
                  } catch (e) {
                    debugPrint('Gagal menghapus alarm di backend: $e');
                  }
                }
                if (taskSlug != null) {
                  await taskService.deleteTask(taskSlug);
                  await _fetchTasks();
                  showCustomTopSnackbar(
                    context: context,
                    message: 'Berhasil menghapus tugas',
                  );
                }
                if (mounted) {
                  setState(() {
                    if (_animatingTaskId == task.id) {
                      _isAnimating = false;
                      _animatingTaskId = null;
                    }
                  });
                }
              });
            } catch (e) {
              debugPrint('Error menghapus task: $e');
              if (mounted) {
                setState(() {
                  _isAnimating = false;
                  _animatingTaskId = null;
                });
                showCustomTopSnackbar(
                  context: context,
                  message: 'Gagal menghapus tugas, coba lagi',
                );
              }
            }
          },
          onViewDetails: () {
            widget.onTapTask?.call(task);
          },
          onToggleAlarm: () async {
            try {
              final taskService = Provider.of<TaskService>(context, listen: false);
              // Toggle alarm using updateTask (e.g., set alarmId to null or to a value)
              final newAlarmId = task.isAlarmEnabled ? null : task.alarmId;
              await taskService.updateTask(
                slug: task.slug!,
                alarmId: newAlarmId,
              );
              await _fetchTasks();
              showCustomTopSnackbar(
                context: context,
                message: 'Alarm tugas diperbarui',
              );
            } catch (e) {
              showCustomTopSnackbar(
                context: context,
                message: 'Gagal memperbarui alarm',
              );
            }
          },
        ),
      ),
    );
  }
}
