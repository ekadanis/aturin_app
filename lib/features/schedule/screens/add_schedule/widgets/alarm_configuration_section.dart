// AlarmConfigurationSection - Revised with multi-day support
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/widgets/alarm_picker.dart';
import 'package:aturin_app/features/schedule/screens/add_schedule/widgets/alarm_picker_bottom_sheet.dart';

class AlarmConfigurationSection extends StatelessWidget {
  final bool isEnabled;
  final DateTime? alarmDateTime;
  final DateTime selectedDate;
  final TimeOfDay? startTime;
  final Function(bool) onToggle;
  final Function(DateTime) onAlarmTimeChanged;

  const AlarmConfigurationSection({
    super.key,
    required this.isEnabled,
    required this.alarmDateTime,
    required this.selectedDate,
    required this.startTime,
    required this.onToggle,
    required this.onAlarmTimeChanged,
  });

  // Check if alarm can be enabled with 1-minute minimum gap
  bool get _canEnableAlarm {
    if (startTime == null) return false;

    final now = DateTime.now();
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    // Alarm hanya bisa diaktifkan jika waktu mulai > waktu sekarang + 1 menit
    final minimumStartTime = now.add(const Duration(minutes: 1));
    return startDateTime.isAfter(minimumStartTime);
  }

  // Check if current alarm time is still valid
  bool get _isAlarmTimeValid {
    if (alarmDateTime == null) return true;
    
    final now = DateTime.now();
    // Alarm tidak valid jika waktu alarm sudah lewat
    return alarmDateTime!.isAfter(now);
  }

  // Get effective alarm state
  bool get _effectiveAlarmEnabled {
    if (!_canEnableAlarm) return false;
    if (!_isAlarmTimeValid) return false;
    return isEnabled;
  }

  Future<void> _selectCustomAlarmTime(BuildContext context) async {
    if (startTime != null && _canEnableAlarm) {
      final selectedAlarmTime = await showCustomAlarmPickerBottomSheet(
        context,
        initialDateTime: _isAlarmTimeValid ? alarmDateTime : null,
        selectedDate: selectedDate,
        startTime: startTime!,
      );

      if (selectedAlarmTime != null) {
        onAlarmTimeChanged(selectedAlarmTime);
      }
    }
  }

  String get _getErrorMessage {
    if (startTime == null) {
      return '*Isi dulu waktu mulai alarmnya';
    }

    final now = DateTime.now();
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    final minimumStartTime = now.add(const Duration(minutes: 1));
    
    if (startDateTime.isBefore(minimumStartTime) || startDateTime.isAtSameMomentAs(now)) {
      return '*Alarm butuh jarak minimal 1 menit dari waktu sekarang';
    }

    if (alarmDateTime != null && !_isAlarmTimeValid) {
      return '*Waktu alarm sudah lewat, silakan atur ulang';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    // Auto-disable alarm if time is no longer valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEnabled && !_isAlarmTimeValid && _canEnableAlarm) {
        onToggle(false);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alarm picker dengan disabled state
        Opacity(
          opacity: _canEnableAlarm ? 1.0 : 0.5,
          child: IgnorePointer(
            ignoring: !_canEnableAlarm,
            child: AlarmPicker(
              isEnabled: _effectiveAlarmEnabled,
              alarmDateTime: _isAlarmTimeValid ? alarmDateTime : null,
              onToggle: _canEnableAlarm 
                  ? (value) {
                      if (value && !_isAlarmTimeValid) {
                        // Reset alarm time if trying to enable with invalid time
                        final now = DateTime.now();
                        final defaultAlarmTime = now.add(const Duration(minutes: 15));
                        onAlarmTimeChanged(defaultAlarmTime);
                      }
                      onToggle(value);
                    }
                  : (_) {}, // Empty function when disabled
              onPickTime: _canEnableAlarm 
                  ? () => _selectCustomAlarmTime(context)
                  : null,
              showInitialWarning: false,
            ),
          ),
        ),

        // Error message di bawah alarm picker dengan teks merah
        if (!_canEnableAlarm || !_isAlarmTimeValid) ...[
          const SizedBox(height: 8),
          Text(
            _getErrorMessage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}