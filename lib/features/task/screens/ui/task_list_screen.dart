import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/core/utils/tap_protection.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/widgets/bottom_navbar.dart';
import '../../../../../../routers/app_router.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/task_list_view.dart';
import '../../../../core/widgets/custom_snackbar_top.dart';
import '../../model/task_model.dart';

@RoutePage()
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with WidgetsBindingObserver, TapProtectionMixin {
  String _selectedFilter = 'Semua';
  final List<String> _filters = [
    'Semua',
    'Terlambat',
    'Belum Selesai',
    'Selesai',
  ];

  int _overdueTasksCount = 0;

  Timer? _reloadTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchOverdueCount();
      Provider.of<TaskApiService>(context, listen: false).fetchTasks();
      _startAutoReload();
    });
  }

  void _startAutoReload() {
    _reloadTimer?.cancel();
    _reloadTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchOverdueCount();
      setState(() {}); // Trigger reload TaskListView
    });
  }

  void _resetAutoReloadTimer() {
    _startAutoReload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOverdueCount() async {
    final taskService = Provider.of<TaskApiService>(context, listen: false);
    final data = await taskService.countLateTasks();
    print('Data dari API: $data');
    if (data != null && data['overdue_tasks'] != null) {
      setState(() {
        _overdueTasksCount = data['overdue_tasks'] as int;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchOverdueCount();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetAutoReloadTimer,
      onPanDown: (_) => _resetAutoReloadTimer(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          safeNavigate(() {
            context.router.pushAndPopUntil(
              const HomeRoute(),
              predicate: (_) => false
            );
          });
          return;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              'Tugas',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _resetAutoReloadTimer();
                return false;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -8),
                    child: FilterTabs(
                      filters: _filters,
                      selectedFilter: _selectedFilter,
                      overdueTasksCount: _overdueTasksCount,
                      onFilterSelected: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: TaskListView(
                      currentFilter: _selectedFilter,
                      onShowSuccess: (message) {
                        // reload TaskListView
                        setState(() {});
                        // reload countLateTask agar badge overdue sinkron
                        _fetchOverdueCount();
                        // tampilkan snackbar jika perlu
                        showCustomTopSnackbar(context: context, message: message);
                      },                      onTapTask: (task) {
                        safeOnTap(() async {
                          // Get all tasks for the current filter to pass to TaskDetailListRoute
                          final taskApiService = TaskApiService();
                          List<Task> allTasks = [];
                          int taskIndex = 0;
                          
                          try {
                            if (_selectedFilter == 'Semua') {
                              allTasks = await taskApiService.getAllTasks();
                            } else if (_selectedFilter == 'Terlambat') {
                              final data = await taskApiService.getTasksByStatus('terlambat');
                              if (data != null && data['tasks'] != null) {
                                allTasks = List<Task>.from(data['tasks'].map((e) => Task.fromMap(e)));
                              }
                            } else if (_selectedFilter == 'Belum Selesai') {
                              final data = await taskApiService.getTasksByStatus('belum_selesai');
                              if (data != null && data['tasks'] != null) {
                                allTasks = List<Task>.from(data['tasks'].map((e) => Task.fromMap(e)));
                              }
                            } else if (_selectedFilter == 'Selesai') {
                              final data = await taskApiService.getTasksByStatus('selesai');
                              if (data != null && data['tasks'] != null) {
                                allTasks = List<Task>.from(data['tasks'].map((e) => Task.fromMap(e)));
                              }
                            }
                            
                            // Find the index of the tapped task
                            taskIndex = allTasks.indexWhere((t) => t.id == task.id);
                            if (taskIndex == -1) taskIndex = 0;
                            
                          } catch (e) {
                            // Fallback to single task if loading fails
                            allTasks = [task];
                            taskIndex = 0;
                          }
                          
                          final result = await context.router.push(
                            TaskDetailListRoute(
                              tasks: allTasks,
                              initialIndex: taskIndex,
                            ),
                          );
                          
                          if (result == true) {
                            setState(() {});
                            _fetchOverdueCount(); // reload countLateTask juga setelah edit
                            showCustomTopSnackbar(
                              context: context,
                              message: 'Tugas berhasil diperbarui',
                            );
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavbar(currentIndex: 2),
        ),
      ),
    );
  }
}
