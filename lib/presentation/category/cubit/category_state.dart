import '../../../domain/entities/category_entity.dart';

abstract class CategoryState {
  const CategoryState();
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryLoading(this.categories);
}

class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;

  const CategoryLoaded(this.categories);
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);
}
