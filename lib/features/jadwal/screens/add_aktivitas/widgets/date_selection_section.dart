import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:aturin_app/core/widgets/calendar_section_widget.dart';

class DateSelectionSection extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;
  final Function(DateTime selectedDay, DateTime focusedDay) onDateSelected;
  final Function(DateTime focusedDay) onPageChanged;
  final Function(CalendarFormat format) onFormatChanged;

  const DateSelectionSection({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.calendarFormat,
    required this.onDateSelected,
    required this.onPageChanged,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Pilih hari',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        CalendarSectionWidget(
          selectedDate: selectedDate,
          focusedDate: focusedDate,
          calendarFormat: calendarFormat,
          schedules: const [], // Empty list since we're adding a new schedule
          onDateSelected: onDateSelected,
          onPageChanged: onPageChanged,
          onFormatChanged: onFormatChanged,
        ),
      ],
    );
  }
}
