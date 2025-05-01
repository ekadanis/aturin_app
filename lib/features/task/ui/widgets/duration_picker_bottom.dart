import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'bottom_sheet_container.dart';

Future<Duration?> showDurationPickerBottomSheet(BuildContext context) async {
  int selectedHour = 0;
  int selectedMinute = 30;
  Duration? result;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return BottomSheetContainer(
            title: 'Estimasi Waktu Pengerjaan',
            subtitle: '$selectedHour Jam $selectedMinute Menit',
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NumberPicker(
                  minValue: 0,
                  maxValue: 23,
                  value: selectedHour,
                  zeroPad: true,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  selectedTextStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  onChanged: (value) => setState(() => selectedHour = value),
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
                NumberPicker(
                  minValue: 0,
                  maxValue: 59,
                  value: selectedMinute,
                  zeroPad: true,
                  textStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  selectedTextStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                  onChanged: (value) => setState(() => selectedMinute = value),
                ),
              ],
            ),
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              result = Duration(
                hours: selectedHour,
                minutes: selectedMinute,
              );
              Navigator.pop(context, result);
            },
          );
        },
      );
    },
  );

  return result;
}
