import 'package:aturin_app/core/widgets/calendar_section_widget.dart';
import 'package:aturin_app/features/schedule/screens/schedule_screen/widgets/category_tabs_widget.dart';
import 'package:aturin_app/features/schedule/widgets/schedule_list_widget.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/core/widgets/bottom_navbar.dart';
import 'package:aturin_app/routers/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/features/schedule/model/schedule_model.dart';
import 'package:aturin_app/features/alarm/model/alarm.dart';

@RoutePage()
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with TickerProviderStateMixin {
  String selectedCategory = 'Semua';
  DateTime selectedDate = DateTime.now();
  DateTime focusedDate = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;

  // Sample data - moved to a proper data source or state management
  List<ScheduleModel> schedules = [
    ScheduleModel(
      activityId: 1,
      userId: 1,
      alarmId: 1,
      activityTitle: 'Tugas ASD',
      activityDate: DateTime.now(),
      activityStartTime: DateTime.now().add(const Duration(hours: 1)),
      activityCompleteTime: DateTime.now().add(const Duration(hours: 4)),
      activityCategory: ActivityCategory.akademik,
      alarm: AlarmModel(
        alarmId: 1,
        alarmDateTime: DateTime.now().add(const Duration(hours: 1)),
        alarmEnabled: true,
      ),
    ),
    ScheduleModel(
      activityId: 2,
      userId: 1,
      alarmId: 2,
      activityTitle: 'Les Bahasa Jepang',
      activityDate: DateTime.now(),
      activityStartTime: DateTime.now().add(const Duration(hours: 2)),
      activityCompleteTime: DateTime.now().add(const Duration(hours: 6)),
      activityCategory: ActivityCategory.akademik,
    ),
  ];

  // Filter schedules based on selected category and date
  List<ScheduleModel> get filteredSchedules {
    return schedules.where((schedule) {
      // Filter by category
      bool categoryMatch = selectedCategory == 'Semua' || 
          schedule.activityCategory.displayName == selectedCategory;
      
      // Filter by selected date
      bool dateMatch = isSameDay(schedule.activityDate, selectedDate);
      
      return categoryMatch && dateMatch;
    }).toList();
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
        return;
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
            ),
            // Uncommented and using filtered schedules
            // Expanded(
            //   child: ScheduleListWidget(
            //     schedules: filteredSchedules, // Use filtered schedules
            //     selectedCategory: selectedCategory,
            //     onScheduleTap: (schedule) {
            //       context.pushRoute(const ActivityDetailListRoute());
            //     },
            //     onScheduleMenuTap: (schedule) {
            //       _showScheduleMenu(context, schedule);
            //     },
            //   ),
            // ),
          ],
        ),
        bottomNavigationBar: const BottomNavbar(currentIndex: 1),
      ),
    );
  }

}