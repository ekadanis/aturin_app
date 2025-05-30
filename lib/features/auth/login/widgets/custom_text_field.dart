import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.obscureText,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: AppTheme.inputFieldColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14.sp,
          color: AppTheme.lightTextColor,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            size: 20.sp,
            color: AppTheme.lightSecondaryTextColor,
          ),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13.sp,
            color: AppTheme.lightSecondaryTextColor,
          ),
          filled: true,
          fillColor: AppTheme.inputFieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 1.5,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 2.h,
            horizontal: 4.w,
          ),
        ),
      ),
    );
  }
}