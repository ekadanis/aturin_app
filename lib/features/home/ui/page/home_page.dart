import 'package:aturin_app/core/widgets/empty_widget.dart';
import 'package:aturin_app/features/home/services/home_service.dart';
import 'package:aturin_app/core/providers/global_state_service.dart';
import 'package:aturin_app/features/task/services/task_service.dart';
import 'package:aturin_app/core/services/api/activities/activity_api_service.dart';

import 'package:aturin_app/features/home/widget/greeting_header.dart';
import 'package:aturin_app/features/home/widget/timeline_widget.dart';
import 'package:aturin_app/features/home/widget/activity_card.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/routers/app_router.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum TaskViewType { tugas, aktivitas }

class _HomePageState extends State<HomePage> {
  late HomeService homeService;
  TaskViewType _selectedView = TaskViewType.tugas;
  @override
  void initState() {
    super.initState();
    debugPrint('🏠 HomePage: initState() called');
    homeService = Provider.of<HomeService>(context, listen: false);
    // Note: fetchData() is already called by DataPrefetchGuard before navigation
    // so we don't need to call it again here to avoid duplicate API calls
    debugPrint(
      '🏠 HomePage: Skipping fetchData() - already called by DataPrefetchGuard',
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tinggi bottom navigation untuk padding scroll
    final bottomNavHeight = kBottomNavigationBarHeight;

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: GreetingHeader(),
        // Mengaktifkan extendBody agar body dapat memperluas hingga di bawah bottom navigation bar
        extendBody: true,
        bottomNavigationBar: const BottomNavbar(currentIndex: 0),        body: Consumer4<
          GlobalStateService,
          HomeService,
          TaskService,
          ActivityApiService
        >(
          builder: (
            context,
            globalState,
            homeService,
            taskService,
            activityService,
            _,
          ) {
            // Get data from GlobalStateService
            final allTasks = globalState.allTasks;
            final allActivities = globalState.allActivities;

            // Use HomeService to compute today's data
            final items =
                _selectedView == TaskViewType.tugas
                    ? homeService.getTodayTasks(allTasks)
                    : homeService.getTodayActivities(allActivities);

            return SafeArea(
              bottom: false, // Menghilangkan padding bawah
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/home_head1.png',
                      width: 100.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        _buildSwitcherButton(
                          TaskViewType.aktivitas,
                          'Aktivitas',
                        ),
                        const SizedBox(width: 12),
                        _buildSwitcherButton(TaskViewType.tugas, 'Tugas'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          items.isEmpty
                              ? Center(
                                child: EmptyWidget(
                                  message:
                                      _selectedView == TaskViewType.tugas
                                          ? 'Tidak ada tugas hari ini.'
                                          : 'Tidak ada aktivitas hari ini.',
                                ),
                              )
                              : ListView.builder(
                                padding: EdgeInsets.all(6),
                                itemCount: items.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == items.length) {
                                    return SizedBox(
                                      height: bottomNavHeight + 40,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 20,
                                          ),
                                          child: Text(
                                            'Semua ${_selectedView == TaskViewType.tugas ? 'tugas' : 'aktivitas'} hari ini ditampilkan',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  } // Display tasks
                                  if (_selectedView == TaskViewType.tugas) {
                                    final task = items[index] as Task;

                                    // Semua tugas menggunakan Timeline Widget
                                    bool previousIsFlagged = false;
                                    final isLast = index == items.length - 1;

                                    if (index > 0) {
                                      final previousTask =
                                          items[index - 1] as Task;
                                      previousIsFlagged =
                                          previousTask.isAlarmEnabled ||
                                          previousTask.status ==
                                              TaskStatus.late;
                                    }

                                    return TimelineWidget(
                                      task: task,
                                      index: index,
                                      isLast: isLast,
                                      previousIsFlagged: previousIsFlagged,                                      onToggleCompletion: () async {
                                        final success = await taskService.toggleTaskCompletion(task.slug);
                                        if (success) {
                                          globalState.onTasksChanged();
                                        }
                                      },
                                      onDelete: () async {
                                        await taskService.deleteTask(
                                          task.slug!,
                                        );
                                        globalState.onTasksChanged();
                                      },                                      onToggleAlarm: () async {
                                        final success = await taskService.toggleTaskAlarmStatus(task.slug!);
                                        if (success) {
                                          globalState.onTasksChanged();
                                        }
                                      },
                                      onViewDetails: () async {
                                        final result = await context.router.push(
                                          TaskDetailListRoute(
                                            tasks:
                                                items
                                                    .whereType<Task>()
                                                    .toList(),
                                            initialIndex: index,
                                          ),
                                        ); // Refresh data if task was modified/deleted
                                        if (result == true && mounted) {
                                          globalState.onTasksChanged();
                                        }
                                      },
                                      currentFilter: "today",
                                    );
                                  }
                                  // Display activities
                                  else {
                                    final activity =
                                        items[index] as AktivitasModel;
                                    return ActivityCard(
                                      activity: activity,
                                      onTap: () async {
                                        final result = await context.router.push(
                                          ActivityDetailListRoute(
                                            activities:
                                                items
                                                    .whereType<AktivitasModel>()
                                                    .toList(),
                                            initialIndex: index,
                                          ),
                                        ); // Refresh data if activity was modified/deleted
                                        if (result == true && mounted) {
                                          globalState.onActivitiesChanged();
                                        }
                                      },
                                      onEdit: () {
                                        // TODO: Navigate to edit activity screen
                                      },
                                      onDelete: () async {
                                        await activityService.deleteActivity(
                                          activity.id!.toString(),
                                        );
                                        globalState.onActivitiesChanged();
                                      },
                                    );
                                  }
                                },
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwitcherButton(TaskViewType type, String label) {
    final isSelected = _selectedView == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = type),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Color(0xFFDCE8F5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
