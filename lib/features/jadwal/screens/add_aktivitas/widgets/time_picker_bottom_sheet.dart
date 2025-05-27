import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'bottom_sheet_container.dart';

Future<TimeOfDay?> showTimePickerBottomSheet(
  BuildContext context, {
  TimeOfDay? initialTime,
  String? title,
  DateTime? selectedDate,
}) async {
  final now = DateTime.now();
  final currentTime = TimeOfDay.now();
  final isToday = selectedDate != null && 
                  selectedDate.year == now.year &&
                  selectedDate.month == now.month &&
                  selectedDate.day == now.day;

  // Hitung waktu minimum (waktu sekarang + 1 menit)
  TimeOfDay minimumTime = isToday 
    ? TimeOfDay(
        hour: currentTime.hour,
        minute: currentTime.minute + 1 > 59 
          ? 0 
          : currentTime.minute + 1,
      )
    : const TimeOfDay(hour: 0, minute: 0);

  // Adjust hour jika minute overflow
  if (isToday && currentTime.minute + 1 > 59) {
    minimumTime = TimeOfDay(
      hour: currentTime.hour + 1 > 23 ? 0 : currentTime.hour + 1,
      minute: 0,
    );
  }

  // Set initial values ke minimum time yang valid
  int selectedHour = isToday ? minimumTime.hour : (initialTime?.hour ?? 0);
  int selectedMinute = isToday ? minimumTime.minute : (initialTime?.minute ?? 0);
  
  // Validasi initial time jika ada
  if (isToday && initialTime != null) {
    final initialMinutes = initialTime.hour * 60 + initialTime.minute;
    final minimumMinutes = minimumTime.hour * 60 + minimumTime.minute;
    
    if (initialMinutes < minimumMinutes) {
      selectedHour = minimumTime.hour;
      selectedMinute = minimumTime.minute;
    }
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
          // Hitung range yang valid untuk jam
          final minHour = isToday ? minimumTime.hour : 0;
          final maxHour = 23;
          
          // Hitung range yang valid untuk menit berdasarkan jam yang dipilih
          int minMinute = 0;
          if (isToday && selectedHour == minimumTime.hour) {
            minMinute = minimumTime.minute;
          }
          
          // Format waktu untuk ditampilkan
          String formattedTime = '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}';
          
          return BottomSheetContainer(
            title: title ?? 'Pilih Waktu',
            subtitle: formattedTime,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Info waktu mulai jika hari ini
                if (isToday)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.blue[600],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Waktu mulai dari: ${minimumTime.format(context)}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
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
                          maxValue: maxHour,
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
                            selectedHour = value;
                            
                            // Auto-adjust menit ketika jam berubah
                            if (isToday && selectedHour == minimumTime.hour) {
                              // Jika jam sama dengan jam minimum, menit harus >= menit minimum
                              if (selectedMinute < minimumTime.minute) {
                                selectedMinute = minimumTime.minute;
                              }
                            } else if (isToday && selectedHour > minimumTime.hour) {
                              // Jika jam lebih besar dari jam minimum, menit bisa mulai dari 0
                              selectedMinute = 0;
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
                          minValue: minMinute,
                          maxValue: 59,
                          value: selectedMinute < minMinute ? minMinute : selectedMinute,
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
              result = TimeOfDay(
                hour: selectedHour,
                minute: selectedMinute,
              );
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