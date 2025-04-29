import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../models/task.dart';
import '../../services/task_services.dart';
import '../widgets/filter_tabs.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_route/auto_route.dart';
import '../../../../core/widgets/bottom_navbar.dart';
import '../../../../routers/app_router.dart';

@RoutePage()
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with WidgetsBindingObserver {
  String _selectedFilter = 'Semua';
  final List<String> _filters = ['Semua', 'Terlambat', 'Belum Selesai', 'Selesai'];
  bool _showSuccessMessage = false;
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Load data on initial load
    _loadTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fetch tasks when dependencies change
    _loadTasks();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh task list when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadTasks();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Centralized method to load tasks with error handling
  void _loadTasks() {
    // Use Future.microtask to avoid setState during build
    Future.microtask(() {
      if (mounted) {
        try {
          Provider.of<TaskService>(context, listen: false).fetchTasks();
        } catch (e) {
          // Handle errors if needed
          debugPrint('Error fetching tasks: $e');
        }
      }
    });
  }

  void _showSuccess(String message) {
    setState(() {
      _showSuccessMessage = true;
      _successMessage = message;
    });
    
    // Sembunyikan pesan setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          'Tugas',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      
      body: Column(
        children: [
          // Pesan sukses
          if (_showSuccessMessage)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2E9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF4CAF50), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage,
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showSuccessMessage = false;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          
          // Filter tabs
          FilterTabs(
            filters: _filters,
            selectedFilter: _selectedFilter,
            onFilterSelected: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
          
          // Task list
          Expanded(
            child: Consumer<TaskService>(
              builder: (context, taskService, child) {
                // // Check if tasks are loading
                // if (taskService.isLoading) {
                //   return const Center(
                //     child: CircularProgressIndicator(),
                //   );
                // }
                
                final filteredTasks = taskService.getTasksByFilter(_selectedFilter);
                
                if (filteredTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.assignment_outlined,
                          size: 56,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada tugas',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        if (_selectedFilter != 'Semua')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Coba pilih filter lain',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await Provider.of<TaskService>(context, listen: false).fetchTasks();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.3,
                            children: [
                              SlidableAction(
                                onPressed: (_) {
                                  // Menggunakan AutoRoute untuk navigasi ke halaman detail
                                  context.router.push(TaskDetailRoute(task: task)).then((_) {
                                    // Refresh tasks when returning from detail screen
                                    _loadTasks();
                                  });
                                },
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey.shade600,
                                icon: Icons.info_outline,
                                label: 'Detail',
                              ),
                              SlidableAction(
                                onPressed: (_) async {
                                  await Provider.of<TaskService>(context, listen: false)
                                      .deleteTask(task.id);
                                  // Force refresh after deletion
                                  _loadTasks();
                                  _showSuccess('Berhasil menghapus tugas');
                                },
                                backgroundColor: const Color(0xFFFFCDD2),
                                foregroundColor: Colors.red,
                                icon: Icons.delete_outline,
                                label: 'Hapus',
                              ),
                            ],
                          ),
                          child: _buildTaskCard(task),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: FloatingActionButton(
          onPressed: () {
            // Menggunakan AutoRoute alih-alih Navigator.push
            context.pushRoute(AddTaskRoute()).then((result) {
              if (result == true) {
                _loadTasks();
                _showSuccess('Berhasil menambahkan tugas');
              }
            });
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add, color: AppTheme.buttonBackgroundColor),
        ),
      ),
      
      // Menggunakan bottom navbar custom yang sudah ada
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Checkbox atau indikator status
                GestureDetector(
                  onTap: () async {
                    await Provider.of<TaskService>(context, listen: false)
                        .toggleTaskCompletion(task.id);
                    // Force refresh after updating completion status
                    _loadTasks();
                    if (!task.isCompleted) {
                      _showSuccess('Berhasil Menyelesaikan Tugas');
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? AppTheme.primaryColor : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? AppTheme.primaryColor : AppTheme.primaryColor,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: task.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppTheme.lightCardColor,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Informasi tugas
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kategori
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getCategoryName(task.category),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Judul tugas
                      Text(
                        task.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Estimasi waktu
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Estimasi: ${task.estimatedDuration.inHours};${(task.estimatedDuration.inMinutes % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusName(task.status, task: task),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusTextColor(task.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Alarm indicator if active
          if (task.isAlarmActive)
            Container(
              height: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFEEEEEE),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Icon(
                    Icons.alarm,
                    size: 12,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Alarm Aktif',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getCategoryName(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString() == 'TaskCategory.$category',
      );
      
      switch (taskCategory) {
        case TaskCategory.akademik:
          return 'Akademik';
        case TaskCategory.hiburan:
          return 'Hiburan';
        case TaskCategory.pekerjaan:
          return 'Pekerjaan';
        case TaskCategory.olahraga:
          return 'Olahraga';
        case TaskCategory.sosial:
          return 'Sosial';
        case TaskCategory.spiritual:
          return 'Spiritual';
        case TaskCategory.pribadi:
          return 'Pribadi';
        case TaskCategory.istirahat:
          return 'Istirahat';
      }
    } catch (_) {
      return category;
    }
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
          final deadlineDay = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
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
        return const Color(0xFFFFDDDD);
      case TaskStatus.today:
        return const Color(0xFFE3F2F9);
      case TaskStatus.tomorrow:
        return const Color(0xFFFFF8E1);
      case TaskStatus.upcoming:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getStatusTextColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.completed:
        return const Color(0xFF4CAF50);
      case TaskStatus.late:
        return const Color(0xFFFF6B6B);
      case TaskStatus.today:
        return const Color(0xFF2196F3);
      case TaskStatus.tomorrow:
        return const Color(0xFFFFC107);
      case TaskStatus.upcoming:
        return const Color(0xFF9E9E9E);
    }
  }
}