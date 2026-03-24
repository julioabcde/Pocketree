import 'package:dio/dio.dart';
import 'package:pocketree/core/error/dio_error_handler.dart';
import 'package:pocketree/features/categories/data/models/category_model.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';

abstract class CategoryRemoteDatasource {
  Future<CategoryModel> createCategory({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    int? parentId,
  });

  Future<List<CategoryModel>> getCategories({
    CategoryType? type,
    int? parentId,
  });

  Future<CategoryModel> getCategoryById(int categoryId);

  Future<CategoryModel> updateCategory({
    required int categoryId,
    String? name,
    String? icon,
    String? color,
  });

  Future<void> deleteCategory(int categoryId);
}

class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final Dio dio;

  CategoryRemoteDatasourceImpl(this.dio);

  @override
  Future<CategoryModel> createCategory({
    required String name,
    required CategoryType type,
    String? icon,
    String? color,
    int? parentId,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'type': type.value,
      };

      if (icon != null) data['icon'] = icon;
      if (color != null) data['color'] = color;
      if (parentId != null) data['parent_id'] = parentId;

      final response = await dio.post('/categories', data: data);
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories({
    CategoryType? type,
    int? parentId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (type != null) queryParams['type'] = type.value;
      if (parentId != null) queryParams['parent_id'] = parentId;

      final response = await dio.get(
        '/categories',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final list = response.data as List<dynamic>;
      return list
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> getCategoryById(int categoryId) async {
    try {
      final response = await dio.get('/categories/$categoryId');
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> updateCategory({
    required int categoryId,
    String? name,
    String? icon,
    String? color,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (icon != null) data['icon'] = icon;
      if (color != null) data['color'] = color;

      final response = await dio.put('/categories/$categoryId', data: data);
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      handleDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(int categoryId) async {
    try {
      await dio.delete('/categories/$categoryId');
    } on DioException catch (e) {
      handleDioError(e);
    }
  }
}