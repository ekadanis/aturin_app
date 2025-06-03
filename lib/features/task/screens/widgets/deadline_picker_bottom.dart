import '../../../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/widgets/bottom_sheet_container.dart';

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
        builder: (context, setState) {
          final isToday =
              selectedDate.year == now.year &&
              selectedDate.month == now.month &&
              selectedDate.day == now.day;

          final minHour = isToday ? now.hour : 0;
          final minMinute =
              isToday && selectedHour == now.hour ? now.minute : 0;

          // Auto-adjust if value < min
          if (selectedHour < minHour) selectedHour = minHour;
          if (selectedMinute < minMinute) selectedMinute = minMinute;

          final formattedDateTime = DateFormat(
            'EEEE, d MMM yyyy, HH:mm',
            'id_ID',
          ).format(
            DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedHour,
              selectedMinute,
            ),
          );

          return BottomSheetContainer(
            title: 'Deadline',
            subtitle: formattedDateTime,
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: ListWheelScrollView.useDelegate(
                      controller: FixedExtentScrollController(initialItem: 0),
                      itemExtent: 40,
                      diameterRatio: 5,
                      perspective: 0.002,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDate = now.add(Duration(days: index));

                          // Reset jam dan menit saat ganti hari
                          if (!(selectedDate.year == now.year &&
                              selectedDate.month == now.month &&
                              selectedDate.day == now.day)) {
                            selectedHour = 0;
                            selectedMinute = 0;
                          }

                          // Jika hari ini, pastikan jam dan menit valid
                          final isToday =
                              selectedDate.year == now.year &&
                              selectedDate.month == now.month &&
                              selectedDate.day == now.day;

                          final minHour = isToday ? now.hour : 0;
                          final minMinute =
                              isToday && selectedHour == now.hour
                                  ? now.minute
                                  : 0;

                          if (selectedHour < minHour) selectedHour = minHour;
                          if (selectedMinute < minMinute)
                            selectedMinute = minMinute;
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
                              DateFormat('EEEE, d MMM', 'id_ID').format(date),
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
                          minValue: minHour,
                          maxValue: 23,
                          value:
                              selectedHour < minHour ? minHour : selectedHour,
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

                                if (isToday &&
                                    selectedHour == now.hour &&
                                    selectedMinute < now.minute) {
                                  selectedMinute = now.minute;
                                }
                              }),
                        ),

                        const SizedBox(width: 8),

                        NumberPicker(
                          minValue: minMinute,
                          maxValue: 59,
                          value:
                              selectedMinute < minMinute
                                  ? minMinute
                                  : selectedMinute,
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
            onCancel: () => Navigator.pop(context),
            onConfirm: () {
              final now = DateTime.now();

              DateTime candidate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedHour,
                selectedMinute,
              );

              if (candidate.isBefore(now)) {
                candidate = now;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Waktu sudah lewat, batas waktu diatur ke sekarang',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }

              finalDate = candidate;
              Navigator.pop(context, finalDate);
            },
          );
        },
      );
    },
  );

  return finalDate;
}
