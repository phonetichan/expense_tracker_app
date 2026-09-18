
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/category_repository.dart';
import 'category_state.dart';

@singleton
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository repository;

  List<CategoryEntity> currentCategories = [];

  CategoryCubit(this.repository) : super(CategoryInitial());

  // void clear() {
  //   currentCategories = [];
  //   emit(const CategoryLoaded([]));
  // }

  Future<void> loadCategories({
    required String uid,
    required String type,
  }) async {
    try {
      final categories = await repository.getCategories(uid, type);

      currentCategories = categories;

      emit(CategoryLoaded(List.from(currentCategories)));
    } catch (e) {
      emit(CategoryError(e.toString()));
      rethrow;
    }
  }

  Future<void> loadAllCategories({
    required String uid,
  }) async {
    try {
      final categories = await repository.getAllCategories(uid);
      if (isClosed) return;
      currentCategories = categories;

      emit(CategoryLoaded(List.from(currentCategories)));
    } catch (e) {
      emit(CategoryError(e.toString()));
      rethrow;
    }
  }

  Future<void> addCategory({
    required String uid,
    required CategoryEntity category,
  }) async {
    try {
      await repository.addCategory(uid, category);

      await loadAllCategories(uid: uid);
    } catch (e) {
      emit(CategoryError(e.toString()));
      rethrow;
    }
  }

  Future<void> updateCategory({
    required String uid,
    required CategoryEntity category,
  }) async {
    try {
      await repository.updateCategory(uid, category);

      await loadAllCategories(uid: uid);
    } catch (e) {
      emit(CategoryError(e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCategory({
    required String uid,
    required String categoryId,
  }) async {
    try {
      await repository.deleteCategory(uid, categoryId);

      await loadAllCategories(uid: uid);
    } catch (e) {
      emit(CategoryError(e.toString()));
      rethrow;
    }
  }
}

