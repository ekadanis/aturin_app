import 'package:aturin_app/core/widgets/categories.dart';
import 'package:aturin_app/features/task/model/task_model.dart';

/// Helper class to convert between string categories and CategoryOption objects
class CategoryHelper {
  /// Get CategoryOption from task category string
  static CategoryOption getCategoryOptionFromString(String categoryString) {
    try {
      return categories.firstWhere(
        (category) => category.name.toLowerCase() == categoryString.toLowerCase(),
        orElse: () => categories.first, // Default to Akademik
      );
    } catch (e) {
      return categories.first; // Default to Akademik
    }
  }

  /// Get CategoryOption from TaskCategory enum
  static CategoryOption getCategoryOptionFromEnum(TaskCategory taskCategory) {
    final categoryName = taskCategory.displayName;
    return getCategoryOptionFromString(categoryName);
  }

  /// Convert CategoryOption to string for API compatibility
  static String getCategoryStringFromOption(CategoryOption categoryOption) {
    return categoryOption.name.toLowerCase();
  }

  /// Get TaskCategory enum from string
  static TaskCategory getTaskCategoryFromString(String categoryString) {
    try {
      return TaskCategory.values.firstWhere(
        (category) => category.displayName.toLowerCase() == categoryString.toLowerCase(),
        orElse: () => TaskCategory.akademik,
      );
    } catch (e) {
      return TaskCategory.akademik;
    }
  }

  /// Get TaskCategory enum from CategoryOption
  static TaskCategory getTaskCategoryFromOption(CategoryOption categoryOption) {
    return getTaskCategoryFromString(categoryOption.name);
  }
  /// Validate if a category string exists in available categories
  static bool isValidCategory(String categoryString) {
    return categories.any(
      (category) => category.name.toLowerCase() == categoryString.toLowerCase(),
    );
  }

  /// Get all available categories
  static List<CategoryOption> getAllCategories() {
    return categories;
  }

  /// Get category names as strings
  static List<String> getAllCategoryNames() {
    return categories.map((category) => category.name).toList();
  }
}
