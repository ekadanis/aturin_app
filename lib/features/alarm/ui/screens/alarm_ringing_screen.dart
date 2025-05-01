import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alarm/alarm.dart';
import 'package:intl/intl.dart';
import 'package:aturin_app/features/task/services/task_services.dart';
import 'package:aturin_app/features/task/models/task.dart';
import '../widgets/alarm_clock_image.dart';
import '../widgets/alarm_time_display.dart';
import '../widgets/task_description.dart';
import '../widgets/category_tag.dart';
import '../widgets/cancel_slider.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class AlarmRingingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;
  // Callback untuk memanggil saat alarm dimatikan dari standalone mode
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
  bool _loading = true;
  bool _error = false;
  final timeFormat = DateFormat('HH:mm');
  final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _loadTask();
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
          _error = task == null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = true;
          _loading = false;
        });
        debugPrint('Error loading task: $e');
      }
    }
  }

  void _stopAlarm() {
    try {
      debugPrint(
        'Mencoba menghentikan alarm dengan ID: ${widget.alarmSettings.id}',
      );
      Alarm.stop(widget.alarmSettings.id);

      // Jika onDismiss tersedia (mode standalone), gunakan itu untuk kembali ke aplikasi
      if (widget.onDismiss != null) {
        debugPrint(
          'Menggunakan onDismiss callback untuk kembali ke aplikasi utama',
        );
        widget.onDismiss!();
      } else {
        // Jika tidak, berarti kita berada dalam aplikasi utama, cukup pop screen
        debugPrint('Kembali dengan Navigator.pop');
        context.router.pop();
      }
    } catch (e) {
      debugPrint('Error stopping alarm: $e');
      // Fallback jika terjadi error
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
    final taskName = _task?.title ?? 'Waktunya mengerjakan tugas!';
    final category = _getCategoryName(_task?.category ?? 'akademik');

    return WillPopScope(
      // Pastikan alarm dihentikan jika user menavigasi kembali
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
                      AlarmTimeDisplay(time: time, date: date),
                      const SizedBox(height: 10),
                      const AlarmClockImage(),
                      const SizedBox(height: 10),
                      TaskDescription(taskName: taskName),
                      const SizedBox(height: 16),
                      CategoryTag(category: category),
                      const SizedBox(height: 72),
                      // Cancel alarm slider dengan callback
                      CancelSlider(
                        text: "Matikan Alarm",
                        description: "Geser ke kanan untuk mematikan alarm",
                        onCancelled: _stopAlarm,
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
