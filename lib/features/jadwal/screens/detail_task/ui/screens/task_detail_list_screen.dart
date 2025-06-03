import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../task/model/task_model.dart';
import '../widgets/task_detail_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/widgets/custom_snackbar_top.dart';
import 'package:aturin_app/routers/app_router.dart';

@RoutePage()
class TaskDetailListScreen extends StatefulWidget {
  final List<Task>? tasks;
  final int? initialIndex;

  const TaskDetailListScreen({Key? key, this.tasks, this.initialIndex})
    : super(key: key);

  @override
  State<TaskDetailListScreen> createState() => _TaskDetailListScreenState();
}

class _TaskDetailListScreenState extends State<TaskDetailListScreen> {
  late final PageController _pageController;
  int _currentPageIndex = 0;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.initialIndex ?? 0;
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _currentPageIndex,
    );
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      final newIndex = page.round();
      if (newIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newIndex;
        });
      }
    });

    _initializeTasks();
  }

  void _initializeTasks() {
    if (widget.tasks != null && widget.tasks!.isNotEmpty) {
      // Use provided tasks
      setState(() {
        _tasks = widget.tasks!;
      });
    } else {
      // Fetch tasks from API
      _fetchTasksFromAPI();
    }
  }

  Future<void> _fetchTasksFromAPI() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final taskApiService = Provider.of<TaskApiService>(
        context,
        listen: false,
      );
      await taskApiService.fetchTasks();

      setState(() {
        _tasks = taskApiService.tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat data tugas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Check if current task is completed
  bool get _isCurrentTaskCompleted {
    if (_tasks.isEmpty) return false;
    final currentTask = _tasks[_currentPageIndex];
    // Assuming the task has a status field or isCompleted field
    // Adjust this based on your Task model structure
    return currentTask.status == 'selesai' || 
           currentTask.status == 'completed' ||
           currentTask.isCompleted == true;
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchTasksFromAPI,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada tugas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        final task = _tasks[index];
        final isSelected = index == _currentPageIndex;

        return AnimatedScale(
          scale: isSelected ? 1.0 : 0.9,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: TaskDetailCard(
            task: task,
            isSelected: isSelected,
            onTap: () {
              // Handle card tap
              print('Task tapped: ${task.title}');
            },
          ),
        );
      },
    );
  }

  Future<void> _handleEditTask() async {
    if (_tasks.isEmpty || _isCurrentTaskCompleted) return;
    
    final currentTask = _tasks[_currentPageIndex];
    
    final result = await context.router.push(
      AddTaskRoute(existingTask: currentTask),
    );
    
    if (result == true && mounted) {
      // Refresh the current task data
      if (currentTask.slug != null) {
        try {
          final taskApiService = Provider.of<TaskApiService>(
            context,
            listen: false,
          );
          final updatedTask = await taskApiService.getTaskBySlug(currentTask.slug!);
          if (updatedTask != null) {
            setState(() {
              _tasks[_currentPageIndex] = updatedTask;
            });
          }
        } catch (e) {
          // If failed to get updated task, just refresh the list
          _fetchTasksFromAPI();
        }
      }
    }
  }

  Future<void> _handleDeleteTask() async {
    if (_tasks.isEmpty || _isCurrentTaskCompleted) return;

    final currentTask = _tasks[_currentPageIndex];

    try {
      final taskApiService = Provider.of<TaskApiService>(
        context,
        listen: false,
      );

      if (currentTask.slug != null) {
        // Show loading indicator
        if (mounted) {
          showCustomTopSnackbar(
            context: context,
            message: 'Menghapus tugas...',
            isError: false,
          );
        }

        final result = await taskApiService.deleteTask(currentTask.slug!);

        if (result.isSuccess) {
          // Remove task from local list
          setState(() {
            _tasks.removeAt(_currentPageIndex);

            // Adjust current page index if needed
            if (_currentPageIndex >= _tasks.length && _tasks.isNotEmpty) {
              _currentPageIndex = _tasks.length - 1;
            }
          });

          // Show success message
          if (mounted) {
            showCustomTopSnackbar(
              context: context,
              message: 'Tugas berhasil dihapus',
              isError: false,
            );
          }
          
          // Navigate back if no more tasks
          if (_tasks.isEmpty) {
            // Return true to indicate data changed, so parent can refresh
            Navigator.pop(context, true);
          } else {
            // Animate to adjusted page
            _pageController.animateToPage(
              _currentPageIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        } else {
          // Show error message
          if (mounted) {
            showCustomTopSnackbar(
              context: context,
              message: result.message,
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: 'Gagal menghapus tugas: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_detail.png',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.router.pop(true), // Return true to indicate potential data changes
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Detail Tugas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Task Cards with loading and error handling
                  Expanded(child: _buildContent()),

                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),

          // Action Buttons
          // Action Buttons (Hidden if task is completed)
if (!_isCurrentTaskCompleted)
  Positioned(
    bottom: 36,
    left: 0,
    right: 0,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Edit Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/activitycategory/edit-pencil.svg',
              width: 48,
              height: 48,
            ),
            onPressed: _handleEditTask,
          ),
        ),

        const SizedBox(width: 64),

        // Delete Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFFDECEC),
            borderRadius: BorderRadius.circular(60),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 8,
              ),
            ],
          ),
          child: IconButton(
            icon: SvgPicture.asset(
              'assets/activitycategory/trash.svg',
              width: 48,
              height: 48,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ConfirmDialog(
                  isTask: true,
                  onConfirm: () {
                    _handleDeleteTask();
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),

        ],
      ),
    );
  }
}