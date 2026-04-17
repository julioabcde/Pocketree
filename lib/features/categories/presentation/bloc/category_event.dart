import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryDataRequested extends CategoryEvent {
  final CategoryType? type;

  const CategoryDataRequested({this.type});

  @override
  List<Object?> get props => [type];
}

class CategoryDataRefreshed extends CategoryEvent {
  final CategoryType? type;
  final Completer<void> completer;

  CategoryDataRefreshed({this.type, Completer<void>? completer})
      : completer = completer ?? Completer<void>();

  @override
  List<Object?> get props => [type];
}

class CategoryCreateRequested extends CategoryEvent {
  final String name;
  final CategoryType type;
  final String? icon;
  final String? color;
  final int? parentId;

  const CategoryCreateRequested({
    required this.name,
    required this.type,
    this.icon,
    this.color,
    this.parentId,
  });

  @override
  List<Object?> get props => [name, type, icon, color, parentId];
}

class CategoryUpdateRequested extends CategoryEvent {
  final int categoryId;
  final String? name;
  final String? icon;
  final String? color;

  const CategoryUpdateRequested({
    required this.categoryId,
    this.name,
    this.icon,
    this.color,
  });

  @override
  List<Object?> get props => [categoryId, name, icon, color];
}

class CategoryDeleteRequested extends CategoryEvent {
  final int categoryId;

  const CategoryDeleteRequested({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}