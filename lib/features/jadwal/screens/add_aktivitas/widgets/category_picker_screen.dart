import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aturin_app/core/theme/app_theme.dart';
import 'package:aturin_app/core/widgets/categories.dart';

class CategoryPickerScreen extends StatelessWidget {
  final String selectedCategory;

  const CategoryPickerScreen({super.key, required this.selectedCategory});
  @override
  Widget build(BuildContext context) {
    print('DEBUG: CategoryPickerScreen opened with selectedCategory: "$selectedCategory"');
    print('DEBUG: selectedCategory.isEmpty: ${selectedCategory.isEmpty}');
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pilih Kategori'),
        backgroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.name == selectedCategory;
          
          if (index == 0) {
            print('DEBUG: First category "${category.name}" isSelected: $isSelected (category.name == selectedCategory: ${category.name == selectedCategory})');
          }

          return GestureDetector(
            onTap: () => Navigator.pop(context, category.name),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    category.iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      category.textColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, color: AppTheme.primaryColor),
                ],
              ),
            ),
          );
        },
      ),    );
  }
}

