import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';

class CategoryModel {
  final int id;
  final String name;
  final CategoryType type;
  final String icon;
  final String color;
  final int? parentId;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.parentId,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: CategoryType.fromString(json['type'] as String),
      icon: json['icon'] as String,
      color: json['color'] as String,
      parentId: json['parent_id'] as int?,
      isSystem: json['is_system'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      type: type,
      icon: icon,
      color: color,
      parentId: parentId,
      isSystem: isSystem,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}