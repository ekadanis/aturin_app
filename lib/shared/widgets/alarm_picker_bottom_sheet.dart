import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'bottom_sheet_container.dart';

Future<DateTime?> showCustomAlarmPickerBottomSheet(
  BuildContext context, {
  DateTime? initialDateTime,
  required DateTime selectedDate,
  required TimeOfDay startTime,
  required DateTime maxDate, // Tambahkan parameter maxDate (deadline)
}) async {
  final now = DateTime.now();
  
  // Calculate start time as DateTime
  final startDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    startTime.hour,
    startTime.minute,
  );
  
  // Max alarm time is 1 minute before start time
  final maxAlarmDateTime = startDateTime.subtract(const Duration(minutes: 1));

  // Initialize alarm time - use provided initialDateTime or default to current time + 15 minutes
  DateTime initialDate;
  if (initialDateTime != null) {
    initialDate = initialDateTime;
    // Ensure initial date is within valid bounds
    if (initialDate.isBefore(now)) {
      initialDate = now.add(const Duration(minutes: 15));
    } else if (initialDate.isAfter(maxAlarmDateTime)) {
      initialDate = maxAlarmDateTime;
    }
  } else {
    // Default: 15 minutes from now, but ensure it's before max alarm time
    initialDate = now.add(const Duration(minutes: 15));
    if (initialDate.isAfter(maxAlarmDateTime)) {
      initialDate = maxAlarmDateTime;
    }
  }

  DateTime selectedAlarmDate = DateTime(
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
      final nowTruncated = DateTime(now.year, now.month, now.day);
      final maxDateTruncated = DateTime(maxDate.year, maxDate.month, maxDate.day); // Ganti ke maxDate

      final maxDays = maxDateTruncated.difference(nowTruncated).inDays;
      final initialDayIndex = selectedAlarmDate.difference(nowTruncated).inDays;
      final validInitialDayIndex = initialDayIndex.clamp(0, maxDays);

      final dayScrollController = FixedExtentScrollController(
        initialItem: validInitialDayIndex,
      );

      return StatefulBuilder(
        builder: (context, setState) {
          final availableDates = List.generate(
            maxDays + 1,
            (index) => nowTruncated.add(Duration(days: index)),
          );

          List<int> getValidHours() {
            final List<int> hours = [];
            final isToday = selectedAlarmDate.year == nowTruncated.year &&
                selectedAlarmDate.month == nowTruncated.month &&
                selectedAlarmDate.day == nowTruncated.day;

            final isSelectedDay = selectedAlarmDate.year == selectedDate.year &&
                selectedAlarmDate.month == selectedDate.month &&
                selectedAlarmDate.day == selectedDate.day;

            int minHour = isToday ? now.hour : 0;
            int maxHour = isSelectedDay ? maxAlarmDateTime.hour : 23;

            // Adjust min hour if we're in the same hour as now
            if (isToday && minHour == now.hour && now.minute >= 59) {
              minHour = now.hour + 1;
            }

            for (int h = minHour; h <= maxHour; h++) {
              hours.add(h);
            }

            return hours;
          }

          List<int> getValidMinutes() {
            final List<int> minutes = [];

            final isSameAsNow = selectedAlarmDate.year == now.year &&
                selectedAlarmDate.month == now.month &&
                selectedAlarmDate.day == now.day &&
                selectedHour == now.hour;

            final isSameAsMaxAlarm = selectedAlarmDate.year == selectedDate.year &&
                selectedAlarmDate.month == selectedDate.month &&
                selectedAlarmDate.day == selectedDate.day &&
                selectedHour == maxAlarmDateTime.hour;

            int minMinute = isSameAsNow ? now.minute + 1 : 0;
            int maxMinute = isSameAsMaxAlarm ? maxAlarmDateTime.minute : 59;

            for (int m = minMinute; m <= maxMinute; m++) {
              minutes.add(m);
            }

            return minutes;
          }

          final validHours = getValidHours();
          final validMinutes = getValidMinutes();

          // Ensure we have at least one valid option
          if (validHours.isEmpty) {
            return BottomSheetContainer(
              title: 'Kustom Alarm',
              subtitle: 'Tidak ada waktu yang tersedia',
              content: const Center(
                child: Text('Tidak ada waktu alarm yang valid untuk tanggal ini'),
              ),
              onCancel: () => Navigator.pop(context),
              onConfirm: null,
              isConfirmEnabled: false,
            );
          }

          if (validMinutes.isEmpty) {
            validMinutes.add(0);
          }

          // Adjust selected values if they're not valid
          if (!validHours.contains(selectedHour)) {
            selectedHour = validHours.first;
          }

          if (!validMinutes.contains(selectedMinute)) {
            selectedMinute = validMinutes.first;
          }

          final currentSelectedDateTime = DateTime(
            selectedAlarmDate.year,
            selectedAlarmDate.month,
            selectedAlarmDate.day,
            selectedHour,
            selectedMinute,
          );

          final formattedDateTime = DateFormat(
            'EEEE, d MMM yyyy, HH:mm',
            'id_ID',
          ).format(currentSelectedDateTime);

          return BottomSheetContainer(
            title: 'Kustom Alarm',
            subtitle: formattedDateTime,
            content: Column(
              children: [
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
                                selectedAlarmDate = availableDates[index];

                                // Update hour and minute based on new date
                                final newValidHours = getValidHours();
                                if (newValidHours.isNotEmpty && !newValidHours.contains(selectedHour)) {
                                  selectedHour = newValidHours.first;
                                }

                                final newValidMinutes = getValidMinutes();
                                if (newValidMinutes.isNotEmpty && !newValidMinutes.contains(selectedMinute)) {
                                  selectedMinute = newValidMinutes.first;
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
                                  date.year == selectedAlarmDate.year &&
                                  date.month == selectedAlarmDate.month &&
                                  date.day == selectedAlarmDate.day;

                              String displayText;
                              if (date.year == now.year &&
                                  date.month == now.month &&
                                  date.day == now.day) {
                                displayText = 'Hari ini';
                              } else if (date.year == now.year &&
                                  date.month == now.month &&
                                  date.day == now.day + 1) {
                                displayText = 'Besok';
                              } else {
                                displayText = DateFormat(
                                  'EEEE, d MMM',
                                  'id_ID',
                                ).format(date);
                              }

                              return Center(
                                child: Text(
                                  displayText,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
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
                              textMapper: (numberText) {
                                return numberText.padLeft(2, '0');
                              },
                              onChanged: (value) => setState(() {
                                if (validHours.contains(value)) {
                                  selectedHour = value;

                                  // Update valid minutes for new hour
                                  final newValidMinutes = getValidMinutes();
                                  if (newValidMinutes.isNotEmpty && !newValidMinutes.contains(selectedMinute)) {
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
                              infiniteLoop: false,
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
                              textMapper: (numberText) {
                                return numberText.padLeft(2, '0');
                              },
                              onChanged: (value) => setState(() {
                                if (validMinutes.contains(value)) {
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
            onConfirm: () {
              finalDate = DateTime(
                selectedAlarmDate.year,
                selectedAlarmDate.month,
                selectedAlarmDate.day,
                selectedHour,
                selectedMinute,
              );
              Navigator.pop(context, finalDate);
            },
            isConfirmEnabled: true,
          );
        },
      );
    },
  );

  return finalDate;
}