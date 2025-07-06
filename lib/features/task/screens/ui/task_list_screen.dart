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
  Timer? _refreshTimer;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initial data fetch
    _refreshData();
  }

  @override
  void dispose() {
    // Cancel all timers before dispose
    _refreshTimer?.cancel();
    _debounceTimer?.cancel();
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _fetchOverdueCount() async {
    // Check if widget is still mounted to avoid accessing deactivated widget
    if (!mounted) return;

    try {
      final taskService = Provider.of<TaskApiService>(context, listen: false);
      final data = await taskService.countLateTasks();
      print('Data dari API: $data');

      // Check again if widget is still mounted before calling setState
      if (!mounted) return;

      if (data != null && data['overdue_tasks'] != null) {
        setState(() {
          _overdueTasksCount = data['overdue_tasks'] as int;
        });
      }
    } catch (e) {
      // Handle error silently if widget is disposed
      if (mounted) {
        print('Error fetching overdue count: $e');
      }
    }
  }

  // Method to refresh all data dengan debouncing
  Future<void> _refreshData() async {
    if (!mounted) return;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Debounce untuk menghindari multiple rapid calls
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;

      try {
        final taskService = Provider.of<TaskApiService>(context, listen: false);
        await Future.wait([
          _fetchOverdueCount(),
          taskService.fetchTasks(forceRefresh: true),
        ]);
      } catch (e) {
        if (mounted) {
          print('Error refreshing data: $e');
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Ketika app kembali ke foreground, refresh data
      _refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tinggi bottom navigation untuk padding scroll
    final bottomNavHeight = kBottomNavigationBarHeight;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          safeNavigate(() {
            context.router.pushAndPopUntil(
              const HomeRoute(),
              predicate: (_) => false,
            );
          });
          return;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
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
          bottomNavigationBar: const BottomNavbar(currentIndex: 2),
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
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
                        onFilterSelected: (filter) async {
                          setState(() {
                            _selectedFilter = filter;
                          });
                          // Refresh data when filter changes
                          final taskService = Provider.of<TaskApiService>(
                            context,
                            listen: false,
                          );
                          await taskService.fetchTasks(forceRefresh: true);
                        },
                      ),
                    ),
                    Expanded(
                      child: Consumer<TaskApiService>(
                        builder: (context, taskApiService, child) {
                          // Trigger refresh ketika Consumer di-rebuild
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              _refreshData();
                            }
                          });

                          return RefreshIndicator(
                            onRefresh: _refreshData,
                            child: TaskListView(
                              currentFilter: _selectedFilter,
                              onShowSuccess: (message) {
                                // Refresh all data including overdue count and task list
                                _refreshData();
                                showCustomTopSnackbar(
                                  context: context,
                                  message: message,
                                );
                              },
                              onTapTask: (task) {
                                safeOnTap(() async {
                                  final taskApiService =
                                      Provider.of<TaskApiService>(
                                        context,
                                        listen: false,
                                      );
                                  List<Task> allTasks = [];
                                  int taskIndex = 0;
                                  try {
                                    if (_selectedFilter == 'Semua') {
                                      allTasks =
                                          await taskApiService.getAllTasks();
                                    } else if (_selectedFilter == 'Terlambat') {
                                      final data = await taskApiService
                                          .getTasksByStatus('terlambat');
                                      if (data != null &&
                                          data['tasks'] != null) {
                                        allTasks = List<Task>.from(
                                          data['tasks'].map(
                                            (e) => Task.fromMap(e),
                                          ),
                                        );
                                      }
                                    } else if (_selectedFilter ==
                                        'Belum Selesai') {
                                      final data = await taskApiService
                                          .getTasksByStatus('belum_selesai');
                                      if (data != null &&
                                          data['tasks'] != null) {
                                        allTasks = List<Task>.from(
                                          data['tasks'].map(
                                            (e) => Task.fromMap(e),
                                          ),
                                        );
                                      }
                                    } else if (_selectedFilter == 'Selesai') {
                                      final data = await taskApiService
                                          .getTasksByStatus('selesai');
                                      if (data != null &&
                                          data['tasks'] != null) {
                                        allTasks = List<Task>.from(
                                          data['tasks'].map(
                                            (e) => Task.fromMap(e),
                                          ),
                                        );
                                      }
                                    }
                                    taskIndex = allTasks.indexWhere(
                                      (t) => t.id == task.id,
                                    );
                                    if (taskIndex == -1) taskIndex = 0;
                                  } catch (e) {
                                    allTasks = [task];
                                    taskIndex = 0;
                                  }

                                  if (!mounted) return;

                                  final result = await context.router.push(
                                    TaskDetailListRoute(
                                      tasks: allTasks,
                                      initialIndex: taskIndex,
                                    ),
                                  );
                                  if (result == true) {
                                    _fetchOverdueCount();
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    // Spacer agar konten tidak ketutupan bottom nav
                    SizedBox(height: bottomNavHeight + 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
