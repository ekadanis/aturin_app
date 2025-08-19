import 'dart:async';
import 'package:aturin_app/app/bottom_navbar.dart';
import 'package:aturin_app/shared/utils/tap_protection.dart';
import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:aturin_app/shared/core/services/api/task/task_api_service.dart';
import 'package:provider/provider.dart';
import '../../../../shared/core/infrastructure/routers/app_router.dart';
import '../widgets/filter_tabs.dart';
import '../widgets/task_list_view.dart';
import '../../../../shared/widgets/custom_snackbar_top.dart';
import '../../data/model/task_model.dart';

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
  bool _isInitialLoading = true;

  // Force task list rebuild counter - increment after delete operations (sama seperti aktivitas)
  int _taskListRebuildCounter = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Load initial data (sama seperti aktivitas screen)
    Future.microtask(() => _refreshData());
  }

  @override
  void dispose() {
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _fetchOverdueCount({bool useCache = true}) async {
    // Check if widget is still mounted to avoid accessing deactivated widget
    if (!mounted) return;

    try {
      final taskService = Provider.of<TaskApiService>(context, listen: false);
      // Gunakan cache kecuali force refresh
      final data = await taskService.countLateTasks(forceRefresh: !useCache);

      // Check again if widget is still mounted before calling setState
      if (!mounted) return;

      if (data != null && data['overdue_tasks'] != null) {
        setState(() {
          _overdueTasksCount = data['overdue_tasks'] as int;
        });
      }
    } catch (e) {
      // Handle error silently if widget is disposed
      if (mounted) {}
    }
  }

  // Simple refresh method - sama persis dengan aktivitas screen
  Future<void> _refreshData({bool forceRefresh = false}) async {
    if (!mounted) return;

    try {
      final taskApiService = Provider.of<TaskApiService>(
        context,
        listen: false,
      );

      // Hanya tampilkan loading screen jika belum ada data sama sekali
      // Ini mencegah tampilan loading ketika data sudah ada di cache
      final bool shouldShowLoading = taskApiService.tasks.isEmpty;

      if (shouldShowLoading) {
        setState(() {
          _isInitialLoading = true;
        });
      }

      await Future.wait([
        _fetchOverdueCount(useCache: !forceRefresh),
        taskApiService.fetchTasks(forceRefresh: forceRefresh),
      ]);
    } catch (e) {
      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: 'Gagal memuat ulang data',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Ketika app kembali ke foreground, refresh data dari server untuk sinkronisasi
      _refreshData(forceRefresh: true);
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
            bottom: false, // Bottom sudah di-handle oleh BottomNavbar
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
                        // Tidak perlu refresh data saat filter berubah
                        // karena data sudah ada di Provider, cukup setState untuk rebuild UI
                      },
                    ),
                  ),
                  Expanded(
                    child: Consumer<TaskApiService>(
                      builder: (context, taskApiService, child) {
                        // Only show loading indicator during initial loading AND when we have no cached data
                        // If we have ANY cached data (tasks), don't show loading
                        if (_isInitialLoading &&
                            taskApiService.tasks.isEmpty &&
                            taskApiService.isLoading) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (taskApiService.errorMessage != null &&
                            taskApiService.tasks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal memuat tugas',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  taskApiService.errorMessage!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _refreshData(forceRefresh: true),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: () => _refreshData(forceRefresh: true),
                          child: TaskListView(
                            key: ValueKey(
                              'task_list_${taskApiService.tasks.length}_${_taskListRebuildCounter}',
                            ),
                            currentFilter: _selectedFilter,
                            onShowSuccess: (message) {
                              // Refresh all data and force rebuild after any CRUD operation - SAMA SEPERTI AKTIVITAS
                              _refreshData();
                              // Force task list rebuild for instant update
                              setState(() {
                                _taskListRebuildCounter++;
                              });
                              showCustomTopSnackbar(
                                context: context,
                                message: message,
                                isError: false,
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
                                    if (data != null && data['tasks'] != null) {
                                      allTasks = List<Task>.from(
                                        data['tasks'].map(
                                          (e) => Task.fromMap(e),
                                        ),
                                      );
                                    }
                                  } else if (_selectedFilter ==
                                      'Belum Selesai') {
                                    // Filter untuk belum selesai: ambil yang statusnya belum_selesai
                                    // dan deadline masih di masa depan (tidak terlambat)
                                    final data = await taskApiService
                                        .getTasksByStatus('belum_selesai');
                                    if (data != null && data['tasks'] != null) {
                                      final allBelumSelesai = List<Task>.from(
                                        data['tasks'].map(
                                          (e) => Task.fromMap(e),
                                        ),
                                      );
                                      // Filter out yang terlambat
                                      final now = DateTime.now();
                                      allTasks =
                                          allBelumSelesai
                                              .where(
                                                (task) =>
                                                    !task.deadline.isBefore(
                                                      now,
                                                    ),
                                              )
                                              .toList();
                                    }
                                  } else if (_selectedFilter == 'Selesai') {
                                    final data = await taskApiService
                                        .getTasksByStatus('selesai');
                                    if (data != null && data['tasks'] != null) {
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
                                  // Refresh data setelah perubahan dari detail view - SAMA SEPERTI AKTIVITAS
                                  _refreshData();
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
    );
  }
}
