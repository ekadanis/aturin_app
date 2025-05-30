import 'package:aturin_app/core/widgets/calendar_section_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/category_tabs_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivitas_screen/widgets/infinite_schedule_list_widget.dart';
import 'package:aturin_app/features/jadwal/widgets/realtime_status_widget.dart';
import 'package:aturin_app/features/jadwal/widgets/realtime_notification_listener.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/jadwal/services/aktivitas_service.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';
import 'package:aturin_app/features/task/screens/widgets/snackbar.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/task/model/task_model.dart';

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
  CalendarFormat calendarFormat = CalendarFormat.week;  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    focusedDate = DateTime(now.year, now.month, now.day);
    
    // Initialize realtime updates after widget is built
    Future.microtask(() {
      _initializeRealtimeData();
    });
  }
  Future<void> _initializeRealtimeData() async {
    try {
      final aktivitasService = Provider.of<AktivitasService>(context, listen: false);
      
      // Initialize realtime updates
      aktivitasService.initializeRealtimeUpdates();
      
      // Initial data fetch
      await _refreshData();
    } catch (e) {
      debugPrint('Error initializing realtime data: $e');
    }
  }

  @override
  void dispose() {
    // Stop realtime updates when screen is disposed
    try {
      Provider.of<AktivitasService>(context, listen: false).stopRealtimeUpdates();
    } catch (e) {
      debugPrint('Error stopping realtime updates: $e');
    }
    super.dispose();
  }

  Future<void> _refreshData() async {
    try {
      await Provider.of<AktivitasService>(context, listen: false).fetchAktivitas();
      await Provider.of<TaskService>(context, listen: false).fetchTasks();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return RealtimeNotificationListener(
      child: PopScope(
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
            children: [              // Header Section
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Text(
                      'Aktivitas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                    const Spacer(),
                    const RealtimeStatusWidget(),
                  ],
                ),
              ),
              CategoryTabsWidget(
                selectedCategory: selectedCategory,
                onCategoryChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),

              const SizedBox(height: 20),
              // Calendar Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: CalendarSectionWidget(
                  selectedDate: selectedDate,
                  focusedDate: focusedDate,
                  calendarFormat: calendarFormat,
                  schedules: [],
                  onDateSelected: (selectedDay, focusedDay) {
                    setState(() {
                      selectedDate = selectedDay;
                      focusedDate = focusedDay;
                    });
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

              const SizedBox(height: 20),              // Schedule List
              Expanded(
                child: StreamBuilder<List<AktivitasModel>>(
                  stream: Provider.of<AktivitasService>(context, listen: false).aktivitasStream,
                  builder: (context, streamSnapshot) {
                    return Consumer2<AktivitasService, TaskService>(
                      builder: (context, aktivitasService, taskService, _) {
                        // Show loading indicator if data is being fetched and no cached data
                        if (aktivitasService.aktivitasList.isEmpty && taskService.tasks.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final aktivitasList = aktivitasService.aktivitasList.where((a) {
                          final isSameDate = a.activityDate.year == selectedDate.year &&
                              a.activityDate.month == selectedDate.month &&
                              a.activityDate.day == selectedDate.day;
                          final isCategory = selectedCategory == 'Semua' ||
                              a.activityCategory.displayName == selectedCategory;
                          return isSameDate && isCategory;
                        }).toList();

                        final tasksList = taskService.tasks.where((t) {
                          final isSameDate = t.deadline.year == selectedDate.year &&
                              t.deadline.month == selectedDate.month &&
                              t.deadline.day == selectedDate.day;
                          final isCategory = selectedCategory == 'Semua' ||
                              t.category == selectedCategory;
                          return isSameDate && isCategory;
                        }).toList();

                        return RefreshIndicator(
                          onRefresh: _refreshData,
                          child: InfiniteScheduleListWidget(
                            tasks: tasksList,
                            schedules: aktivitasList,
                            selectedCategory: selectedCategory,
                            selectedDate: selectedDate,
                            onDateChanged: (date) {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            onEditSchedule: (aktivitas) => _editActivity(aktivitas),
                            onDeleteSchedule: (aktivitas) => _deleteActivity(aktivitas),
                            onEditTask: (task) => _editTask(task),
                            onDeleteTask: (task) => _deleteTask(task),
                            onToggleTaskCompletion: (task) => _toggleTaskCompletion(task),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),            ],
          ),
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 1),
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

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        iconPath: 'assets/activitycategory/trash-round-tipis.svg',
        title: 'Hapus Tugas',
        description: 'Yakin nih kamu mau hapus tugas ini?',
        confirmText: 'Hapus',
        cancelText: 'Batal',
        isTask: true, // Set true untuk tugas
        onConfirm: () async {
          try {
            final taskService = Provider.of<TaskService>(context, listen: false);
            await taskService.deleteTask(task.id!);
            
            if (mounted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Tugas berhasil dihapus',
                isError: false,
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

  void _toggleTaskCompletion(Task task) async {
    try {
      final taskService = Provider.of<TaskService>(context, listen: false);
      await taskService.toggleTaskCompletion(task.id!);
      
      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: task.isCompleted ? 'Tugas ditandai belum selesai' : 'Tugas ditandai selesai',
          isError: false,
        );
      }
    } catch (e) {
      if (mounted) {
        showCustomTopSnackbar(
          context: context,
          message: 'Gagal mengubah status tugas: ${e.toString()}',
          isError: true,
        );
      }
    }
  }

  void _deleteActivity(AktivitasModel aktivitas) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        iconPath: 'assets/activitycategory/trash-round-tipis.svg',
        title: 'Hapus Aktivitas',
        description: 'Yakin nih kamu mau hapus aktivitas ini?',
        confirmText: 'Hapus',
        cancelText: 'Batal',
        isTask: false, // Pastikan ini diset false untuk aktivitas
        onConfirm: () async {
          try {
            final aktivitasService = Provider.of<AktivitasService>(context, listen: false);
            await aktivitasService.deleteAktivitas(aktivitas.id!);
            
            if (mounted) {
              showCustomTopSnackbar(
                context: context,
                message: 'Aktivitas berhasil dihapus',
                isError: false,
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
          }        },
      ),
    );
  }
}
