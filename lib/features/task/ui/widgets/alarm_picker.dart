import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AlarmPicker extends StatelessWidget {
  final bool isEnabled;
  final DateTime? alarmDateTime;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onPickTime;

  const AlarmPicker({
    super.key,
    required this.isEnabled,
    required this.alarmDateTime,
    required this.onToggle,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Switch bar row
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
              onChanged: onToggle,
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
                    'Waktu Alarm',
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
                            ? 'Pilih waktu alarm'
                            : DateFormat('EEEE, d MMM yyyy, HH:mm', 'id_ID')
                                .format(alarmDateTime!),
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
