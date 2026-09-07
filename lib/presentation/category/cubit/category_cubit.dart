import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/model/category_model.dart';
import '../../../data/respository/category_repository.dart';
import 'category_state.dart';

@injectable
class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository repository;
  List<CategoryModel> currentCategories = [];

  CategoryCubit(this.repository) : super(CategoryInitial());

  Future<void> loadCategories({
    required String uid,
    required String type,
  }) async {
    emit(CategoryLoading(currentCategories));

    try {
      final categories = await repository.getCategories(
        uid,
        type,
      );

      currentCategories = categories;

      emit(
        CategoryLoaded(currentCategories),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> loadAllCategories({
    required String uid,
  }) async {
    emit(CategoryLoading(currentCategories));

    try {
      final categories = await repository.getAllCategories(uid);

      currentCategories = categories;

      emit(
        CategoryLoaded(currentCategories),
      );
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> addCategory({
    required String uid,
    required CategoryModel category,
  }) async {
    try {
      await repository.addCategory(uid, category);

      await loadAllCategories(uid: uid);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory({
    required String uid,
    required CategoryModel category,
  }) async {
    try {
      await repository.updateCategory(uid, category);

      await loadAllCategories(uid: uid);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory({
    required String uid,
    required String categoryId,
    required String type,
  }) async {
    try {
      await repository.deleteCategory(
        uid,
        categoryId,
      );

      await loadAllCategories(uid: uid);
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}