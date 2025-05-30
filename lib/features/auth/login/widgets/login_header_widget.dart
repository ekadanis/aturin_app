import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo/Illustration Section
        Center(
          child: Image.asset(
            'assets/images/login.png',
            height: 25.h,
            width: 70.w,
            fit: BoxFit.contain,
          ),
        ),
        
        SizedBox(height: 3.h),
        
        // Title Section
        Center(
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Masuk ke ',
                      style: TextStyle(color: AppTheme.lightTextColor),
                    ),
                    TextSpan(
                      text: 'Atur',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: 'in',
                      style: TextStyle(
                        color: AppTheme.lightTextColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.5.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Selamat datang kembali! Yuk atur harimu lagi.',
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