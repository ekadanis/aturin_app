import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';

Future<DateTime?> showDeadlinePickerBottomSheet(BuildContext context) async {

  
  DateTime now = DateTime.now();
  DateTime selectedDate = DateTime(now.year, now.month, now.day);
  int selectedHour = now.hour;
  int selectedMinute = now.minute;
  DateTime? finalDate;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setState) => SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
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
                      'Deadline',
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
                    const SizedBox(height: 24),

                    // Date & Time Picker
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date List
                        Expanded(
                          child: SizedBox(
                            height: 150,
                            child: ListWheelScrollView.useDelegate(
                              controller: FixedExtentScrollController(
                                initialItem: 0,
                              ),
                              itemExtent: 40,
                              diameterRatio: 5, // supaya ga terlalu "membulat"
                              perspective: 0.002, // minimal efek 3D
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  selectedDate = now.add(Duration(days: index));
                                });
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 100,
                                builder: (context, index) {
                                  final date = now.add(Duration(days: index));
                                  final isSelected =
                                      selectedDate.year == date.year &&
                                      selectedDate.month == date.month &&
                                      selectedDate.day == date.day;

                                  return Center(
                                    child: Text(
                                      DateFormat(
                                        'EEEE, d MMM',
                                        'id_ID',
                                      ).format(date),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: isSelected ? 18 : 16,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                        color:
                                            isSelected
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
                                NumberPicker(
                                  minValue: 0,
                                  maxValue: 23,
                                  value: selectedHour,
                                  zeroPad: true,
                                  itemWidth: 50,
                                  itemHeight: 50,
                                  textStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey,
                                  ),
                                  selectedTextStyle:
                                      GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                  onChanged:
                                      (value) =>
                                          setState(() => selectedHour = value),
                                ),
                                const SizedBox(width: 8),
                                NumberPicker(
                                  minValue: 0,
                                  maxValue: 59,
                                  value: selectedMinute,
                                  zeroPad: true,
                                  itemWidth: 50,
                                  itemHeight: 50,
                                  textStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey,
                                  ),
                                  selectedTextStyle:
                                      GoogleFonts.plusJakartaSans(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                  onChanged:
                                      (value) => setState(
                                        () => selectedMinute = value,
                                      ),
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
                            side: const BorderSide(
                              color: AppTheme.primaryColor,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 12,
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
                          onPressed: () {
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
                              horizontal: 40,
                              vertical: 12,
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
            ),
      );
    },
  );

  return finalDate;
}
