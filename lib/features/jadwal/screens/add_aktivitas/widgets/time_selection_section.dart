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
    final time = await showTimePickerBottomSheet(
      context,
      initialTime: startTime,
      title: 'Pilih Waktu Mulai',
    );

    if (time != null) {
      onStartTimeChanged(time);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final time = await showTimePickerBottomSheet(
      context,
      initialTime: endTime,
      title: 'Pilih Waktu Selesai',
    );

    if (time != null) {
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
