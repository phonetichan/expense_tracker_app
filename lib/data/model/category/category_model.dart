import '../../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'type': type,
    };
  }

  factory CategoryModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      type: map['type'] ?? 'expense',
    );
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      icon: entity.icon,
      type: entity.type,
    );
  }
}
