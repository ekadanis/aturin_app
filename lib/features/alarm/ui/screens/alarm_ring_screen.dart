// lib/screens/alarm_ring_screen.dart
import 'package:flutter/material.dart';

import '../widgets/alarm_time_display.dart';
import '../widgets/alarm_clock_image.dart';
import '../widgets/task_description.dart';
import '../widgets/category_tag.dart';
import '../widgets/cancel_slider.dart';

class AlarmRingScreen extends StatelessWidget {
  final String time;
  final String date;
  final String taskName;
  final String category;

  const AlarmRingScreen({
    Key? key,
    required this.time,
    required this.date,
    required this.taskName,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFEAFF), // Light blue background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
  
              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 85),
                    AlarmTimeDisplay(
                      time: time,
                      date: date,
                    ),
                    const SizedBox(height: 10),
                    const AlarmClockImage(),
                    const SizedBox(height: 10),
                    TaskDescription(taskName: taskName),
                    const SizedBox(height: 16),
                    CategoryTag(category: category),
                    const SizedBox(height: 72),
                    // Cancel alarm slider
                    const CancelSlider(
                      text: "Matikan Alarm",
                      description: "Geser ke kanan untuk mematikan alarm",
                    ),
                    const SizedBox(height: 20), // Reduced bottom padding
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}