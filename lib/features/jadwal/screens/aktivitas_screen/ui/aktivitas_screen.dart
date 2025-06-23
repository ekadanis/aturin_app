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
import 'package:loading_animation_widget/loading_animation_widget.dart';

@RoutePage()
class AktivitasPage extends StatefulWidget {
  const AktivitasPage({super.key});

  @override
  State<AktivitasPage> createState() => _AktivitasPageState();
}

class _AktivitasPageState extends State<AktivitasPage> {
  String selectedCategory = 'Semua';
  late DateTime selectedDate;
  late DateTime focusedDate;  CalendarFormat calendarFormat = CalendarFormat.week;
  bool _isInitialLoading = true;
  Timer? _debounceTimer; // Add debounce timer variable

  // Force calendar rebuild counter - increment after delete operations
  int _calendarRebuildCounter = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    focusedDate = DateTime(now.year, now.month, now.day);

    // Load initial data
    Future.microtask(() => _refreshData());
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isInitialLoading = true;
      });

      final activityApiService = Provider.of<ActivityApiService>(
        context,
        listen: false,
      );
      final taskApiService = Provider.of<TaskApiService>(
        context,
        listen: false,
      );

      // Fetch all data without timeout restrictions for better responsiveness
      await Future.wait([
        activityApiService.fetchActivities(),
        taskApiService.fetchTasks(),
        taskApiService.fetchUncompletedTasksToday(),
      ]);
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
  }  /// Real-time date change with instant response for calendar taps
  /// Ultra-fast debouncing only for rapid swipe scenarios
  Future<void> _onDateChanged(DateTime newDate) async {
    if (!mounted) return;

    // Cancel previous debounce timer to prevent stale updates
    _debounceTimer?.cancel();

    // Immediately update selected date for instant UI response
    setState(() {
      selectedDate = newDate;
      // Force immediate calendar rebuild for instant dot synchronization
      _calendarRebuildCounter++;
    });

    // For calendar dot taps: No debounce needed - instant data fetch
    // For rapid swiping: Use minimal 20ms debounce to prevent excessive API calls
    final debounceDelay = Duration(milliseconds: 20); // Reduced from 50ms to 20ms
    
    _debounceTimer = Timer(debounceDelay, () async {
      if (!mounted || selectedDate != newDate) return; // Check if date is still current
      
      final taskApiService = Provider.of<TaskApiService>(context, listen: false);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(newDate.year, newDate.month, newDate.day);

      try {
        if (selectedDay.isAtSameMomentAs(today)) {
          // For today, fetch uncompleted tasks
          await taskApiService.fetchUncompletedTasksToday();
        } else {
          // For other dates, fetch all tasks
          await taskApiService.fetchTasks();
        }

        // Final calendar rebuild after data fetch (only if date hasn't changed)
        if (mounted && selectedDate == newDate) {
          setState(() {
            _calendarRebuildCounter++;
          });
        }
      } catch (e) {
        debugPrint('Error fetching data for date change: $e');
      }
    });
  }

  /// Get fresh task data for calendar - always from API service
  List<Task> _getTasksForCalendar() {
    final taskApiService = Provider.of<TaskApiService>(context, listen: false);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (selectedDay.isAtSameMomentAs(today)) {
      // For today: return uncompleted tasks
      return taskApiService.tasks.where((task) => !task.isCompleted).toList();
    } else {
      // For other dates: return uncompleted tasks
      return taskApiService.tasks.where((task) => !task.isCompleted).toList();
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
              Transform.translate(
                offset: const Offset(0, -8),
                child: CategoryTabsWidget(
                  selectedCategory: selectedCategory,
                  onCategoryChanged: (category) {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Calendar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: Consumer2<ActivityApiService, TaskApiService>(                  builder: (context, activityApiService, taskApiService, _) {
                    // Create stable key for calendar - only rebuild when data actually changes
                    final activitiesHash = activityApiService.activities.length;
                    final tasksHash = taskApiService.tasks.length;
                    final calendarKey = ValueKey(
                      'calendar_${activitiesHash}_${tasksHash}_${_calendarRebuildCounter}',
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
                child: Consumer2<ActivityApiService, TaskApiService>(                  builder: (context, activityApiService, taskApiService, _) {
                    if (_isInitialLoading) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppTheme.primaryColor,
                          size: 50,
                        ),
                      );
                    }

                    // Handle ActivityApiService loading state
                    if (activityApiService.isLoading &&
                        activityApiService.activities.isEmpty) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppTheme.primaryColor,
                          size: 50,
                        ),
                      );
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

                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: InfiniteScheduleListWidget(
                        tasks: _getTasksForCalendar(),
                        schedules: activityApiService.activities,
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
                          // Refresh data immediately after any operation
                          _refreshData();
                          showCustomTopSnackbar(
                            context: context,
                            message: message,
                            isError: false,
                          );
                        },
                      ),
                    );
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
              // Force calendar rebuild and refresh data
              _calendarRebuildCounter++;
              _refreshData();

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
              // Immediately fetch fresh data
              await taskApiService.fetchUncompletedTasksToday();
              
              // Force calendar rebuild
              _calendarRebuildCounter++;
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
            }          }
        },
      ),
    );
  }

  @override
  void dispose() {
    // Cancel debounce timer to prevent memory leaks
    _debounceTimer?.cancel();
    super.dispose();
  }
}
