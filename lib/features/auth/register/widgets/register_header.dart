import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RegisterHeaderWidget extends StatelessWidget {
  const RegisterHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Illustration Section
        Center(
          child: Image.asset(
            'assets/images/register2.png',
            height: 18.h,
            width: 60.w,
            fit: BoxFit.contain,
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Title Section
        Center(
          child: Column(
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  children: const [
                    TextSpan(
                      text: 'Daftar ke ',
                      style: TextStyle(color: AppTheme.lightTextColor),
                    ),
                    TextSpan(
                      text: 'Atur',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    TextSpan(
                      text: 'in',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppTheme.lightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'Aturin siap bantu kamu, yuk mulai sekarang!',
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