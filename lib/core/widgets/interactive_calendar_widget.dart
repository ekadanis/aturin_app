import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class InteractiveCalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;
  final List<AktivitasModel> schedules;
  final List<Task> tasks;
  final AnimationController viewTransitionController;
  final Animation<double> viewTransitionAnimation;
  final Function(DateTime, DateTime) onDateSelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;
  final Function(CalendarFormat) onSwitchFormat;

  const InteractiveCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.calendarFormat,    required this.schedules,
    required this.tasks,
    required this.viewTransitionController,
    required this.viewTransitionAnimation,
    required this.onDateSelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    required this.onSwitchFormat,
  });  @override
  Widget build(BuildContext context) {
    // Create a stable key based on data length only - avoid excessive rebuilds
    final dataKey = ValueKey('cal_${schedules.length}_${tasks.length}');
    
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final delta = details.delta.dy;
        if (calendarFormat == CalendarFormat.week && delta > 0 ||
            calendarFormat == CalendarFormat.month && delta < 0) {
          viewTransitionController.value += delta.abs() / 500;
        }
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          final dragThreshold =
              details.primaryVelocity!.abs() > 300 ? 30.0 : 80.0;

          if (details.primaryVelocity! > dragThreshold &&
              calendarFormat != CalendarFormat.month) {
            onSwitchFormat(CalendarFormat.month);
          } else if (details.primaryVelocity! < -dragThreshold &&
              calendarFormat != CalendarFormat.week) {
            onSwitchFormat(CalendarFormat.week);
          } else {
            viewTransitionController.reverse();
          }
        }
      },      child: AnimatedBuilder(
        animation: viewTransitionAnimation,
        builder: (context, child) {
          return TableCalendar<AktivitasModel>(
            key: dataKey, // Force rebuild when data changes
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDate,
            selectedDayPredicate: (day) => isSameDay(selectedDate, day),
            calendarFormat: calendarFormat,
            locale: 'id_ID',
            eventLoader: _getEventsForDay,
            calendarStyle: _buildCalendarStyle(),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: false,
              leftChevronVisible: false,
              rightChevronVisible: false,
              headerPadding: EdgeInsets.zero,
              headerMargin: EdgeInsets.zero,
              titleTextStyle: TextStyle(fontSize: 0),
            ),
            daysOfWeekStyle: _buildDaysOfWeekStyle(),
            daysOfWeekVisible: true,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: onDateSelected,
            onPageChanged: onPageChanged,
            onFormatChanged: onFormatChanged,
            availableGestures: AvailableGestures.horizontalSwipe,
          );
        },
      ),
    );
  }  List<AktivitasModel> _getEventsForDay(DateTime day) {
    // Get activities for this day
    final activitiesForDay = schedules
        .where((schedule) => isSameDay(schedule.activityDate, day))
        .toList();
    
    // Check if there are UNCOMPLETED tasks for this day - filter out completed tasks
    final hasUncompletedTasksForDay = tasks.any((task) => 
        isSameDay(task.deadline, day) && !task.isCompleted);
    
    // Create list of events to show marker
    final events = <AktivitasModel>[];
    
    // Add real activities
    events.addAll(activitiesForDay);
    
    // If there are uncompleted tasks but no activities, create a dummy entry to show the marker
    if (hasUncompletedTasksForDay && activitiesForDay.isEmpty) {
      // Create a minimal dummy activity just to trigger marker display
      final dummyActivity = AktivitasModel(
        activityTitle: 'Tasks for ${day.day}/${day.month}',
        activityDate: day,
        activityStartTime: day,
        activityCompleteTime: day,
        activityCategory: ActivityCategory.akademik,
      );      events.add(dummyActivity);
    }
    
    return events;
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      todayDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF5263F3),
          width: 1.5,
        ),
      ),
      todayTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF5263F3),
      ),
      selectedDecoration: const BoxDecoration(
        color: Color(0xFF5263F3),
        shape: BoxShape.circle,
      ),
      selectedTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      defaultDecoration: const BoxDecoration(
        color: Color(0xFFEEF3FF),
        shape: BoxShape.circle,
      ),
      defaultTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF5263F3),
      ),
      weekendDecoration: const BoxDecoration(
        color: Color(0xFFEEF3FF),
        shape: BoxShape.circle,
      ),
      weekendTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.red,
      ),
      outsideTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey[400],
      ),      markersMaxCount: 1,
      markerDecoration: BoxDecoration(
        color: const Color(0xFFFFC550), // Yellow color for markers
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1,
        ),
      ),
      markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
      markerSizeScale: 0.25, // Make markers slightly bigger
      cellMargin: const EdgeInsets.all(4),
      cellPadding: EdgeInsets.zero,
    );
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle() {
    return DaysOfWeekStyle(
      weekdayStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
      weekendStyle: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey[600],
      ),
    );
  }
}
