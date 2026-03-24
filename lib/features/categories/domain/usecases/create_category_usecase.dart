import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/domain/repositories/category_repository.dart';

class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Either<Failure, Category>> call({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    int? parentId,
  }) {
    return repository.createCategory(
      name: name,
      type: type,
      icon: icon,
      color: color,
      parentId: parentId,
    );
  }
}