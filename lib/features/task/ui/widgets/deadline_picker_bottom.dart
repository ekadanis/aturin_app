import '../../../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bottom_sheet_container.dart';

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
          // Membuat formated subtitle untuk ditampilkan
          final formattedDateTime = DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID').format(
            DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedHour,
              selectedMinute,
            ),
          );
          
          // Menggunakan komponen BottomSheetContainer yang reusable
          return BottomSheetContainer(
            title: 'Deadline',
            subtitle: formattedDateTime,
            content: Row(
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
                          minValue:
                              selectedDate.day == now.day &&
                                      selectedDate.month == now.month &&
                                      selectedDate.year == now.year
                                  ? now
                                      .hour // kalau hari ini, mulai dari jam sekarang
                                  : 0, // kalau bukan hari ini, dari jam 0
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
                              (value) => setState(() {
                                selectedHour = value;

                                // Reset menit kalau jam berubah (supaya valid)
                                if (selectedDate.day == now.day &&
                                    selectedDate.month == now.month &&
                                    selectedDate.year == now.year &&
                                    selectedHour == now.hour &&
                                    selectedMinute < now.minute) {
                                  selectedMinute = now.minute;
                                }
                              }),
                        ),

                        const SizedBox(width: 8),
                        NumberPicker(
                          minValue:
                              selectedDate.day == now.day &&
                                      selectedDate.month == now.month &&
                                      selectedDate.year == now.year &&
                                      selectedHour == now.hour
                                  ? now
                                      .minute // kalau jam sama dengan sekarang, menit mulai dari sekarang
                                  : 0, // kalau tidak, mulai dari 0
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
              finalDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedHour,
                selectedMinute,
              );
              Navigator.pop(context, finalDate);
            },
          );
        },
      );
    },
  );

  return finalDate;
}
