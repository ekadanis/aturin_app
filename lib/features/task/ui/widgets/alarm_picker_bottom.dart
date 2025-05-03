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
  // Waktu saat ini sebagai batas minimum
  final now = DateTime.now();

  // Gunakan maxDateTime langsung sebagai batas maksimum karena sudah dikurangi 1 jam dari deadline
  // di add_task_screen.dart
  final safeMaxDateTime = maxDateTime;

  // Pastikan initialDateTime berada di antara now dan safeMaxDateTime
  DateTime initialDate = initialDateTime ?? now;
  if (initialDate.isBefore(now)) {
    initialDate = now;
  } else if (initialDate.isAfter(safeMaxDateTime)) {
    initialDate = safeMaxDateTime;
  }

  // Truncate to day for selection
  DateTime selectedDate = DateTime(
    initialDate.year,
    initialDate.month,
    initialDate.day,
  );
  int selectedHour = initialDate.hour;
  int selectedMinute = initialDate.minute;
  DateTime? finalDate;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      // Prepare dates for selection
      final nowTruncated = DateTime(now.year, now.month, now.day);
      final maxTruncated = DateTime(
        safeMaxDateTime.year,
        safeMaxDateTime.month,
        safeMaxDateTime.day,
      );

      // Calculate the day difference for controller initialization
      final maxDays = maxTruncated.difference(nowTruncated).inDays;
      final initialDayIndex = selectedDate.difference(nowTruncated).inDays;

      // Ensure initial day index is valid
      final validInitialDayIndex = initialDayIndex.clamp(0, maxDays);

      // Setup day scroll controller
      final dayScrollController = FixedExtentScrollController(
        initialItem: validInitialDayIndex,
      );

      return StatefulBuilder(
        builder: (context, setState) {
          // Tanggal-tanggal yang dapat dipilih (dari sekarang hingga batas max)
          final availableDates = List.generate(
            maxDays + 1,
            (index) => nowTruncated.add(Duration(days: index)),
          );

          // Generate valid hours for selected date
          List<int> getValidHours() {
            final List<int> hours = [];
            final isToday =
                selectedDate.year == nowTruncated.year &&
                selectedDate.month == nowTruncated.month &&
                selectedDate.day == nowTruncated.day;

            final isMaxDay =
                selectedDate.year == maxTruncated.year &&
                selectedDate.month == maxTruncated.month &&
                selectedDate.day == maxTruncated.day;

            // Jika hari ini, mulai dari jam sekarang
            int minHour = isToday ? now.hour : 0;

            // Jika hari terakhir, hanya sampai jam batas maksimal
            int maxHour = isMaxDay ? safeMaxDateTime.hour : 23;

            // Tambahkan semua jam yang valid
            for (int h = minHour; h <= maxHour; h++) {
              hours.add(h);
            }

            return hours;
          }

          // Generate valid minutes for selected hour
          List<int> getValidMinutes() {
            final List<int> minutes = [];

            // Same day and hour as now - only minutes after current minute
            final isSameAsNow =
                selectedDate.year == now.year &&
                selectedDate.month == now.month &&
                selectedDate.day == now.day &&
                selectedHour == now.hour;

            // Same day and hour as max - only minutes before max minute
            final isSameAsMax =
                selectedDate.year == safeMaxDateTime.year &&
                selectedDate.month == safeMaxDateTime.month &&
                selectedDate.day == safeMaxDateTime.day &&
                selectedHour == safeMaxDateTime.hour;

            // Set min and max minutes based on conditions
            final int minMinute = isSameAsNow ? now.minute : 0;
            final int maxMinute = isSameAsMax ? safeMaxDateTime.minute : 59;

            // Add all valid minutes
            for (int m = minMinute; m <= maxMinute; m++) {
              minutes.add(m);
            }

            return minutes;
          }

          // Get valid hours and minutes
          final validHours = getValidHours();
          final validMinutes = getValidMinutes();

          // Set default values if lists are empty to avoid NumberPicker exceptions
          if (validHours.isEmpty) {
            // Add safety value to prevent NumberPicker assertion error
            validHours.add(0);
          }

          if (validMinutes.isEmpty) {
            // Add safety value to prevent NumberPicker assertion error
            validMinutes.add(0);
          }

          // Ensure selected hour and minute are valid
          if (!validHours.contains(selectedHour)) {
            selectedHour = validHours.first;
          }

          if (!validMinutes.contains(selectedMinute)) {
            selectedMinute = validMinutes.first;
          }

          // Format the selected datetime
          final currentSelectedDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedHour,
            selectedMinute,
          );

          // Format strings for display
          final formattedDateTime = DateFormat(
            'EEEE, d MMM yyyy, HH:mm',
            'id_ID',
          ).format(currentSelectedDateTime);

          final formattedMaxAlarmTime = DateFormat(
            'HH:mm',
            'id_ID',
          ).format(safeMaxDateTime);
          final formattedMaxAlarmDate = DateFormat(
            'EEEE, d MMM',
            'id_ID',
          ).format(safeMaxDateTime);

          final deadlineNote =
              '*Waktu alarm harus antara sekarang dan $formattedMaxAlarmTime, $formattedMaxAlarmDate (1 jam sebelum deadline)';

          return BottomSheetContainer(
            title: 'Atur Alarm',
            subtitle: formattedDateTime,
            content: Column(
              children: [
                // Info deadline
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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

                    // Day picker
                    Expanded(
                      child: SizedBox(
                        height: 150,
                        child: ListWheelScrollView.useDelegate(
                          controller: dayScrollController,
                          itemExtent: 40,
                          diameterRatio: 5,
                          perspective: 0.002,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            if (index >= 0 && index < availableDates.length) {
                              setState(() {
                                // Update selected date
                                selectedDate = availableDates[index];

                                final newValidHours = getValidHours();
                                if (newValidHours.isNotEmpty) {
                                  selectedHour = newValidHours.first;

                                  final newValidMinutes = getValidMinutes();
                                  if (newValidMinutes.isNotEmpty) {
                                    selectedMinute = newValidMinutes.first;
                                  }
                                }
                              });
                            }
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: availableDates.length,
                            builder: (context, index) {
                              if (index < 0 || index >= availableDates.length) {
                                return Container();
                              }

                              final date = availableDates[index];
                              final bool isSelected =
                                  date.year == selectedDate.year &&
                                  date.month == selectedDate.month &&
                                  date.day == selectedDate.day;

                              return Center(
                                child: Text(
                                  DateFormat(
                                    'EEEE, d MMM',
                                    'id_ID',
                                  ).format(date),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
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
                            // Hour picker
                            NumberPicker(
                              minValue: validHours.first,
                              maxValue: validHours.last,
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
                                    // Ensure value is within bounds
                                    if (value >= validHours.first &&
                                        value <= validHours.last) {
                                      selectedHour = value;

                                      // Reset minutes when hour changes
                                      final newValidMinutes = getValidMinutes();
                                      if (newValidMinutes.isNotEmpty) {
                                        selectedMinute = newValidMinutes.first;
                                      }
                                    }
                                  }),
                            ),

                            const SizedBox(width: 8),
                            Text(
                              ":",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Minute picker
                            NumberPicker(
                              minValue: validMinutes.first,
                              maxValue: validMinutes.last,
                              value: selectedMinute,
                              zeroPad: true,
                              itemWidth: 50,
                              itemHeight: 50,
                              step: 1, // 1 minute precision
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
                                    if (value >= validMinutes.first &&
                                        value <= validMinutes.last) {
                                      selectedMinute = value;
                                    }
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
            onConfirm:
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
            isConfirmEnabled: validHours.isNotEmpty,
          );
        },
      );
    },
  );

  return finalDate;
}
