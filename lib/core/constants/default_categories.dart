import '../../data/model/category/category_model.dart';

class DefaultCategories {
  static final List<CategoryModel> categories = [
    CategoryModel(
      id: 'food',
      name: 'Food',
      icon: 'restaurant',
      type: 'expense',
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      icon: 'directions_car',
      type: 'expense',
    ),
    CategoryModel(
      id: 'salary',
      name: 'Salary',
      icon: 'payments',
      type: 'income',
    ),
  ];
}