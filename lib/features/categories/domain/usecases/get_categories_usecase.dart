import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call({
    CategoryType? type,
    int? parentId,
  }) {
    return repository.getCategories(
      type: type,
      parentId: parentId,
    );
  }
}