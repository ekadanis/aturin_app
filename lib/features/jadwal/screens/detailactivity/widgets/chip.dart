import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

class CustomChip extends StatelessWidget {
  final String? iconPath;
  final String? label;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const CustomChip({
    Key? key,
    this.iconPath,
    this.label,
    this.foregroundColor,
    this.backgroundColor,
  }) : super(key: key);

  bool get isSvg => (iconPath ?? '').toLowerCase().contains('.svg');

  @override
  Widget build(BuildContext context) {
    final icon = iconPath;
    final fgColor = foregroundColor ?? Colors.black;
    final bgColor = backgroundColor ?? Colors.grey.shade300;
    final chipLabel = label ?? '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.25.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null && icon.isNotEmpty)
            isSvg
                ? SvgPicture.asset(
                  icon,
                  color: fgColor,
                  width: 5.w,
                  height: 5.w,
                )
                : Image.asset(
                  icon,
                  color: fgColor,
                  width: 5.5.w,
                  height: 5.5.w,
                ),
          if (chipLabel != null && chipLabel.isNotEmpty) SizedBox(width: 1.5.w),
          Text(
            chipLabel,
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
} 