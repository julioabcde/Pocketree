import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';

abstract class CategoryRepository {
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    int? parentId,
  });

  Future<Either<Failure, List<Category>>> getCategories({
    CategoryType? type,
    int? parentId,
  });

  Future<Either<Failure, Category>> getCategoryById(int categoryId);

  Future<Either<Failure, Category>> updateCategory({
    required int categoryId,
    String? name,
    String? icon,
    String? color,
  });

  Future<Either<Failure, void>> deleteCategory(int categoryId);
}