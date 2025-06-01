import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/widgets/alarm_picker.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/waktu_mulai_waktu_selesai_picker_screen.dart';

class AlarmConfigurationSection extends StatelessWidget {
  final bool isEnabled;
  final DateTime? alarmDateTime;
  final DateTime selectedDate;
  final TimeOfDay? startTime;
  final Function(bool) onToggle;
  final Function(DateTime) onAlarmTimeChanged;
  final bool isEditing; // New parameter to distinguish between create and edit modes

  const AlarmConfigurationSection({
    super.key,
    required this.isEnabled,
    required this.alarmDateTime,
    required this.selectedDate,
    required this.startTime,
    required this.onToggle,
    required this.onAlarmTimeChanged,
    this.isEditing = false, // Default to false for backward compatibility
  });  // Check if start time allows for alarm (start time should be in the future with 1 minute buffer)
  bool get _hasValidStartTime {
    if (startTime == null) return false;

    // For editing mode, allow alarm configuration even for past activities
    if (isEditing) return true;

    final now = DateTime.now();
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    // For activities, we need to check if the complete datetime is in the future
    // If it's today, require at least 1 minute buffer
    // If it's a future date, allow any time on that date
    if (selectedDate.year == now.year && 
        selectedDate.month == now.month && 
        selectedDate.day == now.day) {
      // Same day - require 1 minute buffer
      return startDateTime.isAfter(now.add(const Duration(minutes: 1)));
    } else {
      // Future date - just ensure the complete datetime is in the future
      return startDateTime.isAfter(now);
    }
  }
  // Check if current alarm time is still valid and not equal to current time
  bool get _isAlarmTimeValid {
    if (alarmDateTime == null) return true;
    
    // For editing mode, preserve existing alarm times even if they've passed
    if (isEditing) return true;
    
    final now = DateTime.now();
    // Check if alarm time is in the future and not equal to current time
    return alarmDateTime!.isAfter(now) && 
           !(alarmDateTime!.year == now.year &&
             alarmDateTime!.month == now.month &&
             alarmDateTime!.day == now.day &&
             alarmDateTime!.hour == now.hour &&
             alarmDateTime!.minute == now.minute);
  }

  Future<void> _showAlarmPickerScreen(BuildContext context) async {
    if (startTime == null || !_hasValidStartTime) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlarmPickerScreen(
          selectedOption: _getCurrentAlarmOption(),
        ),
      ),
    );

    if (result != null) {
      _handleAlarmPickerResult(result);
    }
  }

  String? _getCurrentAlarmOption() {
    if (alarmDateTime == null || startTime == null) return null;
    
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );
    
    final difference = startDateTime.difference(alarmDateTime!);
    
    if (difference.inMinutes == 0) return 'on_time';
    if (difference.inMinutes == 15) return '15_minutes';
    if (difference.inMinutes == 30) return '30_minutes';
    if (difference.inMinutes == 45) return '45_minutes';
    if (difference.inMinutes == 60) return '1_hour';
    
    return null; // Custom time
  }

  void _handleAlarmPickerResult(String result) {
    if (startTime == null) return;

    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );

    DateTime? newAlarmTime;

    if (result.startsWith('custom:')) {
      // Handle custom datetime
      final customDateTimeString = result.substring(7);
      try {
        newAlarmTime = DateTime.parse(customDateTimeString);
      } catch (e) {
        return;
      }
    } else {
      // Handle preset options
      switch (result) {
        case 'on_time':
          newAlarmTime = startDateTime;
          break;
        case '15_minutes':
          newAlarmTime = startDateTime.subtract(const Duration(minutes: 15));
          break;
        case '30_minutes':
          newAlarmTime = startDateTime.subtract(const Duration(minutes: 30));
          break;
        case '45_minutes':
          newAlarmTime = startDateTime.subtract(const Duration(minutes: 45));
          break;
        case '1_hour':
          newAlarmTime = startDateTime.subtract(const Duration(hours: 1));
          break;
      }
    }    // In edit mode, allow setting any alarm time; in create mode, only allow future times
    if (newAlarmTime != null && (isEditing || newAlarmTime.isAfter(DateTime.now()))) {
      onAlarmTimeChanged(newAlarmTime);
      onToggle(true);
    }
  }
  String get _getInfoMessage {
    if (startTime == null) {
      return '*Silakan isi waktu mulai terlebih dahulu';
    }

    final now = DateTime.now();
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime!.hour,
      startTime!.minute,
    );    // Check if start time has already passed - but allow in edit mode
    if (startDateTime.isBefore(now) || startDateTime.isAtSameMomentAs(now)) {
      if (isEditing) {
        return '*Mode edit: Waktu aktivitas dapat diperbarui sesuai kebutuhan';
      } else {
        return '*Waktu mulai sudah terlewat. Alarm tidak dapat diaktifkan untuk waktu yang sudah berlalu.';
      }
    }

    if (!_hasValidStartTime) {
      // More specific error message based on whether it's today or future date
      if (selectedDate.year == now.year && 
          selectedDate.month == now.month && 
          selectedDate.day == now.day) {
        return '*Untuk aktivitas hari ini, alarm dapat diaktifkan minimal 1 menit sebelum waktu mulai';
      } else {
        return '*Waktu mulai aktivitas harus di masa depan untuk mengaktifkan alarm';
      }
    }if (alarmDateTime != null && !_isAlarmTimeValid) {
      // In edit mode, don't show error for past alarm times - allow editing
      if (isEditing) {
        return '*Mode edit: Waktu alarm dapat diperbarui sesuai kebutuhan';
      } else {
        return '*Waktu alarm sudah lewat, silakan atur ulang';
      }
    }

    return '';
  }
  @override
  Widget build(BuildContext context) {
    // Auto-disable alarm if time equals current time - but only for new activities, not when editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isEditing && isEnabled && alarmDateTime != null && !_isAlarmTimeValid) {
        onToggle(false);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [        // Alarm picker
        AlarmPicker(
          isEnabled: isEnabled && _hasValidStartTime && _isAlarmTimeValid,
          alarmDateTime: ((_isAlarmTimeValid || isEditing) && alarmDateTime != null) ? alarmDateTime : null,
          onToggle: _hasValidStartTime 
              ? (value) {
                  if (value) {
                    // When enabling alarm, show alarm picker screen
                    _showAlarmPickerScreen(context);
                  } else {
                    // When disabling alarm
                    onToggle(false);
                  }
                }
              : (_) {}, // Disabled when start time is invalid
          onPickTime: _hasValidStartTime 
              ? () => _showAlarmPickerScreen(context)
              : null,
          showInitialWarning: false,
        ),

        // Info/Error message
        if (_getInfoMessage.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _getInfoMessage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: (!_hasValidStartTime || !_isAlarmTimeValid) ? Colors.red : Colors.orange,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}