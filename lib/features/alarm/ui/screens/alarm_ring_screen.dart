// lib/screens/alarm_ring_screen.dart
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/task/models/task.dart';

import '../widgets/alarm_time_display.dart';
import '../widgets/alarm_clock_image.dart';
import '../widgets/task_description.dart';
import '../widgets/category_tag.dart';
import '../widgets/cancel_slider.dart';

class AlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const AlarmRingScreen({
    Key? key,
    required this.alarmSettings,
  }) : super(key: key);

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  Task? _task;
  bool _loading = true;
  final timeFormat = DateFormat('HH:mm');
  final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _loadTask();
    
    // Debug untuk membantu troubleshooting
    debugPrint('[AlarmRingScreen] Alarm triggered: ID=${widget.alarmSettings.id}');
    debugPrint('[AlarmRingScreen] Audio path: ${widget.alarmSettings.assetAudioPath}');
    debugPrint('[AlarmRingScreen] DateTime: ${widget.alarmSettings.dateTime}');
  }

  Future<void> _loadTask() async {
    try {
      setState(() => _loading = true);
      
      final taskService = Provider.of<TaskService>(context, listen: false);
      final task = await taskService.getTaskById(widget.alarmSettings.id);
      
      if (mounted) {
        setState(() {
          _task = task;
          _loading = false;
        });
        
        debugPrint('[AlarmRingScreen] Loaded task: ${task?.title}');
      }
    } catch (e) {
      debugPrint('[AlarmRingScreen] Error loading task: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _stopAlarm() {
    try {
      debugPrint('[AlarmRingScreen] Stopping alarm ID: ${widget.alarmSettings.id}');
      Alarm.stop(widget.alarmSettings.id);
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('[AlarmRingScreen] Error stopping alarm: $e');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time = widget.alarmSettings.dateTime != null 
        ? timeFormat.format(widget.alarmSettings.dateTime)
        : timeFormat.format(now);
    final date = widget.alarmSettings.dateTime != null
        ? dateFormat.format(widget.alarmSettings.dateTime)
        : dateFormat.format(now);
    
    final taskName = _task?.title ?? 'Waktunya mengerjakan tugas!';
    final category = _getCategoryName(_task?.category ?? 'akademik');

    return WillPopScope(
      onWillPop: () async {
        _stopAlarm();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFDFEAFF),
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
                      CancelSlider(
                        text: "Matikan Alarm",
                        description: "Geser ke kanan untuk mematikan alarm",
                        onCancelled: _stopAlarm,
                      ),
                      
                      // Tambahkan tombol alternatif untuk mematikan alarm
                      TextButton(
                        onPressed: _stopAlarm,
                        child: const Text(
                          "Ketuk disini untuk mematikan",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getCategoryName(String category) {
    try {
      final taskCategory = TaskCategory.values.firstWhere(
        (e) => e.toString() == 'TaskCategory.$category',
        orElse: () => TaskCategory.akademik,
      );
      
      switch (taskCategory) {
        case TaskCategory.akademik:
          return 'Akademik';
        case TaskCategory.hiburan:
          return 'Hiburan';
        case TaskCategory.pekerjaan:
          return 'Pekerjaan';
        case TaskCategory.olahraga:
          return 'Olahraga';
        case TaskCategory.sosial:
          return 'Sosial';
        case TaskCategory.spiritual:
          return 'Spiritual';
        case TaskCategory.pribadi:
          return 'Pribadi';
        case TaskCategory.istirahat:
          return 'Istirahat';
      }
    } catch (_) {
      return category;
    }
  }
}