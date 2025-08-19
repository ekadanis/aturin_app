import 'package:aturin_app/features/schedule/presentation/screens/add_aktivitas/widgets/form_field_widgets.dart';
import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'time_picker_bottom_sheet.dart';

class UserSleepPeriod extends StatefulWidget {
  final TimeOfDay? sleepTime;
  final TimeOfDay? awakeTime;
  final Function(TimeOfDay) onSleepTimeChanged;
  final Function(TimeOfDay) onAwakeTimeChanged;

  const UserSleepPeriod({
    super.key,
    this.sleepTime,
    this.awakeTime,
    required this.onSleepTimeChanged,
    required this.onAwakeTimeChanged,
  });

  @override
  State<UserSleepPeriod> createState() => _UserSleepPeriodState();
}

class _UserSleepPeriodState extends State<UserSleepPeriod> {
  bool tidurMalam = false;
  bool tidurSiang = false;

  TimeOfDay? malamStart;
  TimeOfDay? malamEnd;
  TimeOfDay? siangStart;
  TimeOfDay? siangEnd;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.lightCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.lightDividerColor, width: 1),
      ),
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- FIX: The layout is flattened into a single Row ---
            Row(
              children: [
                // This is the label on the left side
                Text(
                  'Periode Tidur',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTextColor,
                  ),
                ),

                // The Spacer takes up all available space in the middle,
                // pushing the checkboxes to the right.
                const Spacer(),

                // These two widgets now form a compact group on the right.
                _buildCheckboxOption(
                  title: "Malam",
                  value: tidurMalam,
                  onChanged: (value) {
                    setState(() => tidurMalam = value ?? false);
                  },
                ),
                _buildCheckboxOption(
                  title: "Siang",
                  value: tidurSiang,
                  onChanged: (value) {
                    setState(() => tidurSiang = value ?? false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildSleepTime(
              context,
              iconPath: 'assets/icons/half-moon.svg',
              name: 'Malam',
              startTime: malamStart,
              endTime: malamEnd,
              onStartTimeChanged: (t) => setState(() => malamStart = t),
              onEndTimeChanged: (t) => setState(() => malamEnd = t),
            ),
            const SizedBox(height: 16),
            _buildSleepTime(
              context,
              iconPath: 'assets/icons/sun-light.svg',
              name: 'Siang',
              startTime: siangStart,
              endTime: siangEnd,
              onStartTimeChanged: (t) => setState(() => siangStart = t),
              onEndTimeChanged: (t) => setState(() => siangEnd = t),
            ),
          ],
        ),
      ),
    );
  }

  // This is a reusable helper widget to create a compact checkbox with a label.
  // It's wrapped in an InkWell to make the text tappable as well.
  Widget _buildCheckboxOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8.0),
      child: Row(
        mainAxisSize:
            MainAxisSize.min, // Makes the Row only as wide as its children
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact, // Makes checkbox smaller
            // --- ADD THIS LINE ---
            // This removes the extra padding around the checkbox, making it tighter.
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(title),
          const SizedBox(width: 6), // Adds a little space after the text
        ],
      ),
    );
  }

  Widget _buildSleepTime(
    BuildContext context, {
    required String iconPath,
    required String name,
    required TimeOfDay? startTime,
    required TimeOfDay? endTime,
    required ValueChanged<TimeOfDay> onStartTimeChanged,
    required ValueChanged<TimeOfDay> onEndTimeChanged,
  }) {
    Future<void> _selectStart() async {
      final time = await showTimePickerBottomSheet(
        context,
        initialTime: startTime,
        title: 'Pilih Waktu Tidur $name',
      );
      if (time != null) onStartTimeChanged(time);
    }

    Future<void> _selectEnd() async {
      final time = await showTimePickerBottomSheet(
        context,
        initialTime: endTime,
        title: 'Pilih Waktu Bangun $name',
      );
      if (time != null) {
        if (startTime != null) {
          final startDate = DateTime(0, 1, 1, startTime.hour, startTime.minute);
          final endDate = DateTime(0, 1, 1, time.hour, time.minute);
          if (endDate.isBefore(startDate)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Waktu selesai harus setelah waktu mulai.'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        }
        onEndTimeChanged(time);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Tidur $name',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TimeField(
                title: 'Jam Tidur',
                value: startTime?.format(context) ?? '--:--',
                onTap: _selectStart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TimeField(
                title: 'Jam Bangun',
                value: endTime?.format(context) ?? '--:--',
                onTap: _selectEnd,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
