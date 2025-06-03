import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/core/widgets/calendar_section_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/category_tabs_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/infinite_schedule_list_widget.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/core/widgets/custom_snackbar_top.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';

@RoutePage()
class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  String selectedCategory = 'Semua';
  late DateTime selectedDate;
  late DateTime focusedDate;
  CalendarFormat calendarFormat = CalendarFormat.week;
  bool _isInitialLoading = true;
  Timer? _dateChangeDebouncer;
  
  // Local cache for smooth transitions
  List<Task> _allTasks = [];
  List<Task> _uncompletedTasksToday = [];
  DateTime? _lastDataFetch;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    focusedDate = DateTime(now.year, now.month, now.day);

    // Load initial data
    Future.microtask(() => _refreshData());
  }

  @override
  void dispose() {
    _dateChangeDebouncer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    try {
      // Set loading state
      setState(() {
        _isInitialLoading = true;
      });

      final activityApiService = Provider.of<ActivityApiService>(context, listen: false);
      final taskApiService = Provider.of<TaskApiService>(context, listen: false);

      // Fetch activities data
      await activityApiService.fetchActivities().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Activities fetch timeout, continuing with cached data');
        },
      );

      // Fetch ALL tasks once untuk caching
      await taskApiService.fetchTasks().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('All tasks fetch timeout, continuing with cached data');
        },
      );
      
      // Cache all tasks locally
      _allTasks = List.from(taskApiService.tasks);
      
      // Fetch uncompleted tasks today untuk cache
      await taskApiService.fetchUncompletedTasksToday().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Uncompleted tasks today fetch timeout, continuing with cached data');
        },
      );
      
      // Cache uncompleted today tasks
      _uncompletedTasksToday = List.from(taskApiService.tasks);
      
      // Mark last fetch time
      _lastDataFetch = DateTime.now();
      
      print('📦 Data cached successfully:');
      print('   All tasks: ${_allTasks.length}');
      print('   Uncompleted today: ${_uncompletedTasksToday.length}');
      
    } catch (e) {
      debugPrint('Error during data refresh: $e');
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

  /// Smooth date transition without any API calls - uses only cached data
  void _onDateChanged(DateTime newDate) {
    if (!mounted) return;

    // Cancel any pending background refresh
    _dateChangeDebouncer?.cancel();

    print('📅 Date changed to ${newDate.toString().split(' ')[0]} - INSTANT transition using cached data');
    
    // Immediate UI update with cached data - NO async operations
    setState(() {
      selectedDate = newDate;
    });

    // Schedule background refresh if cache is stale (> 5 minutes)
    if (_lastDataFetch != null && DateTime.now().difference(_lastDataFetch!).inMinutes > 5) {
      _dateChangeDebouncer = Timer(const Duration(milliseconds: 500), () {
        _refreshDataInBackground();
      });
    }
  }

  /// Background data refresh tanpa loading indicator
  Future<void> _refreshDataInBackground() async {
    if (!mounted) return;
    
    try {
      final taskApiService = Provider.of<TaskApiService>(context, listen: false);
      final activityApiService = Provider.of<ActivityApiService>(context, listen: false);

      // Silent refresh tanpa loading indicator
      await Future.wait([
        activityApiService.fetchActivities(),
        taskApiService.fetchTasks(),
      ]);

      // Update local cache untuk all tasks
      _allTasks = List.from(taskApiService.tasks);
      
      // Fetch uncompleted tasks today untuk cache
      await taskApiService.fetchUncompletedTasksToday();
      _uncompletedTasksToday = List.from(taskApiService.tasks);
      _lastDataFetch = DateTime.now();

      print('🔄 Background refresh completed');
      print('   All tasks cached: ${_allTasks.length}');
      print('   Uncompleted today cached: ${_uncompletedTasksToday.length}');
      
      // Trigger UI rebuild untuk update calendar markers
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Background refresh error: $e');
    }
  }

  /// Force refresh current date data - useful after task completion/status changes
  Future<void> _forceRefreshCurrentDate() async {
    if (!mounted) return;
    
    final taskApiService = Provider.of<TaskApiService>(context, listen: false);
    final activityApiService = Provider.of<ActivityApiService>(context, listen: false);

    try {
      // Show brief loading
      setState(() {
        _isInitialLoading = true;
      });

      // Force refresh activities
      await activityApiService.fetchActivities();
      
      // Force refresh tasks based on current selected date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      if (selectedDay.isAtSameMomentAs(today)) {
        // For today, fetch uncompleted tasks only
        await taskApiService.fetchUncompletedTasksToday();
      } else {
        // For other dates, fetch all tasks
        await taskApiService.fetchTasks();
      }

      // Force UI rebuild
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error force refreshing data: $e');
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  /// Get the appropriate task data for calendar based on selected date
  /// UPDATED: Always use fresh data from taskApiService untuk avoid stale cache after delete
  List<Task> _getTasksForCalendar() {
    final taskApiService = Provider.of<TaskApiService>(context, listen: false);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    print('🗓️ Calendar data request for ${selectedDate.toString().split(' ')[0]}:');
    
    if (selectedDay.isAtSameMomentAs(today)) {
      // For today: filter uncompleted tasks from taskApiService.tasks (fresh data)
      final uncompletedTasksToday = taskApiService.tasks.where((task) => !task.isCompleted).toList();
      print('   📅 Calendar showing TODAY data: ${uncompletedTasksToday.length} uncompleted tasks (from fresh taskApiService)');
      return uncompletedTasksToday;
    } else {
      // For other dates: filter uncompleted tasks from fresh taskApiService.tasks
      final uncompletedTasks = taskApiService.tasks.where((task) => !task.isCompleted).toList();
      print('   📅 Calendar showing OTHER DATE data: ${uncompletedTasks.length} uncompleted tasks (filtered from ${taskApiService.tasks.length} fresh)');
      return uncompletedTasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.router.pushAndPopUntil(
          const HomeRoute(),
          predicate: (_) => false,
        );
      },
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Text(
                      'Jadwal',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Category Tabs
              CategoryTabsWidget(
                selectedCategory: selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Consumer2<ActivityApiService, TaskApiService>(
                  builder: (context, activityApiService, taskApiService, _) {
                    // Create a unique key based on the data to force rebuild when data changes
                    final activitiesHash = activityApiService.activities
                        .map((a) => '${a.id}_${a.slug}').join(',').hashCode;
                    final tasksHash = taskApiService.tasks
                        .map((t) => '${t.id}_${t.slug}').join(',').hashCode;
                    final calendarKey = ValueKey(
                      'calendar_${activityApiService.activities.length}_${taskApiService.tasks.length}_${activitiesHash}_${tasksHash}'
                    );
                    
                    return CalendarSectionWidget(
                      key: calendarKey,
                      selectedDate: selectedDate,
                      focusedDate: focusedDate,
                      calendarFormat: calendarFormat,
                      schedules: activityApiService.activities,
                      tasks: _getTasksForCalendar(),
                      onDateSelected: (selectedDay, focusedDay) {
                        setState(() {
                          focusedDate = focusedDay;
                        });
                        _onDateChanged(selectedDay);
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setState(() {
                          focusedDate = focusedDay;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Schedule List
              Expanded(
                child: Consumer2<ActivityApiService, TaskApiService>(
                  builder: (context, activityApiService, taskApiService, _) {
                    try {
                      if (_isInitialLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Handle ActivityApiService loading state
                      if (activityApiService.isLoading &&
                          activityApiService.activities.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Handle ActivityApiService error state
                      if (activityApiService.error != null &&
                          activityApiService.activities.isEmpty) {
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
                                'Gagal memuat aktivitas',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activityApiService.error!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      // RACE CONDITION FIX: Send properly filtered data to InfiniteScheduleListWidget
                      // Use filtered task data to ensure consistency between calendar and schedule list
                      final aktivitasList = activityApiService.activities;
                      final tasksList = _getTasksForCalendar(); // Use same filtered data as calendar
                      
                      return RefreshIndicator(
                        onRefresh: _refreshData,
                        child: InfiniteScheduleListWidget(
                          tasks: tasksList,
                          schedules: aktivitasList,
                          selectedCategory: selectedCategory,
                          selectedDate: selectedDate,
                          onDateChanged: (date) {
                            _onDateChanged(date);
                          },
                          onEditSchedule: (aktivitas) => _editActivity(aktivitas),
                          onDeleteSchedule: (aktivitas) => _deleteActivity(aktivitas),
                          onEditTask: (task) => _editTask(task),
                          onDeleteTask: (task) => _deleteTask(task),
                          onShowSuccess: (message) {
                            // Force refresh current date data immediately to avoid stale data
                            _forceRefreshCurrentDate();
                            // Show snackbar
                            showCustomTopSnackbar(
                              context: context,
                              message: message,
                              isError: false,
                            );
                          },
                        ),
                      );
                    } catch (e) {
                      debugPrint('Error in Consumer2 builder: $e');
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
                              'Terjadi kesalahan',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Silakan coba refresh halaman',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _refreshData,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      ),
    );
  }

  void _editActivity(AktivitasModel aktivitas) {
    context.router.push(AddAktivitasRoute(existingAktivitas: aktivitas));
  }

  void _editTask(Task task) {
    context.router.push(AddTaskRoute(existingTask: task));
  }

  void _deleteActivity(AktivitasModel aktivitas) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        iconPath: 'assets/activitycategory/trash-round-tipis.svg',
        title: 'Hapus Aktivitas',
        description: 'Yakin nih kamu mau hapus aktivitas ini?',
        confirmText: 'Hapus',
        cancelText: 'Batal',
        isTask: false,
        onConfirm: () async {
          Navigator.of(dialogContext).pop();

          try {
            // Validasi slug
            if (aktivitas.slug == null || aktivitas.slug!.isEmpty) {
              if (mounted) {
                showCustomTopSnackbar(
                  context: context,
                  message: 'Tidak dapat menghapus aktivitas: data tidak lengkap',
                  isError: true,
                );
              }
              return;
            }

            final activityApiService = Provider.of<ActivityApiService>(
              context,
              listen: false,
            );

            // Show loading indicator
            if (mounted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Menghapus aktivitas...',
                isError: false,
              );
            }

            final success = await activityApiService.deleteActivity(
              aktivitas.slug!,
            );

            if (!mounted) return;
            
            if (success) {
              // Immediately update activityApiService cache untuk instant UI update
              activityApiService.activities.removeWhere((a) => a.slug == aktivitas.slug);
              
              // Trigger UI rebuild immediately
              setState(() {});
              
              // Background refresh untuk sync dengan server (optional)
              _refreshDataInBackground();

              showCustomTopSnackbar(
                context: context,
                message: 'Aktivitas berhasil dihapus',
                isError: false,
              );
            } else {
              showCustomTopSnackbar(
                context: context,
                message: 'Gagal menghapus aktivitas',
                isError: true,
              );
            }
          } catch (e) {
            debugPrint('Error deleting aktivitas: $e');

            if (mounted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Gagal menghapus aktivitas: ${e.toString()}',
                isError: true,
              );
            }
          }
        },
      ),
    );
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (dialogContext) => ConfirmDialog(
        iconPath: 'assets/activitycategory/trash-round-tipis.svg',
        title: 'Hapus Tugas',
        description: 'Yakin nih kamu mau hapus tugas ini?',
        confirmText: 'Hapus',
        cancelText: 'Batal',
        isTask: true,
        onConfirm: () async {
          Navigator.of(dialogContext).pop();

          try {
            // Validasi slug
            if (task.slug == null || task.slug!.isEmpty) {
              if (mounted) {
                showCustomTopSnackbar(
                  context: context,
                  message: 'Tidak dapat menghapus tugas: data tidak lengkap',
                  isError: true,
                );
              }
              return;
            }

            final taskApiService = Provider.of<TaskApiService>(
              context,
              listen: false,
            );

            // Show loading indicator
            if (mounted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Menghapus tugas...',
                isError: false,
              );
            }

            final result = await taskApiService.deleteTask(task.slug!);

            if (!mounted) return;
            
            if (result.isSuccess) {
              print('🗑️ Task delete success - immediately fetching fresh data');
              
              // Don't update cache manually - fetch fresh data from server instead
              print('🔄 Fetching fresh data from server after delete...');
              
              // Force immediate refresh from server untuk memastikan data terbaru
              await taskApiService.fetchUncompletedTasksToday();
              
              print('✅ Fresh data fetched:');
              print('   taskApiService.tasks: ${taskApiService.tasks.length}');
              print('   Current tasks: ${taskApiService.tasks.map((t) => '${t.slug}:"${t.title}"').join(', ')}');
              
              // Update local cache dengan data fresh
              _uncompletedTasksToday = List.from(taskApiService.tasks);
              _lastDataFetch = DateTime.now();
              
              // Trigger UI rebuild immediately dengan data fresh
              setState(() {});

              showCustomTopSnackbar(
                context: context,
                message: 'Tugas berhasil dihapus',
                isError: false,
              );
            } else {
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
                message: 'Gagal menghapus tugas: ${e.toString()}',
                isError: true,
              );
            }
          }
        },
      ),
    );
  }
}