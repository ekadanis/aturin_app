import 'package:flutter/material.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/category_picker_screen.dart';
import 'package:aturin_app/features/jadwal/screens/add_aktivitas/widgets/form_field_widgets.dart';
import 'package:aturin_app/core/widgets/categories.dart';

class CategorySelectionSection extends StatelessWidget {
  final CategoryOption? selectedCategory;
  final String? categoryError;
  final Function(CategoryOption) onCategoryChanged;

  const CategorySelectionSection({
    super.key,
    required this.selectedCategory,
    required this.categoryError,
    required this.onCategoryChanged,
  });
  Future<void> _onCategoryTap(BuildContext context) async {
    print('DEBUG: Opening category picker, selectedCategory: ${selectedCategory?.name ?? 'NULL'}');
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryPickerScreen(
          selectedCategory: selectedCategory?.name ?? '',
        ),
      ),
    );

    print('DEBUG: Category picker returned: $selected');
    if (selected != null) {
      final category = categories.firstWhere((c) => c.name == selected);
      onCategoryChanged(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CategorySelectionField(
      selectedCategoryName: selectedCategory?.name,
      onTap: () => _onCategoryTap(context),
      errorText: categoryError,
    );
  }
}