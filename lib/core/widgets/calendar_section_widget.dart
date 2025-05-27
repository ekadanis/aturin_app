import 'package:aturin_app/core/widgets/calendar_header_widget.dart';
import 'package:aturin_app/core/widgets/interactive_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';


class CalendarSectionWidget extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;
  final List<AktivitasModel> schedules;
  final Function(DateTime, DateTime) onDateSelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;

  const CalendarSectionWidget({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.calendarFormat,
    required this.schedules,
    required this.onDateSelected,
    required this.onPageChanged,
    required this.onFormatChanged,
  });

  @override
  State<CalendarSectionWidget> createState() => _CalendarSectionWidgetState();
}

class _CalendarSectionWidgetState extends State<CalendarSectionWidget>
    with TickerProviderStateMixin {
  late AnimationController _viewTransitionController;
  late Animation<double> _viewTransitionAnimation;

  @override
  void initState() {
    super.initState();
    _viewTransitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _viewTransitionAnimation = CurvedAnimation(
      parent: _viewTransitionController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _viewTransitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          CalendarHeaderWidget(
            focusedDate: widget.focusedDate,
            calendarFormat: widget.calendarFormat,
            viewTransitionAnimation: _viewTransitionAnimation,
            onNavigate: _navigatePeriod,
          ),
          const SizedBox(height: 16),
          InteractiveCalendarWidget(
            selectedDate: widget.selectedDate,
            focusedDate: widget.focusedDate,
            calendarFormat: widget.calendarFormat,
            schedules: widget.schedules,
            viewTransitionController: _viewTransitionController,
            viewTransitionAnimation: _viewTransitionAnimation,
            onDateSelected: widget.onDateSelected,
            onPageChanged: widget.onPageChanged,
            onFormatChanged: widget.onFormatChanged,
            onSwitchFormat: _switchCalendarFormat,
          ),
          const SizedBox(height: 12),
          _buildCalendarIndicator(),
        ],
      ),
    );
  }

  void _switchCalendarFormat(CalendarFormat format) {
    if (widget.calendarFormat != format) {
      widget.onFormatChanged(format);
      _viewTransitionController.forward().then((_) {
        _viewTransitionController.reset();
      });
    }
  }

  void _navigatePeriod(bool forward) {
    _viewTransitionController.forward(from: 0.0);

    DateTime newFocusedDate;
    if (widget.calendarFormat == CalendarFormat.month) {
      newFocusedDate = DateTime(
        widget.focusedDate.year,
        widget.focusedDate.month + (forward ? 1 : -1),
        1,
      );
    } else {
      newFocusedDate = widget.focusedDate.add(Duration(days: forward ? 7 : -7));
    }

    widget.onPageChanged(newFocusedDate);

    Future.delayed(const Duration(milliseconds: 300), () {
      _viewTransitionController.reset();
    });
  }

  Widget _buildCalendarIndicator() {
    return GestureDetector(
      onTap: () {
        _switchCalendarFormat(
          widget.calendarFormat == CalendarFormat.week
              ? CalendarFormat.month
              : CalendarFormat.week,
        );
      },
      child: AnimatedBuilder(
        animation: _viewTransitionAnimation,
        builder: (context, child) {
          return Column(
            children: [
              AnimatedOpacity(
                opacity: _viewTransitionController.value > 0.3 ? 0.7 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    widget.calendarFormat == CalendarFormat.week
                        ? "Geser ke bawah untuk tampilan bulan"
                        : "Geser ke atas untuk tampilan minggu",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40 + (_viewTransitionAnimation.value * 20),
                height: 4 + (_viewTransitionAnimation.value * 1),
                decoration: BoxDecoration(
                  color: widget.calendarFormat == CalendarFormat.month
                      ? const Color(0xFF5263F3).withOpacity(0.7)
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
