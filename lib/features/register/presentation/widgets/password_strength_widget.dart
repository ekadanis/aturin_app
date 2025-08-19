import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class PasswordStrengthWidget extends StatelessWidget {
  final double strengthValue;
  final bool hasUppercase;
  final bool hasSymbol;
  final bool hasMinLength;
  final bool noSpaces;
  final bool isNotEmpty;

  const PasswordStrengthWidget({
    super.key,
    required this.strengthValue,
    required this.hasUppercase,
    required this.hasSymbol,
    required this.hasMinLength,
    required this.noSpaces,
    required this.isNotEmpty,
  });

  String get strengthLabel {
    if (strengthValue <= 0.4) return "Lemah";
    if (strengthValue <= 0.7) return "Sedang";
    if (strengthValue <= 0.99) return "Baik";
    return "Kuat";
  }

  Color get strengthColor {
    if (strengthValue <= 0.4) return AppTheme.weakPasswordColor;
    if (strengthValue <= 0.7) return AppTheme.mediumPasswordColor;
    if (strengthValue <= 0.99) return AppTheme.goodPasswordColor;
    return AppTheme.strongPasswordColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSegmentedProgressIndicator(),
        SizedBox(height: 0.5.h),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            strengthLabel,
            style: GoogleFonts.plusJakartaSans(
              color: strengthColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 1.h,
          children: [
            _buildCriteria('8+ karakter', hasMinLength),
            _buildCriteria('huruf besar (A–Z)', hasUppercase),
            _buildCriteria('simbol (!@#...)', hasSymbol),
            _buildCriteria('tanpa spasi', noSpaces),
            _buildCriteria('tidak boleh kosong', isNotEmpty),
          ],
        ),
      ],
    );
  }

  Widget _buildSegmentedProgressIndicator() {
    int totalSegments = 4;
    double segmentValue = 1.0 / totalSegments;

    return Row(
      children: List.generate(totalSegments, (index) {
        bool isFilled = strengthValue >= (segmentValue * (index + 1));
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0.5.w),
            height: 0.6.h,
            decoration: BoxDecoration(
              color: isFilled ? strengthColor : AppTheme.lightDividerColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCriteria(String text, bool passed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.circle_outlined,
          color: passed ? AppTheme.successColor : AppTheme.lightSecondaryTextColor,
          size: 16.sp,
        ),
        SizedBox(width: 1.w),
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.sp,
            color: passed ? AppTheme.lightTextColor : AppTheme.lightSecondaryTextColor,
            fontWeight: passed ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}