import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/default_categories.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../model/category_model.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore firestore;

  CategoryRepositoryImpl({required this.firestore});

  @override
  Future<void> createDefaultCategories(String uid) async {
    try {
      final categoriesRef = firestore
          .collection('users')
          .doc(uid)
          .collection('categories');

      final batch = firestore.batch();

      for (final category in DefaultCategories.categories) {
        final docRef = categoriesRef.doc(category.id);
        batch.set(docRef, category.toMap());
      }

      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories(String uid, String type) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .where('type', isEqualTo: type)
        .get();

    return snapshot.docs
        .map<CategoryEntity>((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<List<CategoryEntity>> getAllCategories(String uid) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .get();

    return snapshot.docs
        .map<CategoryEntity>((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  @override
  Future<void> addCategory(String uid, CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .add(model.toMap());
  }

  @override
  Future<void> updateCategory(String uid, CategoryEntity category) async {
    final model = CategoryModel.fromEntity(category);
    await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(model.id)
        .update(model.toMap());
  }

  @override
  Future<void> deleteCategory(String uid, String categoryId) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }
}
