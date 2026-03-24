import 'package:equatable/equatable.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final CategoryType? activeFilter;
  final bool isPerformingAction;

  const CategoryLoaded({
    required this.categories,
    this.activeFilter,
    this.isPerformingAction = false,
  });

  List<Category> get incomeCategories =>
      categories.where((c) => c.type == CategoryType.income).toList();

  List<Category> get expenseCategories =>
      categories.where((c) => c.type == CategoryType.expense).toList();

  List<Category> get systemCategories =>
      categories.where((c) => c.isSystem).toList();

  List<Category> get userCategories =>
      categories.where((c) => !c.isSystem).toList();

  List<Category> getSubcategories(int parentId) =>
      categories.where((c) => c.parentId == parentId).toList();

  CategoryLoaded copyWith({
    List<Category>? categories,
    CategoryType? activeFilter,
    bool? isPerformingAction,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      activeFilter: activeFilter ?? this.activeFilter,
      isPerformingAction: isPerformingAction ?? this.isPerformingAction,
    );
  }

  @override
  List<Object?> get props => [categories, activeFilter, isPerformingAction];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryActionSuccess extends CategoryState {
  final String message;

  const CategoryActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}