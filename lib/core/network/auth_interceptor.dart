import 'package:dio/dio.dart';
import 'package:pocketree/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  final Dio dio;

  AuthInterceptor({required this.tokenStorage, required this.dio});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await dio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
            options: Options(headers: {'Authorization': null}),
          );
          final newAccessToken = response.data['access_token'] as String;
          final newRefreshToken = response.data['refresh_token'] as String;
          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          await tokenStorage.clearTokens();
        }
      } else {
        await tokenStorage.clearTokens();
      }
    }
    handler.next(err);
  }
}
