import 'package:aturin_app/core/widgets/calendar_section_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivtias_screen/widgets/category_tabs_widget.dart';
import 'package:aturin_app/features/jadwal/screens/aktivtias_screen/widgets/infinite_schedule_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';
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
  CalendarFormat calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = DateTime(now.year, now.month, now.day);
    focusedDate = DateTime(now.year, now.month, now.day);
  }

  // Enhanced dummy data with proper slug generation
  List<AktivitasModel> schedules = [
    // Today's activities (2025-05-27)
    AktivitasModel(
      activityId: 1,
      userId: 1,
      alarmId: 1,
      activityTitle: 'Tugas Algoritma dan Struktur Data',
      activityDate: DateTime(2025, 5, 27),
      activityStartTime: DateTime(2025, 5, 27, 9, 0),
      activityCompleteTime: DateTime(2025, 5, 27, 12, 0),
      activityCategory: ActivityCategory.akademik,
      slug: 'aktivitas-algoritma-dan-struktur-data',
      alarm: AlarmModel(
        alarmId: 1,
        alarmDateTime: DateTime(2025, 5, 27, 8, 45),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 2,
      userId: 1,
      alarmId: 2,
      activityTitle: 'Les Bahasa Jepang',
      activityDate: DateTime(2025, 5, 27),
      activityStartTime: DateTime(2025, 5, 27, 14, 0),
      activityCompleteTime: DateTime(2025, 5, 27, 16, 0),
      activityCategory: ActivityCategory.akademik,
      slug: 'aktivitas-les-bahasa-jepang',
      alarm: AlarmModel(
        alarmId: 2,
        alarmDateTime: DateTime(2025, 5, 27, 13, 45),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 3,
      userId: 1,
      alarmId: 3,
      activityTitle: 'Coding Practice - Flutter',
      activityDate: DateTime(2025, 5, 27),
      activityStartTime: DateTime(2025, 5, 27, 19, 0),
      activityCompleteTime: DateTime(2025, 5, 27, 21, 0),
      activityCategory: ActivityCategory.akademik,
      slug: 'aktivitas-coding-practice-flutter',
    ),
    
    // Tomorrow's activities (2025-05-28)
    AktivitasModel(
      activityId: 4,
      userId: 1,
      alarmId: 4,
      activityTitle: 'Meeting Tim Project Mobile',
      activityDate: DateTime(2025, 5, 28),
      activityStartTime: DateTime(2025, 5, 28, 10, 0),
      activityCompleteTime: DateTime(2025, 5, 28, 12, 0),
      activityCategory: ActivityCategory.pekerjaan,
      slug: 'aktivitas-meeting-tim-project-mobile',
      alarm: AlarmModel(
        alarmId: 4,
        alarmDateTime: DateTime(2025, 5, 28, 9, 45),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 5,
      userId: 1,
      alarmId: 5,
      activityTitle: 'Presentasi Proposal Skripsi',
      activityDate: DateTime(2025, 5, 28),
      activityStartTime: DateTime(2025, 5, 28, 14, 0),
      activityCompleteTime: DateTime(2025, 5, 28, 16, 0),
      activityCategory: ActivityCategory.akademik,
      slug: 'aktivitas-presentasi-proposal-skripsi',
      alarm: AlarmModel(
        alarmId: 5,
        alarmDateTime: DateTime(2025, 5, 28, 13, 30),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 6,
      userId: 1,
      alarmId: 6,
      activityTitle: 'Gym Session - Chest & Triceps',
      activityDate: DateTime(2025, 5, 28),
      activityStartTime: DateTime(2025, 5, 28, 18, 0),
      activityCompleteTime: DateTime(2025, 5, 28, 20, 0),
      activityCategory: ActivityCategory.olahraga,
      slug: 'aktivitas-gym-session-chest-triceps',
    ),
    
    // Yesterday's activities (2025-05-26)
    AktivitasModel(
      activityId: 7,
      userId: 1,
      alarmId: 7,
      activityTitle: 'Jogging Pagi di Taman',
      activityDate: DateTime(2025, 5, 26),
      activityStartTime: DateTime(2025, 5, 26, 6, 0),
      activityCompleteTime: DateTime(2025, 5, 26, 7, 30),
      activityCategory: ActivityCategory.olahraga,
      slug: 'aktivitas-jogging-pagi-di-taman',
      alarm: AlarmModel(
        alarmId: 7,
        alarmDateTime: DateTime(2025, 5, 26, 5, 45),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 8,
      userId: 1,
      alarmId: 8,
      activityTitle: 'Review Kode dengan Senior Developer',
      activityDate: DateTime(2025, 5, 26),
      activityStartTime: DateTime(2025, 5, 26, 15, 0),
      activityCompleteTime: DateTime(2025, 5, 26, 17, 0),
      activityCategory: ActivityCategory.pekerjaan,
      slug: 'aktivitas-review-kode-dengan-senior-developer',
    ),
    
    // Future activities (2025-05-29)
    AktivitasModel(
      activityId: 9,
      userId: 1,
      alarmId: 9,
      activityTitle: 'Dinner with College Friends',
      activityDate: DateTime(2025, 5, 29),
      activityStartTime: DateTime(2025, 5, 29, 19, 0),
      activityCompleteTime: DateTime(2025, 5, 29, 22, 0),
      activityCategory: ActivityCategory.sosial,
      slug: 'aktivitas-dinner-with-college-friends',
      alarm: AlarmModel(
        alarmId: 9,
        alarmDateTime: DateTime(2025, 5, 29, 18, 30),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 10,
      userId: 1,
      alarmId: 10,
      activityTitle: 'Movie Night - Avengers Marathon',
      activityDate: DateTime(2025, 5, 29),
      activityStartTime: DateTime(2025, 5, 29, 13, 0),
      activityCompleteTime: DateTime(2025, 5, 29, 18, 0),
      activityCategory: ActivityCategory.hiburan,
      slug: 'aktivitas-movie-night-avengers-marathon',
    ),
    
    // Weekend spiritual activities (2025-05-30)
    AktivitasModel(
      activityId: 11,
      userId: 1,
      alarmId: 11,
      activityTitle: 'Sholat Jumat di Masjid Campus',
      activityDate: DateTime(2025, 5, 30),
      activityStartTime: DateTime(2025, 5, 30, 12, 0),
      activityCompleteTime: DateTime(2025, 5, 30, 13, 0),
      activityCategory: ActivityCategory.spiritual,
      slug: 'aktivitas-sholat-jumat-di-masjid-campus',
      alarm: AlarmModel(
        alarmId: 11,
        alarmDateTime: DateTime(2025, 5, 30, 11, 45),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 12,
      userId: 1,
      alarmId: 12,
      activityTitle: 'Kajian Islam - Fiqih Ibadah',
      activityDate: DateTime(2025, 5, 30),
      activityStartTime: DateTime(2025, 5, 30, 15, 0),
      activityCompleteTime: DateTime(2025, 5, 30, 17, 0),
      activityCategory: ActivityCategory.spiritual,
      slug: 'aktivitas-kajian-islam-fiqih-ibadah',
    ),
    
    // Personal care activities (2025-05-31)
    AktivitasModel(
      activityId: 13,
      userId: 1,
      alarmId: 13,
      activityTitle: 'Potong Rambut & Grooming',
      activityDate: DateTime(2025, 5, 31),
      activityStartTime: DateTime(2025, 5, 31, 10, 0),
      activityCompleteTime: DateTime(2025, 5, 31, 11, 30),
      activityCategory: ActivityCategory.pribadi,
      slug: 'aktivitas-potong-rambut-grooming',
    ),
    AktivitasModel(
      activityId: 14,
      userId: 1,
      alarmId: 14,
      activityTitle: 'Power Nap - Istirahat Siang',
      activityDate: DateTime(2025, 5, 31),
      activityStartTime: DateTime(2025, 5, 31, 14, 0),
      activityCompleteTime: DateTime(2025, 5, 31, 15, 30),
      activityCategory: ActivityCategory.istirahat,
      slug: 'aktivitas-power-nap-istirahat-siang',
    ),
    
    // Additional work activities (2025-06-01)
    AktivitasModel(
      activityId: 15,
      userId: 1,
      alarmId: 15,
      activityTitle: 'Client Meeting - UI/UX Discussion',
      activityDate: DateTime(2025, 6, 1),
      activityStartTime: DateTime(2025, 6, 1, 9, 0),
      activityCompleteTime: DateTime(2025, 6, 1, 11, 0),
      activityCategory: ActivityCategory.pekerjaan,
      slug: 'aktivitas-client-meeting-ui-ux-discussion',
      alarm: AlarmModel(
        alarmId: 15,
        alarmDateTime: DateTime(2025, 6, 1, 8, 30),
        alarmEnabled: true,
      ),
    ),
    AktivitasModel(
      activityId: 16,
      userId: 1,
      alarmId: 16,
      activityTitle: 'Code Review & Testing API',
      activityDate: DateTime(2025, 6, 1),
      activityStartTime: DateTime(2025, 6, 1, 13, 0),
      activityCompleteTime: DateTime(2025, 6, 1, 17, 0),
      activityCategory: ActivityCategory.pekerjaan,
      slug: 'aktivitas-code-review-testing-api',
    ),
    
    // Entertainment activities (2025-06-02)
    AktivitasModel(
      activityId: 17,
      userId: 1,
      alarmId: 17,
      activityTitle: 'Gaming Session - Mobile Legends',
      activityDate: DateTime(2025, 6, 2),
      activityStartTime: DateTime(2025, 6, 2, 20, 0),
      activityCompleteTime: DateTime(2025, 6, 2, 22, 30),
      activityCategory: ActivityCategory.hiburan,
      slug: 'aktivitas-gaming-session-mobile-legends',
    ),
    AktivitasModel(
      activityId: 18,
      userId: 1,
      alarmId: 18,
      activityTitle: 'Baca Novel - Laskar Pelangi',
      activityDate: DateTime(2025, 6, 2),
      activityStartTime: DateTime(2025, 6, 2, 15, 0),
      activityCompleteTime: DateTime(2025, 6, 2, 17, 0),
      activityCategory: ActivityCategory.hiburan,
      slug: 'aktivitas-baca-novel-laskar-pelangi',
    ),
    
    // Social activities (2025-06-03)
    AktivitasModel(
      activityId: 19,
      userId: 1,
      alarmId: 19,
      activityTitle: 'Ngopi Bareng Teman SMA',
      activityDate: DateTime(2025, 6, 3),
      activityStartTime: DateTime(2025, 6, 3, 16, 0),
      activityCompleteTime: DateTime(2025, 6, 3, 18, 0),
      activityCategory: ActivityCategory.sosial,
      slug: 'aktivitas-ngopi-bareng-teman-sma',
    ),
    AktivitasModel(
      activityId: 20,
      userId: 1,
      alarmId: 20,
      activityTitle: 'Video Call dengan Keluarga',
      activityDate: DateTime(2025, 6, 3),
      activityStartTime: DateTime(2025, 6, 3, 19, 30),
      activityCompleteTime: DateTime(2025, 6, 3, 21, 0),
      activityCategory: ActivityCategory.sosial,
      slug: 'aktivitas-video-call-dengan-keluarga',
    ),
  ];
  // Dummy Task data with slugs
  List<Task> tasks = [
    Task(
      id: 1,
      title: 'Selesaikan Tugas Database Design',
      deadline: DateTime(2025, 5, 27, 23, 59),
      estimatedDuration: const Duration(hours: 4),
      category: 'Akademik',
      isAlarmEnabled: true,
      alarmDateTime: DateTime(2025, 5, 28, 10, 0),
      slug: 'tugas-selesaikan-tugas-database-design',
    ),
    Task(
      id: 2,
      title: 'Fix Bug pada Aplikasi Flutter',
      deadline: DateTime(2025, 5, 27, 17, 0),
      estimatedDuration: const Duration(hours: 2),
      category: 'Pekerjaan',
      isAlarmEnabled: true,
      alarmDateTime: DateTime(2025, 5, 27, 15, 0),
      slug: 'tugas-fix-bug-pada-aplikasi-flutter',
    ),
    Task(
      id: 3,
      title: 'Buat Presentasi Project Akhir',
      deadline: DateTime(2025, 5, 27, 14, 0),
      estimatedDuration: const Duration(hours: 3, minutes: 30),
      category: 'Akademik',
      isAlarmEnabled: false,
      slug: 'tugas-buat-presentasi-project-akhir',
    ),
    Task(
      id: 4,
      title: 'Kumpulkan Laporan Prakerin',
      deadline: DateTime(2025, 5, 27, 9, 0),
      estimatedDuration: const Duration(hours: 1, minutes: 30),
      category: 'Akademik',
      isAlarmEnabled: true,
      alarmDateTime: DateTime(2025, 5, 30, 7, 0),
      slug: 'tugas-kumpulkan-laporan-prakerin',
    ),
    Task(
      id: 5,
      title: 'Review Kode Tim Development',
      deadline: DateTime(2025, 5, 27, 16, 0),
      estimatedDuration: const Duration(hours: 2, minutes: 15),
      category: 'Pekerjaan',
      isAlarmEnabled: true,
      alarmDateTime: DateTime(2025, 5, 27, 14, 0),
      slug: 'tugas-review-kode-tim-development',
    ),
    Task(
      id: 6,
      title: 'Siapkan Materi Workshop Flutter',
      deadline: DateTime(2025, 5, 27, 10, 0),
      estimatedDuration: const Duration(hours: 5),
      category: 'Pekerjaan',
      isAlarmEnabled: false,
      slug: 'tugas-siapkan-materi-workshop-flutter',
    ),
        Task(
      id: 6,
      title: 'AKU ADALAH ULTARAMAN',
      deadline: DateTime(2025, 5, 27, 10, 0),
      estimatedDuration: const Duration(hours: 5),
      category: 'Pekerjaan',
      isAlarmEnabled: false,
      slug: 'tugas-AKU ADALAH ULTARAMAN',
    ),
  ];


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
        appBar: AppBar(
          title: Text(
            'Jadwal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTextColor,
            ),
          ),
          elevation: 0,
          backgroundColor: AppTheme.lightBackgroundColor,
          foregroundColor: AppTheme.lightTextColor,
          actions: [
            IconButton(
              onPressed: () {
                // Show debug info about current data
                _showDebugInfo();
              },
              icon: const Icon(Icons.info_outline),
              tooltip: 'Debug Info',
            ),
          ],
        ),
        body: Column(
          children: [
            CategoryTabsWidget(
              selectedCategory: selectedCategory,
              onCategoryChanged: (category) {
                setState(() {
                  selectedCategory = category;
                });
              },
            ),
            CalendarSectionWidget(
              selectedDate: selectedDate,
              focusedDate: focusedDate,
              calendarFormat: calendarFormat,
              schedules: schedules,
              onDateSelected: (selectedDay, focusedDay) {
                setState(() {
                  selectedDate = selectedDay;
                  focusedDate = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  focusedDate = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  calendarFormat = format;
                });
              },
            ),            Expanded(
              child: InfiniteScheduleListWidget(
                selectedDate: selectedDate,
                schedules: schedules,
                tasks: tasks,
                selectedCategory: selectedCategory,
                onDateChanged: (newDate) {
                  setState(() {
                    selectedDate = newDate;
                    focusedDate = newDate;
                  });
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      ),
    );
  }

  // Debug method to show current data info
  void _showDebugInfo() {
    final totalActivities = schedules.length;
    final totalTasks = tasks.length;
    final activitiesWithSlug = schedules.where((s) => s.slug != null).length;
    final tasksWithSlug = tasks.where((t) => t.slug != null).length;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Info'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Activities: $totalActivities'),
            Text('Activities with Slug: $activitiesWithSlug'),
            Text('Total Tasks: $totalTasks'),
            Text('Tasks with Slug: $tasksWithSlug'),
            const SizedBox(height: 16),
            const Text('Current Date: 2025-05-27'),
            Text('Selected Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
            Text('Selected Category: $selectedCategory'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}