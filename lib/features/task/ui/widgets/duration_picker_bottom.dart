import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

Future<Duration?> showDurationPickerBottomSheet(BuildContext context) async {
  int selectedHour = 0;
  int selectedMinute = 15;
  Duration? result;

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder:
            (context, setState) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Estimasi Durasi',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NumberPicker(
                        minValue: 0,
                        maxValue: 23,
                        value: selectedHour,
                        zeroPad: true,
                        onChanged:
                            (value) => setState(() => selectedHour = value),
                      ),
                      const Text(":"),
                      NumberPicker(
                        minValue: 0,
                        maxValue: 59,
                        value: selectedMinute,
                        zeroPad: true,
                        onChanged:
                            (value) => setState(() => selectedMinute = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Batal"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          result = Duration(
                            hours: selectedHour,
                            minutes: selectedMinute,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Simpan"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      );
    },
  );

  return result;
}
