import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class LoginLinkWidget extends StatelessWidget {
  final VoidCallback onLoginTap;

  const LoginLinkWidget({
    super.key,
    required this.onLoginTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Sudah punya akun? Yuk langsung ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppTheme.lightSecondaryTextColor,
            ),
          ),
          GestureDetector(
            onTap: onLoginTap,
            child: Text(
              'Masuk',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.sp,
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}