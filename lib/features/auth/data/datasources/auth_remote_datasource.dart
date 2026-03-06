import 'package:dio/dio.dart';
import 'package:pocketree/core/error/exceptions.dart';
import 'package:pocketree/features/auth/data/models/auth_token_model.dart';
import 'package:pocketree/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  });

  Future<AuthTokenModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<AuthTokenModel> refreshToken({required String refreshToken});

  Future<UserModel> getMe();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasourceImpl(this.dio);

  @override
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<AuthTokenModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<AuthTokenModel> refreshToken({required String refreshToken}) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return AuthTokenModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      throw const UnauthorizedException();
    } else if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException(message: e.message ?? 'Network error');
    } else {
      throw ServerException(
        message: e.toString(),
        statusCode: e.response?.statusCode,
      );
    }
  }
}