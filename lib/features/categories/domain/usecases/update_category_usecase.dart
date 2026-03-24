import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, Category>> call({
    required int categoryId,
    String? name,
    String? icon,
    String? color,
  }) {
    return repository.updateCategory(
      categoryId: categoryId,
      name: name,
      icon: icon,
      color: color,
    );
  }
}