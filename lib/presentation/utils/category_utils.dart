import '../../domain/entities/category_entity.dart';

class CategoryUtils {
  /// Matches a transaction's categoryId with the provided CategoryEntity list.
  static CategoryEntity? findCategoryById(
    List<CategoryEntity> categories,
    String? categoryId,
  ) {
    if (categoryId == null) return null;
    try {
      return categories.firstWhere((category) => category.id == categoryId);
    } catch (_) {
      return null;
    }
  }
}