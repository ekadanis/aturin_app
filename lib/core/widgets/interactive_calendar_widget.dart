import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class InteractiveCalendarWidget extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;
  final List<AktivitasModel> schedules;
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
    required this.calendarFormat,
    required this.schedules,
    required this.viewTransitionController,
    required this.viewTransitionAnimation,
    required this.onDateSelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    required this.onSwitchFormat,
  });

  @override
  Widget build(BuildContext context) {
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
      },
      child: AnimatedBuilder(
        animation: viewTransitionAnimation,
        builder: (context, child) {
          return TableCalendar<AktivitasModel>(
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
  }

  List<AktivitasModel> _getEventsForDay(DateTime day) {
    return schedules
        .where((schedule) => isSameDay(schedule.activityDate, day))
        .toList();
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
      ),
      markersMaxCount: 1,
      markerDecoration: const BoxDecoration(
        color: Color(0xFFFFC550),
        shape: BoxShape.circle,
      ),
      markerMargin: const EdgeInsets.symmetric(horizontal: 1.5),
      markerSizeScale: 0.2,
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
