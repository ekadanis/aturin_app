import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';

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

          // Auto adjust kalau hour/minute gak valid
          if (!validHours.contains(selectedHour)) {
            selectedHour = validHours.isNotEmpty ? validHours.last : 0;
          }
          if (!validMinutes.contains(selectedMinute)) {
            selectedMinute = validMinutes.isNotEmpty ? validMinutes.last : 0;
          }

          return SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Atur Alarm',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(
                      DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedHour,
                        selectedMinute,
                      ),
                    ),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '*Alarm harus maksimal 1 jam sebelum ${DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(maxDateTime)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date List (Optional untuk banyak hari)
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
                                    DateFormat(
                                      'EEEE, d MMM',
                                      'id_ID',
                                    ).format(date),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      color:
                                          selectedDate
                                                      .difference(date)
                                                      .inDays ==
                                                  0
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

                      // Time Picker (Hour + Minute)
                      Column(
                        children: [
                          Row(
                            children: [
                              // Jam
                              NumberPicker(
                                minValue:
                                    validHours.isEmpty ? 0 : validHours.first,
                                maxValue:
                                    validHours.isEmpty ? 0 : validHours.last,
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
                                onChanged:
                                    (value) => setState(() {
                                      selectedHour = value;
                                      selectedMinute = getValidMinutes().last;
                                    }),
                              ),
                              const SizedBox(width: 8),
                              // Menit
                              NumberPicker(
                                minValue:
                                    validMinutes.isEmpty
                                        ? 0
                                        : validMinutes.first,
                                maxValue:
                                    validMinutes.isEmpty
                                        ? 0
                                        : validMinutes.last,
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

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 55,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Batal",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed:
                            validHours.isEmpty
                                ? null
                                : () {
                                  finalDate = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedHour,
                                    selectedMinute,
                                  );
                                  Navigator.pop(context, finalDate);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 65,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "OK",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  return finalDate;
}
