// interactive_calendar_widget.dart

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
  final Function(DateTime, DateTime) onDateSelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;
  final DateTime? firstAllowedDate;

  const InteractiveCalendarWidget({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.calendarFormat,
    required this.schedules,
    required this.tasks,
    required this.onDateSelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    this.firstAllowedDate,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<dynamic>(
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
        titleTextStyle: TextStyle(fontSize: 0), // Header is handled by parent
      ),
      daysOfWeekStyle: _buildDaysOfWeekStyle(),
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: onDateSelected,
      onPageChanged: onPageChanged,
      onFormatChanged: onFormatChanged,
      availableGestures: AvailableGestures.horizontalSwipe,
      enabledDayPredicate: (day) {
        if (firstAllowedDate != null) {
          final startOfDay = DateTime(
              firstAllowedDate!.year, firstAllowedDate!.month, firstAllowedDate!.day);
          return !day.isBefore(startOfDay);
        }
        return true;
      },
    );
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    final events = <dynamic>{}; // Use a Set to avoid duplicate markers

    // Add activities for this day
    events.addAll(
        schedules.where((schedule) => isSameDay(schedule.activityDate, day)));

    // Check if there are uncompleted tasks for this day
    final hasUncompletedTasks =
        tasks.any((task) => isSameDay(task.deadline, day) && !task.isCompleted);

    // If there are tasks, add a generic object to the set to ensure a marker is shown
    if (hasUncompletedTasks) {
      events.add(Object()); // Using Object() is a lightweight way to add a unique item
    }

    return events.toList();
  }

  CalendarStyle _buildCalendarStyle() {
    return CalendarStyle(
      todayDecoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF5263F3), width: 1.5),
      ),
      todayTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF5263F3)),
      selectedDecoration:
          const BoxDecoration(color: Color(0xFF5263F3), shape: BoxShape.circle),
      selectedTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
      defaultTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF252525)),
      weekendTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.red),
      outsideTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[400]),
      markersMaxCount: 1,
      markerDecoration: BoxDecoration(
        color: const Color(0xFFFFC550),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      markerMargin: const EdgeInsets.only(top: 8),
      markerSize: 6.0,
      cellMargin: const EdgeInsets.all(6),
    );
  }

  DaysOfWeekStyle _buildDaysOfWeekStyle() {
    return DaysOfWeekStyle(
      weekdayStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600]),
      weekendStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600]),
    );
  }
}