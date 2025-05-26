import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/core/widgets/categories.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03, // Setara dengan 3.w
        vertical: screenWidth * 0.01, // Setara dengan 0.8.h (approx)
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.7)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [          SvgPicture.asset(
            categoryOption.iconPath,
            width: screenWidth * 0.035, // Setara dengan 3.5.w
            height: screenWidth * 0.035, // Setara dengan 3.5.w
            colorFilter: ColorFilter.mode(categoryOption.textColor, BlendMode.srcIn),
          ),
          SizedBox(width: screenWidth * 0.01), // Setara dengan 1.w
          Text(
            categoryOption.name,
            style: TextStyle(
              fontSize: screenWidth * 0.033, // Setara dengan 3.3.w
              color: categoryOption.textColor,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}