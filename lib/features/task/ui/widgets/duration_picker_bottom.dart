import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/theme/app_theme.dart';
import 'bottom_sheet_container.dart';

Future<Duration?> showDurationPickerBottomSheet(BuildContext context) async {
  // Inisialisasi dengan nilai yang valid, memastikan dalam batas min dan max
  int selectedHour = 0; // between 0 and 23
  int selectedMinute = 30; // between 0 and 59
  Duration? result;
  bool isValid = true; // Durasi awal valid

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Selalu lakukan sanitasi nilai saat widget dibuild
          selectedHour = selectedHour.clamp(0, 23);
          selectedMinute = selectedMinute.clamp(0, 59);
          
          // Validasi: minimal durasi 5 menit
          isValid = selectedHour > 0 || selectedMinute >= 5;
          
          return BottomSheetContainer(
            title: 'Estimasi Waktu Pengerjaan',
            subtitle: '$selectedHour Jam $selectedMinute Menit',
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Jam Picker
                    Column(
                      children: [
                        Text(
                          'Jam',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
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
                          onChanged: (value) => setState(() {
                            selectedHour = value.clamp(0, 23);
                          }),
                        ),
                      ],
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
                    
                    // Menit Picker
                    Column(
                      children: [
                        Text(
                          'Menit',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        NumberPicker(
                          minValue: 0,
                          maxValue: 59,
                          value: selectedMinute,
                          zeroPad: true,
                          step: 1,
                          textStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          selectedTextStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                          onChanged: (value) => setState(() {
                            selectedMinute = value.clamp(0, 59);
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Pesan validasi jika durasi kurang dari 5 menit
                if (!isValid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Durasi minimal harus 5 menit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            onCancel: () => Navigator.pop(context),
            onConfirm: isValid ? () {
              result = Duration(
                hours: selectedHour,
                minutes: selectedMinute,
              );
              Navigator.pop(context, result);
            } : null,
            isConfirmEnabled: isValid,
          );
        },
      );
    },
  );

  return result;
}
