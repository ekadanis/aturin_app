import '../../../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:google_fonts/google_fonts.dart';

Future<DateTime?> showAlarmPickerBottomSheet(
  BuildContext context, {
  DateTime? initialDateTime,
  DateTime? maxDateTime,
}) async {
  
  DateTime now = DateTime.now();
  // Gunakan initialDateTime jika tersedia, jika tidak gunakan waktu saat ini
  DateTime initialDate = initialDateTime ?? now;
  DateTime selectedDate = DateTime(initialDate.year, initialDate.month, initialDate.day);
  int selectedHour = initialDate.hour;
  int selectedMinute = initialDate.minute;
  DateTime? finalDate;

  // Tentukan batas maksimum tanggal yang bisa dipilih
  final maxDate = maxDateTime ?? DateTime(now.year + 5, now.month, now.day); // Default 5 tahun ke depan
  final maxDaysFromNow = maxDate.difference(now).inDays;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.white.withOpacity(0.7),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          // Function untuk validasi apakah waktu yang dipilih valid
          bool isSelectedTimeValid() {
            final selectedDateTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedHour,
              selectedMinute,
            );
            return maxDateTime == null || !selectedDateTime.isAfter(maxDateTime);
          }
          
          // Function untuk menentukan apakah jam tertentu valid
          bool isHourValid(int hour) {
            if (maxDateTime == null) return true;
            
            // Jika bukan tanggal maksimum, semua jam valid
            if (selectedDate.year != maxDate.year || 
                selectedDate.month != maxDate.month || 
                selectedDate.day != maxDate.day) {
              return true;
            }
            
            // Pada tanggal maksimum, jam harus < maxDateTime.hour (untuk buffer 1 jam)
            return hour < maxDate.hour;
          }
          
          // Function untuk menentukan apakah menit tertentu valid untuk jam yang dipilih
          bool isMinuteValid(int minute) {
            if (maxDateTime == null) return true;
            
            // Jika bukan tanggal maksimum, semua menit valid
            if (selectedDate.year != maxDate.year || 
                selectedDate.month != maxDate.month || 
                selectedDate.day != maxDate.day) {
              return true;
            }
            
            // Jika jam < maxDateTime.hour - 1, semua menit valid
            if (selectedHour < maxDate.hour - 1) {
              return true;
            }
            
            // Jika jam = maxDateTime.hour - 1, semua menit valid (masih dalam rentang 1 jam)
            if (selectedHour == maxDate.hour - 1) {
              return true;
            }
            
            // Jika jam sama dengan maxDateTime.hour, hanya menit yang < maxDateTime.minute yang valid
            if (selectedHour == maxDate.hour) {
              return minute < maxDate.minute;
            }
            
            // Jika jam > maxDateTime.hour, tidak ada menit yang valid
            return false;
          }
          
          // Generate list jam yang valid
          List<int> getValidHours() {
            List<int> hours = [];
            for (int i = 0; i <= 23; i++) {
              if (isHourValid(i)) {
                hours.add(i);
              }
            }
            return hours;
          }
          
          // Generate list menit yang valid
          List<int> getValidMinutes() {
            List<int> minutes = [];
            for (int i = 0; i <= 59; i++) {
              if (isMinuteValid(i)) {
                minutes.add(i);
              }
            }
            return minutes;
          }
          
          // Daftar jam dan menit valid
          final validHours = getValidHours();
          final validMinutes = getValidMinutes();
          
          // Pastikan jam dan menit yang dipilih valid
          if (!validHours.contains(selectedHour)) {
            selectedHour = validHours.isNotEmpty ? validHours.last : 0;
          }
          if (!validMinutes.contains(selectedMinute)) {
            selectedMinute = validMinutes.isNotEmpty ? validMinutes.last : 0;
          }
          
          return SafeArea(
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
                    'Alarm',
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
                  // Tambahkan informasi mengenai batas waktu jika ada maxDateTime
                  if (maxDateTime != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Pilih waktu alarm minimal 1 jam sebelum ${DateFormat('HH:mm', 'id_ID').format(maxDateTime)
                        }',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
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
                              initialItem: selectedDate.difference(now).inDays.clamp(0, maxDaysFromNow),
                            ),
                            itemExtent: 40,
                            diameterRatio: 5, // supaya ga terlalu "membulat"
                            perspective: 0.002, // minimal efek 3D
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (index) {
                              setState(() {
                                final newSelectedDate = now.add(Duration(days: index));
                                selectedDate = newSelectedDate;
                                
                                // Re-validasi jam dan menit saat tanggal berubah
                                final newValidHours = getValidHours();
                                if (!newValidHours.contains(selectedHour)) {
                                  selectedHour = newValidHours.isNotEmpty ? newValidHours.last : 0;
                                }
                                
                                final newValidMinutes = getValidMinutes();
                                if (!newValidMinutes.contains(selectedMinute)) {
                                  selectedMinute = newValidMinutes.isNotEmpty ? newValidMinutes.last : 0;
                                }
                              });
                            },
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: maxDaysFromNow + 1, // Batasi jumlah hari yang bisa dipilih
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
                              // Custom Hour Picker yang hanya menampilkan jam valid
                              validHours.isEmpty 
                              ? const SizedBox(
                                  width: 50,
                                  height: 150,
                                  child: Center(
                                    child: Text("--", style: TextStyle(fontSize: 20, color: Colors.grey)),
                                  ),
                                )
                              : SizedBox(
                                  width: 50,
                                  height: 150,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: FixedExtentScrollController(
                                      initialItem: validHours.indexOf(selectedHour).clamp(0, validHours.length - 1),
                                    ),
                                    itemExtent: 50,
                                    diameterRatio: 1.5,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (index) {
                                      setState(() {
                                        selectedHour = validHours[index];
                                        
                                        // Re-validasi menit saat jam berubah
                                        final newValidMinutes = getValidMinutes();
                                        if (!newValidMinutes.contains(selectedMinute)) {
                                          selectedMinute = newValidMinutes.isNotEmpty ? newValidMinutes.last : 0;
                                        }
                                      });
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: validHours.length,
                                      builder: (context, index) {
                                        final hour = validHours[index];
                                        final isSelected = selectedHour == hour;
                                        
                                        return Center(
                                          child: Text(
                                            hour.toString().padLeft(2, '0'),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: isSelected ? 20 : 16,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              color: isSelected ? AppTheme.primaryColor : Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                
                              Text(
                                ":",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              
                              // Custom Minute Picker yang hanya menampilkan menit valid
                              validMinutes.isEmpty
                              ? const SizedBox(
                                  width: 50,
                                  height: 150,
                                  child: Center(
                                    child: Text("--", style: TextStyle(fontSize: 20, color: Colors.grey)),
                                  ),
                                )
                              : SizedBox(
                                  width: 50,
                                  height: 150,
                                  child: ListWheelScrollView.useDelegate(
                                    controller: FixedExtentScrollController(
                                      initialItem: validMinutes.indexOf(selectedMinute).clamp(0, validMinutes.length - 1),
                                    ),
                                    itemExtent: 50,
                                    diameterRatio: 1.5,
                                    physics: const FixedExtentScrollPhysics(),
                                    onSelectedItemChanged: (index) {
                                      setState(() {
                                        selectedMinute = validMinutes[index];
                                      });
                                    },
                                    childDelegate: ListWheelChildBuilderDelegate(
                                      childCount: validMinutes.length,
                                      builder: (context, index) {
                                        final minute = validMinutes[index];
                                        final isSelected = selectedMinute == minute;
                                        
                                        return Center(
                                          child: Text(
                                            minute.toString().padLeft(2, '0'),
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: isSelected ? 20 : 16,
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                              color: isSelected ? AppTheme.primaryColor : Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
                        onPressed: (validHours.isNotEmpty && validMinutes.isNotEmpty) ? () {
                          finalDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedHour,
                            selectedMinute,
                          );
                          Navigator.pop(context, finalDate);
                        } : null, // Nonaktifkan tombol jika tidak ada waktu valid
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (validHours.isNotEmpty && validMinutes.isNotEmpty) ? AppTheme.primaryColor : Colors.grey,
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
          );
        },
      );
    },
  );

  return finalDate;
}