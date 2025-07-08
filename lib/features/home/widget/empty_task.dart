import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
class EmptyTaskAndAciivty extends StatelessWidget {
  final String? message;
  
  const EmptyTaskAndAciivty({super.key, this.message});
  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        //  SizedBox(height: 5.h),
        Lottie.asset(
          'assets/icons/NoData.json',
          height: 150,
          width: 150,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
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