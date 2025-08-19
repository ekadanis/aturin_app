import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';

class GoogleLoginButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const GoogleLoginButtonWidget({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: 6.h,
      child: ElevatedButton.icon(
        icon:
            isLoading
                ? SizedBox(
                  width: 3.h,
                  height: 3.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                  ),
                )
                : Image.asset('assets/icons/google.png', height: 3.h),
        label: Text(
          'Masuk dengan Google',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isLoading ? Colors.black54 : Colors.black87,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLoading ? Colors.grey[200] : const Color(0xFFF5F5F5),
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          elevation: isLoading ? 0 : 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}
