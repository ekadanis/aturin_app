import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AlarmPicker extends StatelessWidget {
  final bool isEnabled;
  final DateTime? alarmDateTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onPickTime;
  final String? errorText;
  final bool showError;
  final bool showInitialWarning;
  final bool isDeadlineTooClose;
  final bool isAlarmTimePassed;

  const AlarmPicker({
    super.key,
    required this.isEnabled,
    required this.alarmDateTime,
    required this.onToggle,
    required this.onPickTime,
    this.errorText,
    this.showError = false,
    this.showInitialWarning = false,
    this.isDeadlineTooClose = false,
    this.isAlarmTimePassed = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disableSwitch = isDeadlineTooClose || isAlarmTimePassed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alarm',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: disableSwitch ? null : onToggle,
              splashRadius: 0,
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF5263F3)
                    : Colors.grey.shade300,
              ),
              thumbColor: const WidgetStatePropertyAll(Colors.white),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
        ),

        // Conditional messages
        if (!isEnabled && showInitialWarning)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '*Pilih batas waktu terlebih dahulu untuk mengaktifkan alarm',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        if (isDeadlineTooClose)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '*Alarm hanya dapat diatur minimal 1 jam sebelum deadline',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        // if (isAlarmTimePassed)
        //   Padding(
        //     padding: const EdgeInsets.only(top: 4),
        //     child: Text(
        //       '*Waktu alarm sudah terlewati, alarm tidak dapat diaktifkan',
        //       style: GoogleFonts.plusJakartaSans(
        //         fontSize: 10,
        //         color: Colors.red,
        //         fontStyle: FontStyle.italic,
        //       ),
        //     ),
        //   ),
        if (showError && errorText != null && !isDeadlineTooClose && !isAlarmTimePassed)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

        // Time picker
          // Pick time when enabled
        if (isEnabled)
          GestureDetector(
            onTap: onPickTime,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Atur Alarm',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        alarmDateTime == null
                            ? 'Kustom'
                            : DateFormat(
                              'EEEE, d MMM yyyy, HH:mm',
                              'id_ID',
                            ).format(alarmDateTime!),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
