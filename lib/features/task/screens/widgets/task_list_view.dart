import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/task_model.dart';
import '../../services/task_services.dart';
import 'task_card.dart';
import 'snackbar.dart';
import 'task_animator.dart';

class TaskListView extends StatefulWidget {
  final List<Task> tasks;
  final void Function(String)? onShowSuccess;
  final void Function(Task)? onTapTask;
  final String currentFilter;
  
  // Parameter untuk gaya animasi
  final String animationStyle;

  const TaskListView({
    Key? key,
    required this.tasks,
    this.onShowSuccess,
    this.onTapTask,
    required this.currentFilter,
    this.animationStyle = "slide",
  }) : super(key: key);

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> with TickerProviderStateMixin {
  // Animator untuk mengelola animasi
  late TaskAnimator _animator;
  
  // Track task yang sedang dianimasikan
  int? _animatingTaskId;
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    _animator = TaskAnimator(
      vsync: this,
      animationStyle: widget.animationStyle,
    );
  }
  
  @override
  void didUpdateWidget(TaskListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update animator jika gaya animasi berubah
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
    if (widget.tasks.isEmpty) {
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

    // Reset animation state when tasks list changes (like when switching tabs)
    if (_isAnimating && !widget.tasks.any((t) => t.id == _animatingTaskId)) {
      // If the currently animating task is no longer in the list, reset animation state
      _isAnimating = false;
      _animatingTaskId = null;
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 0, bottom: 80), // Reduced top padding to move list higher
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        
        // Cek apakah task ini sedang dianimasikan
        final isAnimating = _animatingTaskId == task.id && _isAnimating;
        
        if (isAnimating) {
          // Widget dengan animasi custom
          return _animator.buildAnimatedTask(
            task, 
            _buildTaskCard(task),
            onAnimationComplete: () {
              // Reset flag animasi setelah selesai
              setState(() {
                if (_animatingTaskId == task.id) {
                  _isAnimating = false;
                  _animatingTaskId = null;
                }
              });
            }
          );
        } else {
          // Widget tanpa animasi
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
          onToggleCompletion: () {
            // Set flag untuk animasi
            setState(() {
              _animatingTaskId = task.id;
              _isAnimating = true;
            });
            
            // Mulai animasi
            _animator.prepareTaskAnimation(task, !task.isCompleted);
            
            // Toggle status task di provider
            final taskService = Provider.of<TaskService>(
              context,
              listen: false,
            );
            taskService.toggleTaskCompletion(task.id);

            if (!task.isCompleted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Berhasil Menyelesaikan Tugas',
              );
            } else {
              showCustomTopSnackbar(
                context: context,
                message: 'Tugas kembali ke status awal',
              );
            }
          },
          onDelete: () async {
            // Set flag untuk animasi
            setState(() {
              _animatingTaskId = task.id;
              _isAnimating = true;
            });
            
            // Simpan ID task sebelum dihapus untuk menangani race condition
            final taskId = task.id;
            
            try {
              // Mulai animasi hapus
              _animator.prepareTaskDeletion(task, () async {
                // Hapus task dari provider setelah animasi selesai
                // Gunakan await untuk memastikan operasi database selesai
                if (taskId != null) {
                  await Provider.of<TaskService>(
                    context,
                    listen: false,
                  ).deleteTask(taskId);
                  
                  // Tampilkan notifikasi hanya jika penghapusan berhasil
                  showCustomTopSnackbar(
                    context: context,
                    message: 'Berhasil menghapus tugas',
                  );
                }
                
                // Reset flag animasi setelah operasi database selesai
                if (mounted) {
                  setState(() {
                    if (_animatingTaskId == taskId) {
                      _isAnimating = false;
                      _animatingTaskId = null;
                    }
                  });
                }
              });
            } catch (e) {
              // Tangani error dan reset state animasi
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
          onToggleAlarm: () {
            Provider.of<TaskService>(
              context,
              listen: false,
            ).toggleAlarm(task.id);
          },
        ),
      ),
    );
  }
}