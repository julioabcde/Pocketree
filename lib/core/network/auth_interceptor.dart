import 'package:dio/dio.dart';
import 'package:pocketree/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;

  /// Used only for POST /auth/refresh — has NO interceptors to avoid recursive loops.
  final Dio _refreshDio;

  /// The main Dio instance (with interceptors) used to retry the original request.
  final Dio _dio;

  AuthInterceptor({
    required this.tokenStorage,
    required Dio refreshDio,
    required Dio dio,
  })  : _refreshDio = refreshDio,
        _dio = dio;

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
    if (err.requestOptions.extra['retried'] == true) {
      await tokenStorage.clearTokens();
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await _refreshDio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );
          final newAccessToken = response.data['access_token'] as String;
          final newRefreshToken = response.data['refresh_token'] as String;
          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          final retryResponse = await _dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: Options(
              method: err.requestOptions.method,
              headers: {
                ...err.requestOptions.headers,
                'Authorization': 'Bearer $newAccessToken',
              },
              extra: {...err.requestOptions.extra, 'retried': true},
            ),
          );
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
