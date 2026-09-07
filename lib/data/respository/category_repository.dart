import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/default_categories.dart';
import '../model/category_model.dart';

@lazySingleton
class CategoryRepository {
  final FirebaseFirestore firestore;

  CategoryRepository({required this.firestore});

  Future<void> createDefaultCategories(String uid) async {
    try {
      print('Starting category creation for UID: $uid');

      final categoriesRef = firestore
          .collection('users')
          .doc(uid)
          .collection('categories');

      final batch = firestore.batch();

      for (final category in DefaultCategories.categories) {
        print(
          'Adding category: ${category.id} '
          '(${category.name}) '
          '[${category.type}]',
        );

        final docRef = categoriesRef.doc(category.id);

        batch.set(docRef, category.toMap());
      }

      print('Committing ${DefaultCategories.categories.length} categories...');

      await batch.commit();

      print('Firestore category batch committed successfully');
    } catch (e, stackTrace) {
      print('Failed to create default categories');
      print('Error: $e');
      print('StackTrace: $stackTrace');

      rethrow;
    }
  }

  Future<List<CategoryModel>> getCategories(String uid, String type) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .where('type', isEqualTo: type)
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<CategoryModel>> getAllCategories(String uid) async {
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> addCategory(String uid, CategoryModel category) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .add(category.toMap());
  }

  Future<void> updateCategory(String uid, CategoryModel category) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String uid, String categoryId) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }
}
