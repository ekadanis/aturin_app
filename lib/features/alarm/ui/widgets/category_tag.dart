import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:aturin_app/features/task/ui/screens/categories.dart';
import 'package:aturin_app/features/alarm/services/alarm_service.dart';
import 'package:aturin_app/core/theme/app_theme.dart';

class CategoryTag extends StatelessWidget {
  final String category;
  
  const CategoryTag({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alarmService = AlarmService();
    final CategoryOption categoryOption = alarmService.getCategoryOption(category);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 0.8.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            categoryOption.iconPath,
            width: 3.5.w,
            height: 3.5.w,
          ),
          SizedBox(width: 1.w),
          Text(
            categoryOption.name,
            style: TextStyle(
              fontSize: 3.3.w,
              color: categoryOption.color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}