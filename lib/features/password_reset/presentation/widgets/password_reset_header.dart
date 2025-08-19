import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PasswordResetHeader extends StatelessWidget {
  const PasswordResetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Image.asset(
            'assets/images/password1.png',
            height: 25.h,
            width: 70.w,
            fit: BoxFit.contain,
          ),
        ),

        SizedBox(height: 3.h),

        Center(
          child: Column(
            children: [
              Text(
                'Lupa Kata Sandi?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.black,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),

              SizedBox(height: 1.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Text(
                  'Masukkan emailmu, biar bisa atur ulang kata sandi.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17.sp,
                    color: AppTheme.lightSecondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}