import 'package:aturin_app/shared/core/constant/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/shared//utils/category_helper.dart';

class CategoryTabsWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryTabsWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });  @override
  Widget build(BuildContext context) {
    final availableCategories = CategoryHelper.getAllCategories();
    
    final allTabs = ['Semua', ...availableCategories.map((c) => c.name)];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // This padding now controls the space at the very beginning and end.
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8.0),
      child: Row(
        children: [
          for (int i = 0; i < allTabs.length; i++) ...[
            // Build the tab
            _buildCategoryTab(allTabs[i], allTabs[i] == 'Semua'),
            
            // Add spacing AFTER the tab, but NOT for the last one
            if (i < allTabs.length - 1)
              const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }  Widget _buildCategoryTab(String name, bool isAll) {
    final isSelected = selectedCategory == name;
    final category = isAll ? null : CategoryHelper.getCategoryOptionFromString(name);
    Color textColor;
    Color backgroundColor;

    if (isSelected) {
      backgroundColor = AppTheme.selectedTabBackground;
      textColor = AppTheme.selectedTabTextColor;
    } else {
      if (isAll) {
        textColor = AppTheme.allCategoryText;
        backgroundColor = AppTheme.allCategoryBackground;
      } else if (category != null) {
        textColor = category.textColor;
        backgroundColor = category.backgroundColor;
      } else {
        textColor = AppTheme.lightTextColor;
        backgroundColor = Colors.grey[100]!;
      }
    }

    return GestureDetector(
      onTap: () => onCategoryChanged(name),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isAll && category != null) ...[
              SvgPicture.asset(
                category.iconPath,
                width: 16,
                height: 16,
                colorFilter: ColorFilter.mode(textColor, BlendMode.srcIn),
              ),
              const SizedBox(width: 4),
            ],              Text(
              name,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),],
        ),
      ),
    );
  }
}