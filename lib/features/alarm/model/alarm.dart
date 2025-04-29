// lib/models/alarm.dart
class Alarm {
  final String time;
  final String date;
  final String taskName;
  final String category;
  final bool isActive;

  Alarm({
    required this.time,
    required this.date,
    required this.taskName,
    required this.category,
    this.isActive = true,
  });
}