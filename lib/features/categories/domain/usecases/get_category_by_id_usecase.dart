import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/repositories/category_repository.dart';

class GetCategoryByIdUseCase {
  final CategoryRepository repository;

  GetCategoryByIdUseCase(this.repository);

  Future<Either<Failure, Category>> call(int categoryId) {
    return repository.getCategoryById(categoryId);
  }
}