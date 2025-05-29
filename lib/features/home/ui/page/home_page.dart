import 'package:aturin_app/features/home/services/task_service.dart';
import 'package:aturin_app/features/home/widget/empty_task.dart';
import 'package:aturin_app/features/home/widget/greeting_header.dart';
import 'package:aturin_app/features/home/widget/timeline_widget.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:aturin_app/features/task/screens/ui/task_detail_screen.dart';
import 'package:aturin_app/features/task/screens/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  late TaskService taskService;
  TaskViewType _selectedView = TaskViewType.tugas;

  @override
  void initState() {
    super.initState();
    taskService = Provider.of<TaskService>(context, listen: false);
    taskService.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tinggi bottom navigation untuk padding scroll
    final bottomNavHeight = kBottomNavigationBarHeight;
    final tasks = context.watch<TaskService>().tasks;

    final filteredTasks =
        tasks.where((task) {
          return _selectedView == TaskViewType.tugas
              ? task.category.toLowerCase() == 'akademik'
              : task.category.toLowerCase() != 'akademik';
        }).toList();

    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        appBar: GreetingHeader(),
        // Mengaktifkan extendBody agar body dapat memperluas hingga di bawah bottom navigation bar
        extendBody: true,
        bottomNavigationBar: const BottomNavbar(currentIndex: 0),
        body: Consumer<TaskService>(
          builder: (context, taskService, _) {
            final tasks = taskService.tasks;

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
                          'Aktifitas',
                        ),
                        const SizedBox(width: 8),
                        _buildSwitcherButton(TaskViewType.tugas, 'Tugas'),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Expanded(
                      child:
                          filteredTasks.isEmpty
                              ? const Center(child: EmptyTask())
                              : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: filteredTasks.length + 1,
                                itemBuilder: (context, index) {
                                  if (index == filteredTasks.length) {
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
                                  }

                                  final task = filteredTasks[index];

                                  if (task.category == 'Akademik') {
                                    bool previousIsFlagged = false;
                                    final isLast =
                                        index == filteredTasks.length - 1;

                                    if (index > 0) {
                                      final previousTask =
                                          filteredTasks[index - 1];
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
                                          () => taskService
                                              .toggleTaskCompletion(task.id!),
                                      onDelete:
                                          () =>
                                              taskService.deleteTask(task.id!),
                                      onToggleAlarm:
                                          () =>
                                              taskService.toggleAlarm(task.id!),
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
                                  } else {
                                    return TaskCard(
                                      task: task,
                                      currentFilter: "today",
                                      onToggleCompletion:
                                          () => taskService
                                              .toggleTaskCompletion(task.id!),
                                      onDelete:
                                          () =>
                                              taskService.deleteTask(task.id!),
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
                                      onToggleAlarm:
                                          () =>
                                              taskService.toggleAlarm(task.id!),
                                      showCheckbox: false,
                                      showStatus: false,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
