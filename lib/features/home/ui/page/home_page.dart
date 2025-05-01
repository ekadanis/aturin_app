import 'package:aturin_app/features/home/services/task_service.dart' as home;
import 'package:aturin_app/features/home/widget/empty_task.dart';
import 'package:aturin_app/features/home/widget/greeting_header.dart';
import 'package:aturin_app/features/home/widget/timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch tasks when the page loads
      Provider.of<home.TaskService>(context, listen: false).fetchTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan tinggi bottom navigation untuk padding scroll
    final bottomNavHeight = kBottomNavigationBarHeight;
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppTheme.lightBackgroundColor,
        appBar: GreetingHeader(),
        // Mengaktifkan extendBody agar body dapat memperluas hingga di bawah bottom navigation bar
        extendBody: true,
        bottomNavigationBar: const BottomNavbar(currentIndex: 0),
        body: Consumer<home.TaskService>(
          builder: (context, taskService, _) {
            final tasks = taskService.tasks;
            
            return SafeArea(
              bottom: false, // Menghilangkan padding bawah
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'Tugas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 21, 
                        fontWeight: FontWeight.bold,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: tasks.isEmpty 
                        ? const Center(child: EmptyTask())
                        : ListView.builder(
                            // Menghilangkan padding karena akan kita tambahkan sebagai item terpisah
                            padding: EdgeInsets.zero,
                            itemCount: tasks.length + 1, // +1 untuk item gap di bagian bawah
                            itemBuilder: (context, index) {
                              // Item terakhir adalah gap
                              if (index == tasks.length) {
                                // Menambahkan SizedBox sebagai gap yang jelas di bagian bawah
                                return SizedBox(
                                  height: bottomNavHeight + 40, // Margin yang lebih besar untuk kejelasan visual
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Text(
                                        'Semua tugas hari ini ditampilkan',
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
            );
          },
        ),
      ),
    );
  }
}
