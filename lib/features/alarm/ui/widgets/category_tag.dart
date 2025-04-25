// lib/widgets/category_tag.dart
import 'package:flutter/material.dart';

class CategoryTag extends StatelessWidget {
  final String category;
  final IconData icon;
  
  const CategoryTag({
    Key? key,
    required this.category,
    this.icon = Icons.videogame_asset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.shade200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.purple,
          ),
          const SizedBox(width: 6),
          Text(
            category,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}