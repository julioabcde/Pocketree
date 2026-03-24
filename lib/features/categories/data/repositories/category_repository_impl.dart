import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/error_mapper.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource remoteDatasource;

  CategoryRepositoryImpl(this.remoteDatasource);

  @override
  Future<Either<Failure, Category>> createCategory({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    int? parentId,
  }) async {
    try {
      final model = await remoteDatasource.createCategory(
        name: name,
        type: type,
        icon: icon,
        color: color,
        parentId: parentId,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories({
    CategoryType? type,
    int? parentId,
  }) async {
    try {
      final models = await remoteDatasource.getCategories(
        type: type,
        parentId: parentId,
      );
      return Right(models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, Category>> getCategoryById(int categoryId) async {
    try {
      final model = await remoteDatasource.getCategoryById(categoryId);
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, Category>> updateCategory({
    required int categoryId,
    String? name,
    String? icon,
    String? color,
  }) async {
    try {
      final model = await remoteDatasource.updateCategory(
        categoryId: categoryId,
        name: name,
        icon: icon,
        color: color,
      );
      return Right(model.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(int categoryId) async {
    try {
      await remoteDatasource.deleteCategory(categoryId);
      return const Right(null);
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}