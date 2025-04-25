import 'package:aturin_app/features/home/services/task_service.dart';
import 'package:aturin_app/features/home/widget/empty_task.dart';
import 'package:aturin_app/features/home/widget/greeting_header.dart';
import 'package:aturin_app/features/home/widget/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    bool taskEmpty = TaskService.tasks.isEmpty;
    final tasks = TaskService.tasks;
    return PopScope(
      // Untuk HomePage, kita biarkan tombol back normal (keluar dari aplikasi)
      canPop: true,
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        appBar: GreetingHeader(),
        bottomNavigationBar: const BottomNavbar(currentIndex: 0),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Tugas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 21, 
                    fontWeight: FontWeight.bold,
                    color: AppTheme.lightTextColor,
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child:
                      taskEmpty
                          ? Center(child: EmptyTask())
                          : ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              final isLast = index == tasks.length - 1;

                              return TimelineWidget(
                                task: task,
                                index: index,
                                isLast: isLast,
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
