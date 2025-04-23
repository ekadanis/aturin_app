import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'categories.dart';

class CategoryPickerScreen extends StatelessWidget {
  final String selectedCategory;

  const CategoryPickerScreen({super.key, required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kategori')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.name == selectedCategory;

          return GestureDetector(
            onTap: () => Navigator.pop(context, category.name),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? category.color : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    category.iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(category.color, BlendMode.srcIn),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check, color: category.color)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
