import 'package:equatable/equatable.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';

class Category extends Equatable {
  final int id;
  final String name;
  final CategoryType type;
  final String icon;
  final String color;
  final int? parentId;
  final bool isSystem;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
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

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    icon,
    color,
    parentId,
    isSystem,
    createdAt,
    updatedAt,
  ];
}
