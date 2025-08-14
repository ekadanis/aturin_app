import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_sheet_container.dart';

class _TimePickerContent extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  const _TimePickerContent({
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  __TimePickerContentState createState() => __TimePickerContentState();
}

class __TimePickerContentState extends State<_TimePickerContent> {
  late int selectedHour;
  late int selectedMinute;

  @override
  void initState() {
    super.initState();
    selectedHour = widget.initialTime.hour;
    selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hour Picker
        NumberPicker(
          minValue: 00,
          maxValue: 23,
          value: selectedHour.clamp(00, 23),
          zeroPad: true,
          onChanged: (value) {
            setState(() {
              selectedHour = value;
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
          minValue: 00,
          maxValue: 59,
          value: selectedMinute.clamp(00, 59),
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
}) async {
  // Waktu awal selalu 00:00
  TimeOfDay initialPickerTime = initialTime ?? const TimeOfDay(hour: 0, minute: 0);

  // Gunakan ValueNotifier agar subtitle bisa berubah tanpa rebuild seluruh sheet
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
            subtitle: formattedTime,
            content: _TimePickerContent(
              initialTime: initialPickerTime,
              onTimeChanged: (newTime) {
                selectedTimeNotifier.value = newTime;
              },
            ),
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              Navigator.pop(context, selectedTimeNotifier.value);
            },
            isConfirmEnabled: true,
          );
        },
      );
    },
  );
}
