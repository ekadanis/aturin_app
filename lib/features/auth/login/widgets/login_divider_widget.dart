import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class LoginDividerWidget extends StatelessWidget {
  const LoginDividerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppTheme.lightDividerColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Text(
            'atau',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.sp,
              color: AppTheme.lightSecondaryTextColor,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppTheme.lightDividerColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}