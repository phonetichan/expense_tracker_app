class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final String type;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
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
}