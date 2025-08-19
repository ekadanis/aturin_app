import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RegisterAppBarWidget extends StatelessWidget {
  final VoidCallback onBackPressed;

  const RegisterAppBarWidget({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: AppTheme.lightTextColor,
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: 8.w,
              minHeight: 4.h,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Daftar Akun',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTextColor,
            ),
          ),
        ],
      ),
    );
  }
}