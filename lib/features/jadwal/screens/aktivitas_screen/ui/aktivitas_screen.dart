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
      final activityApiService = Provider.of<ActivityApiService>(
        context, 
        listen: false,
      );
      final taskApiService = Provider.of<TaskApiService>(
        context,
        listen: false,
      );

      // Hanya tampilkan loading screen jika belum ada data sama sekali
      // Ini mencegah tampilan loading ketika data sudah ada di cache
      final bool shouldShowLoading = activityApiService.activities.isEmpty &&
                                    taskApiService.tasks.isEmpty;
      
      if (shouldShowLoading) {
        setState(() {
          _isInitialLoading = true;
        });
      }

      // Untuk pull-to-refresh manual: gunakan cache jika data belum berubah
      // Ini menghindari loading saat data di cache masih valid
      bool forceRefresh = false;
      
      // Jika dipanggil dari initState, gunakan cache
      // Jika dipanggil dari RefreshIndicator (pull-to-refresh), paksa refresh dari server
      if (ModalRoute.of(context)?.isCurrent == true) {
        // User pull-to-refresh, paksa update dari server
        forceRefresh = true;
      } else {
      }
      
      await Future.wait([
        activityApiService.fetchActivities(forceRefresh: forceRefresh),
        taskApiService.fetchTasks(forceRefresh: forceRefresh),
        taskApiService.fetchUncompletedTasksToday(forceRefresh: forceRefresh),
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

  /// Real-time date change with instant response for calendar taps
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
          // For today, fetch uncompleted tasks (use cache, don't force refresh)
          await taskApiService.fetchUncompletedTasksToday(forceRefresh: false);
        } else {
          // For other dates, fetch all tasks (use cache, don't force refresh)
          await taskApiService.fetchTasks(forceRefresh: false);
        }

        // Final calendar rebuild after data fetch (only if date hasn't changed)
        if (mounted && selectedDate == newDate) {
          setState(() {
            _calendarRebuildCounter++;
          });
        }
      } catch (e) {
      }
    });
  }

  /// Get fresh task data for calendar - leveraging cached data from Provider
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

  // In aktivitas_screen.dart

@override
Widget build(BuildContext context) {
  final bottomNavHeight = kBottomNavigationBarHeight;

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
      extendBody: true,
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
              const SizedBox(height: 5),

              // --- FIX #1: The Calendar Section is NOT wrapped in Expanded or SingleChildScrollView ---
              // It is a direct child of the Column and will take up its own necessary height.
              Consumer2<ActivityApiService, TaskApiService>(
                builder: (context, activityApiService, taskApiService, _) {
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
              const SizedBox(height: 15),

              // --- FIX #2: The Schedule List is the ONLY widget wrapped in Expanded ---
              // This tells it to fill all the remaining space below the calendar.
              Expanded(
                child: Consumer2<ActivityApiService, TaskApiService>(
                  builder: (context, activityApiService, taskApiService, _) {
                    if (_isInitialLoading &&
                        activityApiService.activities.isEmpty &&
                        taskApiService.tasks.isEmpty &&
                        (activityApiService.isLoading || taskApiService.isLoading)) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: AppTheme.primaryColor,
                          size: 50,
                        ),
                      );
                    }
                    // ... (your error handling UI remains the same)

                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      child: InfiniteScheduleListWidget(
                        // ... (all properties remain the same)
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
                          _refreshData();
                          setState(() {
                            _calendarRebuildCounter++;
                          });
                          showCustomTopSnackbar(
                            context: context,
                            message: message,
                            isError: false,
                          );
                        },
                        sectionTimeConfig: const [
                          {'label': 'Pagi (05:00 - 10:00)', 'start': 5, 'end': 10},
                          {'label': 'Siang (11:00 - 14:00)', 'start': 11, 'end': 14},
                          {'label': 'Sore (15:00 - 18:00)', 'start': 15, 'end': 18},
                          {'label': 'Malam (19:00 - 04:00)', 'start': 19, 'end': 4},
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Spacer to ensure content isn't hidden by the bottom navbar
              SizedBox(height: bottomNavHeight + 10),
            ],
          ),
        ),
      ),
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

            // Delete from API
            final success = await activityApiService.deleteActivity(
              aktivitas.slug!,
            );

            if (!mounted) return;
            
            if (success) {
              // Refresh all data immediately after successful delete
              await _refreshData();
              // Force calendar rebuild for instant update
              setState(() {
                _calendarRebuildCounter++;
              });
              
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

            final result = await taskApiService.deleteTask(task.slug!);

            if (!mounted) return;
            
            if (result.isSuccess) {
              // Refresh all data immediately after successful delete
              await _refreshData();
              // Force calendar rebuild for instant update
              setState(() {
                _calendarRebuildCounter++;
              });

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

  @override
  void dispose() {
    // Cancel debounce timer to prevent memory leaks
    _debounceTimer?.cancel();
    super.dispose();
  }
}
