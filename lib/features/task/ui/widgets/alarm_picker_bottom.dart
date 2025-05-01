import '../../../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottom_sheet_container.dart';

Future<DateTime?> showAlarmPickerBottomSheet(
  BuildContext context, {
  DateTime? initialDateTime,
  required DateTime maxDateTime,
}) async {
  DateTime now = DateTime.now();
  DateTime initialDate = initialDateTime ?? now;
  DateTime selectedDate = DateTime(
    initialDate.year,
    initialDate.month,
    initialDate.day,
  );
  int selectedHour = initialDate.hour;
  int selectedMinute = initialDate.minute;
  DateTime? finalDate;

  // Batas maksimal adalah 1 jam sebelum deadline
  final safeMaxDateTime = maxDateTime.subtract(const Duration(hours: 1));

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final maxDaysFromNow = safeMaxDateTime.difference(now).inDays;

          // Validasi Jam
          List<int> getValidHours() {
            List<int> hours = [];
            for (int i = 0; i <= 23; i++) {
              final date = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                i,
              );
              if (date.isBefore(safeMaxDateTime)) {
                hours.add(i);
              }
            }
            return hours;
          }

          // Validasi Menit
          List<int> getValidMinutes() {
            List<int> minutes = [];
            for (int i = 0; i <= 59; i++) {
              final date = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedHour,
                i,
              );
              if (date.isBefore(safeMaxDateTime)) {
                minutes.add(i);
              }
            }
            return minutes;
          }

          final validHours = getValidHours();
          final validMinutes = getValidMinutes();

          if (validHours.isEmpty) {
            selectedHour = 0;
          }
          else if (!validHours.contains(selectedHour)) {
            selectedHour = validHours.last;
          }

          if (validMinutes.isEmpty) {
            selectedMinute = 0;
          }
          else if (!validMinutes.contains(selectedMinute)) {
            selectedMinute = validMinutes.last;
          }

          // Format date time untuk subtitle
          final formattedDateTime = DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(
            DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedHour,
              selectedMinute,
            ),
          );

          // Informasi catatan deadline
          final deadlineNote = '*Alarm  maksimal 1 jam sebelum ${DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(maxDateTime)}';

          return BottomSheetContainer(
            title: 'Atur Alarm',
            subtitle: formattedDateTime,
            content: Column(
              children: [
                // Catatan deadline
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    deadlineNote,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                
                // Date and time picker
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 12),
                    
                    Expanded(
    
                      child: SizedBox(
                        height: 150,
                        child: ListWheelScrollView.useDelegate(
                          controller: FixedExtentScrollController(
                            initialItem: 0,
                          ),
                          itemExtent: 40,
                          diameterRatio: 5,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedDate = now.add(Duration(days: index));
                              selectedHour = getValidHours().last;
                              selectedMinute = getValidMinutes().last;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: maxDaysFromNow + 1,
                            builder: (context, index) {
                              final date = now.add(Duration(days: index));
                              return Center(
                                child: Text(
                                  DateFormat('EEEE, d MMM', 'id_ID').format(date),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    color: selectedDate.difference(date).inDays == 0
                                            ? AppTheme.primaryColor
                                            : Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),

                    // Time Picker
                    Column(
                      children: [
                        Row(
                          children: [
                            // Hour picker
                            NumberPicker(
                              minValue: validHours.isEmpty ? 0 : validHours.first,
                              maxValue: validHours.isEmpty ? 0 : validHours.last,
                              value: selectedHour,
                              zeroPad: true,
                              itemWidth: 50,
                              itemHeight: 50,
                              textStyle: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                              ),
                              selectedTextStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryColor,
                              ),
                              onChanged: (value) => setState(() {
                                selectedHour = value;
                                selectedMinute = getValidMinutes().last;
                              }),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Minute picker
                            NumberPicker(
                              minValue: validMinutes.isEmpty ? 0 : validMinutes.first,
                              maxValue: validMinutes.isEmpty ? 0 : validMinutes.last,
                              value: selectedMinute,
                              zeroPad: true,
                              itemWidth: 50,
                              itemHeight: 50,
                              textStyle: GoogleFonts.plusJakartaSans(
                                color: Colors.grey,
                              ),
                              selectedTextStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
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
              ],
            ),
            onCancel: () => Navigator.pop(context),
            onConfirm: validHours.isEmpty ? null : () {
              finalDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedHour,
                selectedMinute,
              );
              Navigator.pop(context, finalDate);
            },
            isConfirmEnabled: validHours.isNotEmpty,
          );
        },
      );
    },
  );

  return finalDate;
}
