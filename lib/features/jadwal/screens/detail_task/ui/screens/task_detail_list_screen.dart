import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../task/model/task_model.dart';
import '../../../../../profile/models/user.dart';
import '../../../../../alarm/model/alarm.dart';
import '../widgets/task_detail_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/core/widgets/confirm_dialog.dart';

@RoutePage()
class TaskDetailListScreen extends StatefulWidget {
  const TaskDetailListScreen({Key? key}) : super(key: key);

  @override
  State<TaskDetailListScreen> createState() => _TaskDetailListScreenState();
}

class _TaskDetailListScreenState extends State<TaskDetailListScreen> {
  late final PageController _pageController;
  int _currentPageIndex = 0;
  // Dummy data untuk testing - sesuai dengan model database baru
  final List<Task> _tasks = [
    Task(
      id: 1,
      userId: 1,
      title: 'Tugas GIS',
      description: 'Belajar per lembar tentang sistem informasi geografis',
      deadline: DateTime(2024, 3, 20, 14, 0),
      estimatedDuration: const Duration(minutes: 120),
      category: 'akademik',
      taskStatus: TaskDatabaseStatus.selesai,
      alarmId: 1,
      slug: 'tugas-gis',
      // Relasi dengan User
      user: User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        slug: 'john-doe',
      ),
      // Relasi dengan AlarmModel
      alarm: AlarmModel(
        id: 1,
        alarmDateTime: DateTime(2024, 3, 20, 13, 30),
        alarmEnabled: true,
        slug: 'alarm-tugas-gis',
      ),
    ),
    Task(
      id: 2,
      userId: 1,
      title: 'Meeting Project',
      description: 'Diskusi progress project dengan tim development',
      deadline: DateTime(2024, 3, 21, 10, 0),
      estimatedDuration: const Duration(hours: 2),
      category: 'pekerjaan',
      taskStatus: TaskDatabaseStatus.belumSelesai,
      slug: 'meeting-project',
      // Relasi dengan User
      user: User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        slug: 'john-doe',
      ),
      // Tidak ada alarm
      alarm: null,
    ),
    Task(
      id: 3,
      userId: 1,
      title: 'Les Bahasa Jepang',
      description: 'Belajar hiragana dan katakana dasar',
      deadline: DateTime(2024, 3, 22, 16, 30),
      estimatedDuration: const Duration(hours: 1, minutes: 30),
      category: 'hiburan',
      taskStatus: TaskDatabaseStatus.belumSelesai,
      alarmId: 2,
      slug: 'les-bahasa-jepang',
      // Relasi dengan User
      user: User(
        id: 1,
        name: 'John Doe',
        email: 'john@example.com',
        slug: 'john-doe',
      ),
      // Relasi dengan AlarmModel
      alarm: AlarmModel(
        id: 2,
        alarmDateTime: DateTime(2024, 3, 22, 16, 0),
        alarmEnabled: true,
        slug: 'alarm-les-jepang',
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _pageController.addListener(() {
      final page = _pageController.page ?? 0;
      final newIndex = page.round();
      if (newIndex != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_detail.png',
              fit: BoxFit.cover,
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => context.router.pop(),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Detail Tugas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // Task Cards
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        final isSelected = index == _currentPageIndex;

                        return AnimatedScale(
                          scale: isSelected ? 1.0 : 0.9,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: TaskDetailCard(
                            task: task,
                            isSelected: isSelected,
                            onTap: () {
                              // Handle card tap
                              print('Task tapped: ${task.title}');
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),

          // Action Buttons
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Edit Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/activitycategory/edit-pencil.svg',
                      width: 48,
                      height: 48,
                    ),
                    onPressed: () {
                      // Handle edit
                      final currentTask = _tasks[_currentPageIndex];
                      print('Edit task: ${currentTask.title}');
                    },
                  ),
                ),

                const SizedBox(width: 64),

                // Delete Button
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECEC),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 3,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/activitycategory/trash.svg',
                      width: 48,
                      height: 48,
                    ),                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          isTask: true,
                          onConfirm: () {
                            // Handle delete task
                            final currentTask = _tasks[_currentPageIndex];
                            print('Delete task: ${currentTask.title}');
                            Navigator.pop(context); // Close dialog
                            Navigator.pop(context); // Close detail screen
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
