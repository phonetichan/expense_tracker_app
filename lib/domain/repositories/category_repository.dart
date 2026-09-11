import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<void> createDefaultCategories(String uid);
  Future<List<CategoryEntity>> getCategories(String uid, String type);
  Future<List<CategoryEntity>> getAllCategories(String uid);
  Future<void> addCategory(String uid, CategoryEntity category);
  Future<void> updateCategory(String uid, CategoryEntity category);
  Future<void> deleteCategory(String uid, String categoryId);
}
