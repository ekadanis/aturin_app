import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/core/widgets/categories.dart';

class CategoryTabsWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategoryTabsWidget({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildCategoryTab('Semua', true),
          ...categories.map(
            (category) => _buildCategoryTab(category.name, false),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String name, bool isAll) {
    final isSelected = selectedCategory == name;
    final category = isAll ? null : categories.firstWhere((c) => c.name == name);
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

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onCategoryChanged(name),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              ],
              Text(
                name,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}