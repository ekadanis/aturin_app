import 'package:flutter/material.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/form_field_widgets.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/time_picker_bottom_sheet.dart';

class TimeSelectionSection extends StatelessWidget {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final DateTime selectedDate;
  final String? startTimeError;
  final String? endTimeError;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;

  const TimeSelectionSection({
    super.key,
    required this.startTime,
    required this.endTime,
    required this.selectedDate,
    required this.startTimeError,
    required this.endTimeError,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  Future<void> _selectStartTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    final time = await showTimePickerBottomSheet(
      context,
      initialTime: startTime ?? now,
      title: 'Pilih Waktu Mulai',
    );

    if (time != null) {
      if (isToday) {
        // Konversi TimeOfDay ke DateTime agar bisa dibandingkan
        final selectedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          time.hour,
          time.minute,
        );
        final nowDateTime = DateTime.now();

        if (selectedDateTime.isBefore(nowDateTime)) {
          // Tampilkan pesan atau tolak pemilihan waktu
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Waktu mulai tidak boleh kurang dari waktu sekarang.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      onStartTimeChanged(time);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    // final now = TimeOfDay.now();
    final today = DateTime.now();
    final isToday =
        selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    final time = await showTimePickerBottomSheet(
      context,
      initialTime: endTime ?? const TimeOfDay(hour: 23, minute: 59),
      title: 'Pilih Waktu Selesai',
    );

    if (time != null) {
      // Konversi TimeOfDay ke DateTime
      final selectedEndDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time.hour,
        time.minute,
      );

      if (isToday && selectedEndDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu selesai tidak boleh di masa lalu.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (startTime != null) {
        final selectedStartDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          startTime!.hour,
          startTime!.minute,
        );

        if (selectedEndDateTime.isBefore(selectedStartDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Waktu selesai harus setelah waktu mulai.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      onEndTimeChanged(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TimeField(
            title: 'Waktu mulai',
            value: startTime?.format(context) ?? 'Pilih waktu',
            onTap: () => _selectStartTime(context),
            error: startTimeError,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TimeField(
            title: 'Waktu selesai',
            value: endTime?.format(context) ?? 'Pilih waktu',
            onTap: () => _selectEndTime(context),
            error: endTimeError,
          ),
        ),
      ],
    );
  }
}
