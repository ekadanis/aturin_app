// calendar_section_widget.dart

import 'dart:ui';
import 'package:aturin_app/core/widgets/calendar_header_widget.dart';
import 'package:aturin_app/core/widgets/interactive_calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/features/jadwal/model/aktivitas_model.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import 'package:sizer/sizer.dart';

class CalendarSectionWidget extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat calendarFormat;
  final List<AktivitasModel> schedules;
  final List<Task> tasks;
  final Function(DateTime, DateTime) onDateSelected;
  final Function(DateTime) onPageChanged;
  final Function(CalendarFormat) onFormatChanged;
  final DateTime? firstAllowedDate;

  const CalendarSectionWidget({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.calendarFormat,
    required this.schedules,
    this.tasks = const [],
    required this.onDateSelected,
    required this.onPageChanged,
    required this.onFormatChanged,
    this.firstAllowedDate,
  });

  @override
  State<CalendarSectionWidget> createState() => _CalendarSectionWidgetState();
}

class _CalendarSectionWidgetState extends State<CalendarSectionWidget>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  final double _minHeight = 12.5.h;
  final double _maxHeight = 37.7.h;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Set initial animation state based on calendar format
    if (widget.calendarFormat == CalendarFormat.month) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- ADD THIS METHOD for real-time dragging ---
  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final animationRange = _maxHeight - _minHeight;
    // Update the animation controller's value based on the drag delta.
    // The controller's value is automatically clamped between 0.0 and 1.0.
    _animationController.value += details.primaryDelta! / animationRange;

    // --- Trigger perubahan format saat gesture berjalan ---
    // if (details.primaryDelta! > 0 &&
    //     widget.calendarFormat != CalendarFormat.month) {
    //   // sedang geser ke bawah → ubah ke bulan
    //   widget.onFormatChanged(CalendarFormat.month);
    // }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // If the animation is more than halfway complete, snap it open.
    if (_animationController.value >= 0.4) {
      _animationController.forward().then((_) {
        widget.onFormatChanged(CalendarFormat.month);
      });
    }
    // Otherwise, snap it closed.
    else {
      _animationController.reverse().then((_) {
        widget.onFormatChanged(CalendarFormat.week);
      });
    }
  }

  // void _onVerticalDragEnd(DragEndDetails details) {
  //   const openThreshold = 0.4; // lebih rendah, biar buka lebih mudah
  //   const closeThreshold = 0.6; // lebih rendah juga, biar konsisten

  //   if (_animationController.value >= closeThreshold) {
  //     // buka full month
  //     widget.onFormatChanged(CalendarFormat.month);
  //     _animationController.forward();
  //   } else if (_animationController.value <= openThreshold) {
  //     // tutup full week
  //     widget.onFormatChanged(CalendarFormat.week);
  //     _animationController.reverse();
  //   } else {
  //     // pakai arah swipe untuk memutuskan
  //     if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
  //       widget.onFormatChanged(CalendarFormat.month);
  //       _animationController.forward();
  //     } else {
  //       widget.onFormatChanged(CalendarFormat.week);
  //       _animationController.reverse();
  //     }
  //   }
  // }

  void _switchCalendarFormat() {
    if (widget.calendarFormat == CalendarFormat.week) {
      widget.onFormatChanged(CalendarFormat.month);
      _animationController.forward();
    } else {
      widget.onFormatChanged(CalendarFormat.week);
      _animationController.reverse();
    }
  }

  // This method handles the logic for both back and forward navigation
  void _navigate(bool isForward) {
    DateTime newFocusedDate;
    if (widget.calendarFormat == CalendarFormat.month) {
      newFocusedDate = DateTime(
        widget.focusedDate.year,
        widget.focusedDate.month + (isForward ? 1 : -1),
        1, // Go to the first of the month to avoid day-out-of-range errors
      );
    } else {
      // Week view
      newFocusedDate = widget.focusedDate.add(
        Duration(days: isForward ? 7 : -7),
      );
    }
    // Call the parent widget's onPageChanged callback
    widget.onPageChanged(newFocusedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalendarHeaderWidget(
            focusedDate: widget.focusedDate,
            calendarFormat: widget.calendarFormat,
            onNavigate: _navigate,
          ),
          const SizedBox(height: 16),

          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final height =
                  lerpDouble(
                    _minHeight,
                    _maxHeight,
                    _animationController.value,
                  )!;
              return SizedBox(height: height, child: child);
            },
            child: GestureDetector(
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              behavior: HitTestBehavior.opaque,
              // --- THE CRUCIAL FIX: Add ClipRect here ---
              // This prevents the calendar from painting outside its bounds
              // during the animation, solving the visual overflow.
              onTap: _switchCalendarFormat,
              child: Column(
                children: [
                  Expanded(
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        minHeight: _minHeight,
                        maxHeight: _maxHeight,
                        child: InteractiveCalendarWidget(
                          selectedDate: widget.selectedDate,
                          focusedDate: widget.focusedDate,
                          calendarFormat: widget.calendarFormat,
                          schedules: widget.schedules,
                          tasks: widget.tasks,
                          onDateSelected: widget.onDateSelected,
                          onPageChanged: widget.onPageChanged,
                          onFormatChanged: widget.onFormatChanged,
                          firstAllowedDate: widget.firstAllowedDate,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.calendarFormat == CalendarFormat.week
                        ? "Geser ke bawah untuk tampilan bulan"
                        : "Geser ke atas untuk tampilan minggu",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
