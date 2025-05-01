import 'package:flutter/material.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:slider_button/slider_button.dart';

class CancelSliderButton extends StatelessWidget {
  final String text;
  final String description;
  final VoidCallback? onCancelled;

  const CancelSliderButton({
    Key? key,
    required this.text,
    required this.description,
    this.onCancelled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 15.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SliderButton(
            action: () async {
              if (onCancelled != null) {
                onCancelled!();
              }
              return true;
            },
            label: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 4.w,
                letterSpacing: 0.5,
              ),
            ),
            icon: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF5263F3),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 5.w,
              ),
            ),
            width: 80.w,
            radius: 100,
            buttonColor: Color(0xFF5263F3),
            backgroundColor: Color(0xFFA3BBFE),
            highlightedColor: Colors.white.withOpacity(0.3),
            baseColor: Colors.white,
            vibrationFlag: true,
            //smissible: true,
            shimmer: true,
            height: 14.w,
            buttonSize: 12.w,
            disable: false,
          ),
        ),
        SizedBox(height: 1.5.h),
        Text(
          description,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.lightSecondaryTextColor,
            fontSize: 3.w,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}