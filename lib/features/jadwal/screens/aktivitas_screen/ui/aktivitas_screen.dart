import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// Import widgets dan services yang diperlukan
import 'package:aturin_app/core/widgets/calendar_section_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/category_tabs_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/infinite_schedule_list_widget.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/core/widgets/custom_snackbar_top.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/core/services/api/task/task_api_service.dart';
import 'package:aturin_app/core/utils/category_helper.dart';

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
    super.dispose();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    try {
      // Set loading state
      setState(() {
        _isInitialLoading = true;
      });

      // Fetch activities data using microtask pattern like DataPrefetchGuard
      final activityApiService = Provider.of<ActivityApiService>(
        context,
        listen: false,
      );
      await activityApiService.fetchActivities().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Activities fetch timeout, continuing with cached data');
        },
      );      final taskApiService = Provider.of<TaskApiService>(
        context,
        listen: false,
      );
      
      // Fetch appropriate tasks based on selected date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      
      if (selectedDay.isAtSameMomentAs(today)) {
        await taskApiService.fetchUncompletedTasksToday().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Uncompleted tasks fetch timeout, continuing with cached data');
          },
        );
      } else {
        await taskApiService.fetchTasks().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('Tasks fetch timeout, continuing with cached data');
          },
        );
      }
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
  Future<void> _onDateChanged(DateTime newDate) async {
    if (!mounted) return;

    setState(() {
      selectedDate = newDate;
    });

    final taskApiService = Provider.of<TaskApiService>(context, listen: false);

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDay = DateTime(newDate.year, newDate.month, newDate.day);

      if (selectedDay.isAtSameMomentAs(today)) {
        // For today, fetch uncompleted tasks only
        await taskApiService.fetchUncompletedTasksToday();
      } else {
        // For other dates, fetch all tasks
        await taskApiService.fetchTasks();
      }
    } catch (e) {
      debugPrint('Error refreshing tasks for date: $e');
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
                child: CalendarSectionWidget(
                  selectedDate: selectedDate,
                  focusedDate: focusedDate,
                  calendarFormat: calendarFormat,
                  schedules: [],
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
                ),
              ),

              const SizedBox(height: 20), // Schedule List
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

                      final aktivitasList =
                          activityApiService.activities.where((a) {
                            try {
                              final isSameDate =
                                  a.activityDate.year == selectedDate.year &&
                                  a.activityDate.month == selectedDate.month &&
                                  a.activityDate.day == selectedDate.day;
                              final isCategory =
                                  selectedCategory == 'Semua' ||
                                  a.activityCategory.displayName ==
                                      selectedCategory;
                              return isSameDate && isCategory;
                            } catch (e) {
                              debugPrint('Error filtering aktivitas: $e');
                              return false;
                            }
                          }).toList();                      // Get tasks based on selected date
                      List<Task> availableTasks;
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final selectedDay = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
                      
                      if (selectedDay.isAtSameMomentAs(today)) {
                        // For today, use uncompleted tasks that were fetched by fetchUncompletedTasksToday()
                        availableTasks = taskApiService.tasks.where((t) => !t.isCompleted).toList();
                      } else {
                        // For other dates, filter all tasks by date
                        availableTasks = taskApiService.tasks.where((t) {
                          try {
                            final isSameDate =
                                t.deadline.year == selectedDate.year &&
                                t.deadline.month == selectedDate.month &&
                                t.deadline.day == selectedDate.day;
                            return isSameDate;
                          } catch (e) {
                            debugPrint('Error filtering tasks by date: $e');
                            return false;
                          }
                        }).toList();
                      }
                        // Apply category filter
                      final tasksList = availableTasks.where((t) {
                        try {
                          if (selectedCategory == 'Semua') {
                            return true;
                          }
                          // Konversi task category string ke CategoryOption name untuk perbandingan yang konsisten
                          final categoryOption = CategoryHelper.getCategoryOptionFromString(t.category);
                          return categoryOption.name == selectedCategory;
                        } catch (e) {
                          debugPrint('Error filtering tasks by category: $e');
                          return false;
                        }
                      }).toList();return RefreshIndicator(
                        onRefresh: _refreshData,
                        child: InfiniteScheduleListWidget(
                          tasks: tasksList,
                          schedules: aktivitasList,
                          selectedCategory: selectedCategory,
                          selectedDate: selectedDate,
                          onDateChanged: (date) {
                            _onDateChanged(date);
                          },
                          onEditSchedule:
                              (aktivitas) => _editActivity(aktivitas),
                          onDeleteSchedule:
                              (aktivitas) => _deleteActivity(aktivitas),
                          onEditTask: (task) => _editTask(task),
                          onDeleteTask: (task) => _deleteTask(task),
                          onShowSuccess: (message) {
                            // Reload data after successful delete
                            setState(() {});
                            _refreshData();
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
      builder:
          (dialogContext) => ConfirmDialog(
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
                      message:
                          'Tidak dapat menghapus aktivitas: data tidak lengkap',
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
                  // // Force refresh data
                  // await _refreshData();

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
      builder:
          (dialogContext) => ConfirmDialog(
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
                      message:
                          'Tidak dapat menghapus tugas: data tidak lengkap',
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
                  // Force refresh data
                  await _refreshData();

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
