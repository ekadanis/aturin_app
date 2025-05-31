import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';
import 'package:aturin_app/features/task/model/task_model.dart';
import '../widgets/alarm_clock_image.dart';
import '../widgets/alarm_time_display.dart';
import '../widgets/task_description.dart';
import '../widgets/category_tag.dart';
import '../widgets/cancel_slider_button.dart';
import 'package:auto_route/auto_route.dart';
import '../../services/alarm_service.dart';
import 'package:aturin_app/core/services/api/task/task_service.dart';

@RoutePage()
class AlarmRingingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  final VoidCallback? onDismiss;

  const AlarmRingingScreen({
    Key? key,
    required this.alarmSettings,
    this.onDismiss,
  }) : super(key: key);

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  Task? _task;
  final timeFormat = DateFormat('HH:mm');
  final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
  final AlarmService _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    try {
      final taskService = TaskService();
      // Fetch all tasks and find the one with alarmId matching the alarmSettings.id
      final allTasks = await taskService.getAllTasks();
      final task = allTasks.where((t) => t.alarmId == widget.alarmSettings.id).cast<Task?>().firstWhere((_) => true, orElse: () => null);
      if (mounted) {
        setState(() {
          _task = task;
        });
      }
    } catch (e) {
      debugPrint('Error loading task: $e');
    }
  }

  void _stopAlarm() {
    try {
      debugPrint(
        'Mencoba menghentikan alarm dengan ID: ${widget.alarmSettings.id}',
      );
      Alarm.stop(widget.alarmSettings.id);

      if (widget.onDismiss != null) {
        debugPrint(
          'Menggunakan onDismiss callback untuk kembali ke aplikasi utama',
        );
        widget.onDismiss!();
      } else {
        debugPrint('Kembali dengan Navigator.pop');
        context.router.pop();
      }
    } catch (e) {
      debugPrint('Error stopping alarm: $e');
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      } else if (mounted) {
        context.router.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time =
        _task?.alarmDateTime != null
            ? timeFormat.format(_task!.alarmDateTime!)
            : timeFormat.format(now);
    final date =
        _task?.alarmDateTime != null
            ? dateFormat.format(_task!.alarmDateTime!)
            : dateFormat.format(now);

    final taskName = _task?.title.isNotEmpty == true 
        ? _task!.title 
        : 'Waktunya mengerjakan tugas!';

    final category = _alarmService.getCategoryName(_task?.category ?? 'akademik');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        _stopAlarm();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFDFEAFF),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableHeight = constraints.maxHeight;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Top section - Clock time and date
                    SizedBox(height: screenHeight * 0.02), // Setara dengan 2.h
                    AlarmTimeDisplay(time: time, date: date),
                    
                    // Middle section - Animation
                    Container(
                      height: availableHeight * 0.3, // Responsive height
                      child: const AlarmClockImage(),
                    ),
                    
                    // Bottom section - Task info
                    Column(
                      children: [
                        TaskDescription(taskName: taskName),
                        SizedBox(height: screenHeight * 0.01), // Setara dengan 1.h
                        CategoryTag(category: category),
                      ],
                    ),
                    
                    // Cancel button section - Always visible and properly positioned
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: screenHeight * 0.03, // Setara dengan 3.h
                        top: screenHeight * 0.02, // Setara dengan 2.h
                      ),
                      child: CancelSliderButton(
                        text: "Matikan Alarm",
                        description: "Geser ke kanan untuk mematikan alarm",
                        onCancelled: _stopAlarm,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}