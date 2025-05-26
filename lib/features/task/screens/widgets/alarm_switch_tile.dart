import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class AlarmSwitchTile extends StatelessWidget {
  final bool isEnabled;
  final bool canEnableAlarm;
  final VoidCallback? onToggle;
  final VoidCallback? onTapDisabled;
  final String? toggleError;
  final bool showError;

  const AlarmSwitchTile({
    super.key,
    required this.isEnabled,
    required this.canEnableAlarm,
    this.onToggle,
    this.onTapDisabled,
    this.toggleError,
    this.showError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            GestureDetector(
              onTap: () {
                if (!canEnableAlarm && onTapDisabled != null) {
                  onTapDisabled!();
                }
              },
              child: AbsorbPointer(
                absorbing: !canEnableAlarm,
                child: Switch(
                  value: isEnabled,
                  onChanged: canEnableAlarm ? (_) => onToggle?.call() : null,
                  splashRadius: 0,
                  trackColor: MaterialStateProperty.resolveWith((states) {
                    if (!canEnableAlarm) return Colors.grey.shade200;
                    return states.contains(MaterialState.selected)
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300;
                  }),
                  thumbColor: MaterialStateProperty.resolveWith((states) {
                    if (!canEnableAlarm) return Colors.grey.shade400;
                    return Colors.white;
                  }),
                  overlayColor: const MaterialStatePropertyAll(Colors.transparent),
                  trackOutlineColor: const MaterialStatePropertyAll(Colors.transparent),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            toggleError ??
                '*Pilih deadline terlebih dahulu untuk mengaktifkan alarm',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: showError ? Colors.red : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
