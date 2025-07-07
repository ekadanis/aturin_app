import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import '../../../../../core/widgets/bottom_sheet_container.dart';

Future<TimeOfDay?> showTimePickerBottomSheet(
  BuildContext context, {
  TimeOfDay? initialTime,
  String? title,
  DateTime? selectedDate ,
}) async {
  final now = DateTime.now();
  selectedDate = DateTime(now.year, now.month, now.day);
  final currentTime = TimeOfDay.now();
  final isToday =
      selectedDate.year == now.year &&
      selectedDate.month == now.month &&
      selectedDate.day == now.day;

  // Hitung range yang valid untuk jam
  int minHour = isToday ? now.hour : 0;

  // Hitung range yang valid untuk menit berdasarkan jam yang dipilih
  int minMinute = isToday ? (now.minute + 1) : 0;

  // Tangani overflow menit
  if (minMinute > 59) {
    minMinute = 0;
    minHour += 1;
    if (minHour > 23) {
      minHour = 23;
      minMinute = 59;
    }
  }

  // Set initial values ke minimum time yang valid
  int selectedHour = initialTime?.hour ?? minHour;
  int selectedMinute = initialTime?.minute ?? minMinute;

  // Auto-adjust if value < min
  if (selectedHour < minHour) selectedHour = minHour;
  if (selectedMinute < minMinute) selectedMinute = minMinute;

  // Validasi jika waktu awal lebih kecil dari waktu minimum
  if (isToday) {
    final initialTotal = selectedHour * 60 + selectedMinute;
    final minTotal = minHour * 60 + minMinute;

    if (initialTotal < minTotal) {
      selectedHour = minHour;
      selectedMinute = minMinute;
    }
  }

  // Hitung waktu minimum (waktu sekarang + 1 menit)
  TimeOfDay minimumTime =
      isToday
          ? TimeOfDay(
            hour: currentTime.hour,
            minute: currentTime.minute + 1 > 59 ? 0 : currentTime.minute + 1,
          )
          : const TimeOfDay(hour: 0, minute: 0);

  // Adjust hour jika minute overflow
  if (isToday && currentTime.minute + 1 > 59) {
    minimumTime = TimeOfDay(
      hour: currentTime.hour + 1 > 23 ? 0 : currentTime.hour + 1,
      minute: 0,
    );
  }

  TimeOfDay? result;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Format waktu untuk ditampilkan
          String formattedTime =
              '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';

          final effectiveMinMinute =
              (isToday && selectedHour == minHour) ? minMinute : 0;

          return BottomSheetContainer(
            title: title ?? 'Pilih Waktu',
            subtitle: formattedTime,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info waktu mulai jika hari ini
                // if (isToday)
                //   Container(
                //     margin: const EdgeInsets.only(bottom: 16),
                //     padding: const EdgeInsets.all(12),
                //     decoration: BoxDecoration(
                //       color: Colors.blue[50],
                //       borderRadius: BorderRadius.circular(8),
                //       border: Border.all(color: Colors.blue[200]!),
                //     ),
                //     // child: Row(
                //     //   children: [
                //     //     Icon(
                //     //       Icons.access_time,
                //     //       color: Colors.blue[600],
                //     //       size: 20,
                //     //     ),
                //     //     const SizedBox(width: 8),
                //     //     Expanded(
                //     //       child: Text(
                //     //         'Waktu mulai dari: ${minimumTime.format(context)}',
                //     //         style: GoogleFonts.plusJakartaSans(
                //     //           fontSize: 12,
                //     //           color: Colors.blue[600],
                //     //         ),
                //     //       ),
                //     //     ),
                //     //   ],
                //     // ),
                //   ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hour Picker - hanya tampilkan jam yang valid
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
                          minValue: minHour,
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
                          onChanged:
                              (value) => setState(() {
                                selectedHour = value;

                                // Reset menit jika jam berubah
                                if (isToday) {
                                  if (selectedHour == minHour &&
                                      selectedMinute < minMinute) {
                                    selectedMinute = minMinute;
                                  } else if (selectedHour > minHour) {
                                    selectedMinute = 0;
                                  }
                                }
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

                    // Minute Picker - hanya tampilkan menit yang valid
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
                          minValue: effectiveMinMinute,
                          maxValue: 59,
                          value: selectedMinute < effectiveMinMinute ? effectiveMinMinute : selectedMinute,
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
                          onChanged:
                              (value) => setState(() {
                                selectedMinute = value;
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              result = TimeOfDay(hour: selectedHour, minute: selectedMinute);
              Navigator.pop(context, result);
            },
            isConfirmEnabled: true,
          );
        },
      );
    },
  );

  return result;
}
