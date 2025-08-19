// lib/widgets/task_description.dart
import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskDescription extends StatelessWidget {
  final String taskName;
  
  const TaskDescription({
    Key? key,
    required this.taskName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Column(
      children: [
        Text(
          "Satu hal beres, Satu beban pun hilang!",
          style: GoogleFonts.plusJakartaSans(
            fontSize: screenWidth * 0.038, // Setara dengan 3.8.w
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: screenWidth * 0.02), // Setara dengan 1.h (perkiraan)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: screenWidth * 0.05, // Setara dengan 5.w
                color: AppTheme.primaryColor,
              ),
            ),
            Flexible(
              child: Text(
                taskName,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: screenWidth * 0.05, // Setara dengan 5.w
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Text(
              '',
              style: GoogleFonts.plusJakartaSans(
                fontSize: screenWidth * 0.05, // Setara dengan 5.w
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}