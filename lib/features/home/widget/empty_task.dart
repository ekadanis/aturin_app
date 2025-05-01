import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
class EmptyTask extends StatelessWidget {
  const EmptyTask({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
          SizedBox(height: 20.h),
        Image.asset(
          'assets/images/https___lottiefiles.com_animations_no-data-bt8EDsKmcr.gif',
          height: 150,
          color: AppTheme.primaryColor,
        ),

        Text(
          'Yuk, tambahkan tugas pertama kamu!',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}