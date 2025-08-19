
import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RegisterLinkWidget extends StatelessWidget {
  final VoidCallback onRegisterTap;

  const RegisterLinkWidget({
    super.key,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Belum punya akun? Yuk langsung ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.sp,
              color: AppTheme.lightSecondaryTextColor,
            ),
          ),
          GestureDetector(
            onTap: onRegisterTap,
            child: Text(
              'Daftar',
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