// lib/widgets/task_description.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';

class TaskDescription extends StatelessWidget {
  final String taskName;
  
  const TaskDescription({
    Key? key,
    required this.taskName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Satu tugas beres, Satu beban hilang!",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 3.8.w, // Responsive - approximately 14-16sp on most devices
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 5.w, // Responsive quotation marks
                color: AppTheme.primaryColor,
              ),
            ),
            Flexible(
              child: Text(
                taskName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 5.w,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Text(
              '"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 5.w,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}