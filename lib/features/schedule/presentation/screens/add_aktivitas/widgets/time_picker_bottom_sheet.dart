import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/shared/widgets/bottom_sheet_container.dart';

class _TimePickerContent extends StatefulWidget {
  final TimeOfDay initialTime;
  final bool isToday;
  final Function(TimeOfDay) onTimeChanged;

  const _TimePickerContent({
    required this.initialTime,
    required this.isToday,
    required this.onTimeChanged,
  });

  @override
  __TimePickerContentState createState() => __TimePickerContentState();
}

class __TimePickerContentState extends State<_TimePickerContent> {
  late int selectedHour;
  late int selectedMinute;
  late DateTime now;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
    now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    // Define the valid range for the pickers
    final int minHourForPicker = widget.isToday ? now.hour : 0;
    final int minMinuteForPicker =
        (widget.isToday && selectedHour == now.hour) ? now.minute : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour Picker
        NumberPicker(
          minValue: minHourForPicker,
          maxValue: 23,
          value: selectedHour.clamp(minHourForPicker, 23),
          zeroPad: true,
          onChanged: (value) {
            setState(() {
              selectedHour = value;
              // If the new hour makes the current minute invalid, adjust it.
              if (widget.isToday &&
                  selectedHour == now.hour &&
                  selectedMinute < now.minute) {
                selectedMinute = now.minute;
              }
              // Notify the parent about the change
              widget.onTimeChanged(
                TimeOfDay(hour: selectedHour, minute: selectedMinute),
              );
            });
          },
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Colors.grey,
          ),
          selectedTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            ":",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        // Minute Picker
        NumberPicker(
          minValue: minMinuteForPicker,
          maxValue: 59,
          value: selectedMinute.clamp(minMinuteForPicker, 59),
          zeroPad: true,
          onChanged: (value) {
            setState(() {
              selectedMinute = value;
              // Notify the parent about the change
              widget.onTimeChanged(
                TimeOfDay(hour: selectedHour, minute: selectedMinute),
              );
            });
          },
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            color: Colors.grey,
          ),
          selectedTextStyle: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

// The main function is now simpler.
Future<TimeOfDay?> showTimePickerBottomSheet(
  BuildContext context, {
  TimeOfDay? initialTime,
  String? title,
  DateTime? selectedDate,
}) async {
  final now = DateTime.now();
  final isToday =
      selectedDate != null &&
      selectedDate.year == now.year &&
      selectedDate.month == now.month &&
      selectedDate.day == now.day;

  final minTimeForToday = TimeOfDay(hour: now.hour, minute: now.minute);
  TimeOfDay initialPickerTime =
      initialTime ??
      (isToday ? minTimeForToday : const TimeOfDay(hour: 0, minute: 0));

  if (isToday) {
    final initialMinutes =
        initialPickerTime.hour * 60 + initialPickerTime.minute;
    final minMinutes = minTimeForToday.hour * 60 + minTimeForToday.minute;
    if (initialMinutes < minMinutes) {
      initialPickerTime = minTimeForToday;
    }
  }

  // Use a ValueNotifier to update the subtitle without rebuilding the whole sheet.
  final ValueNotifier<TimeOfDay> selectedTimeNotifier = ValueNotifier(
    initialPickerTime,
  );

  return await showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      return ValueListenableBuilder<TimeOfDay>(
        valueListenable: selectedTimeNotifier,
        builder: (context, currentTime, child) {
          final formattedTime =
              '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}';

          return BottomSheetContainer(
            title: title ?? 'Pilih Waktu',
            subtitle: formattedTime, // Subtitle now updates efficiently
            content: _TimePickerContent(
              initialTime: initialPickerTime,
              isToday: isToday,
              onTimeChanged: (newTime) {
                // When the picker content changes, it updates the notifier.
                selectedTimeNotifier.value = newTime;
              },
            ),
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              // The final value is the one in the notifier.
              Navigator.pop(context, selectedTimeNotifier.value);
            },
            isConfirmEnabled: true,
          );
        },
      );
    },
  );
}
