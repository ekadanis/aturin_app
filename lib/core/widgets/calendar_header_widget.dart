import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarHeaderWidget extends StatelessWidget {
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;
  final Animation<double> viewTransitionAnimation;
  final Function(bool) onNavigate;

  const CalendarHeaderWidget({
    super.key,
    required this.focusedDate,
    required this.calendarFormat,
    required this.viewTransitionAnimation,
    required this.onNavigate,
  });

  static const List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewTransitionAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getMonthYearText(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF5263F3),
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => onNavigate(false),
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 20,
                  splashRadius: 20,
                  tooltip: calendarFormat == CalendarFormat.month
                      ? 'Bulan sebelumnya'
                      : 'Minggu sebelumnya',
                ),
                IconButton(
                  onPressed: () => onNavigate(true),
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 20,
                  splashRadius: 20,
                  tooltip: calendarFormat == CalendarFormat.month
                      ? 'Bulan berikutnya'
                      : 'Minggu berikutnya',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _getMonthYearText() {
    return '${_monthNames[focusedDate.month - 1]} ${focusedDate.year}';
  }
}