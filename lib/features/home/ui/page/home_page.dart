import 'package:aturin_app/features/home/services/home_service.dart';
import 'package:aturin_app/features/home/widget/empty_task.dart';
import 'package:aturin_app/features/home/widget/greeting_header.dart';
import 'package:aturin_app/features/home/widget/timeline_widget.dart';
import 'package:aturin_app/features/home/widget/activity_card.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/screens/ui/task_detail_screen.dart';
import 'package:aturin_app/features/jadwal/screens/detailactivity/ui/activity_detail_list.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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
    homeService = Provider.of<HomeService>(context, listen: false);
    homeService.fetchData();
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
        bottomNavigationBar: const BottomNavbar(currentIndex: 0),
        body: Consumer<HomeService>(
          builder: (context, homeService, _) {
            // Get the appropriate data based on selected view
            final items =
                _selectedView == TaskViewType.tugas
                    ? homeService.todayTasks
                    : homeService.todayAktivitas;

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
                        const SizedBox(width: 8),
                        _buildSwitcherButton(TaskViewType.tugas, 'Tugas'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          items.isEmpty
                              ? const Center(child: EmptyTask())
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
                                      previousIsFlagged: previousIsFlagged,
                                      onToggleCompletion:
                                          () => homeService
                                              .toggleTaskCompletion(task.id!),
                                      onDelete:
                                          () =>
                                              homeService.deleteTask(task.id!),
                                      onToggleAlarm:
                                          () =>
                                              homeService.toggleAlarm(task.id!),
                                      onViewDetails: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => TaskDetailScreen(
                                                  task: task,
                                                ),
                                          ),
                                        );
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
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ActivityDetailListPage(
                                                  activities:
                                                      items
                                                          .whereType<
                                                            AktivitasModel
                                                          >()
                                                          .toList(),
                                                  initialIndex: index,
                                                ),
                                          ),
                                        );
                                      },
                                      onEdit: () {
                                        // TODO: Navigate to edit activity screen
                                      },
                                      onDelete:
                                          () => homeService.deleteActivity(
                                            activity.id!,
                                          ),
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
