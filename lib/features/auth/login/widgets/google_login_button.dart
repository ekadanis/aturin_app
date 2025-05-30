import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class GoogleLoginButtonWidget extends StatelessWidget {
  final VoidCallback onGoogleLogin;

  const GoogleLoginButtonWidget({
    super.key,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      height: 6.h,
      child: ElevatedButton.icon(
        icon: Image.asset(
          'assets/icons/google.png',
          height: 3.h,
        ),
        label: Text(
          'Masuk dengan Google',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5F5F5),
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
        ),
        onPressed: onGoogleLogin,
      ),
    );
  }
}