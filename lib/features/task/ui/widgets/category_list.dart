import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/categories.dart';

class CategoryListTile extends StatelessWidget {
  final CategoryOption category;
  final VoidCallback onTap;

  const CategoryListTile({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Kategori'),
      subtitle: Text(category.name),
      leading: SvgPicture.asset(
        category.iconPath,
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(category.color, BlendMode.srcIn),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
