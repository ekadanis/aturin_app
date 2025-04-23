import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';

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
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setState) => SafeArea(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 32,
                ),
                margin: const EdgeInsets.only(top: 100),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Deadline',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: SizedBox(
                              height: 150,
                              child: ListWheelScrollView.useDelegate(
                                itemExtent: 48,
                                perspective: 0.005,
                                diameterRatio: 2,
                                onSelectedItemChanged: (index) {
                                  setState(
                                    () =>
                                        selectedDate = now.add(
                                          Duration(days: index),
                                        ),
                                  );
                                },
                                physics: const FixedExtentScrollPhysics(),
                                childDelegate: ListWheelChildBuilderDelegate(
                                  builder: (context, index) {
                                    final date = now.add(Duration(days: index));
                                    final isSelected =
                                        selectedDate.difference(date).inDays ==
                                        0;
                                    return Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        DateFormat('EEEE, d MMM', 'id_ID').format(date),
                                        style: TextStyle(
                                          color:
                                              isSelected
                                                  ? AppTheme.primaryColor
                                                  : AppTheme.primaryColor,
                                          fontWeight:
                                              isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          fontSize: isSelected ? 18 : 15,
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: 1000,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Time Picker (minute and hour side by side)
                        Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    NumberPicker(
                                      minValue: 0,
                                      maxValue: 23,
                                      value: selectedHour,
                                      zeroPad: true,
                                      itemWidth: 50,
                                      itemHeight: 50,
                                      onChanged:
                                          (value) => setState(
                                            () => selectedHour = value,
                                          ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    NumberPicker(
                                      minValue: 0,
                                      maxValue: 59,
                                      value: selectedMinute,
                                      zeroPad: true,
                                      itemWidth: 50,
                                      itemHeight: 50,
                                      onChanged:
                                          (value) => setState(
                                            () => selectedMinute = value,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color:AppTheme.primaryColor),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Batal",
                            style: TextStyle(color: AppTheme.primaryColor),
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
                            Navigator.pop(context);
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
                          child: const Text("OK"),
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
