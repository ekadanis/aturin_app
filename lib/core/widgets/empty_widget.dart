import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
class EmptyWidget extends StatelessWidget {
  final String? message;

  const EmptyWidget({super.key, this.message});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 5.h),
        Lottie.asset(
          'assets/icons/NoData.json',
          height: 25.h,
          width: 60.w,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
        ),
        //SizedBox(height: 0.1.h),
        Text(
          message ?? 'Tidak ada tugas hari ini.',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.h),
      ],
    );
  }
}