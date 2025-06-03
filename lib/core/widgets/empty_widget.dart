import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
class EmptyWidget extends StatelessWidget {
  final String? message;

  const EmptyWidget({super.key, this.message});
  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
          SizedBox(height: 5.h),
        Image.asset(
          'assets/images/https___lottiefiles.com_animations_no-data-bt8EDsKmcr.gif',
          height: 150,
          color: AppTheme.primaryColor,
        ),

        Text(
          message ?? 'Tidak ada tugas hari ini.',
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