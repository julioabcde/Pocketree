import 'package:dio/dio.dart';
import 'package:pocketree/core/config/app_config.dart';
import 'package:pocketree/core/network/auth_interceptor.dart';
import 'package:pocketree/core/storage/token_storage.dart';

class DioClient {
  static Dio create({required TokenStorage tokenStorage}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.getBaseUrl(),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (AppConfig.enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }

    dio.interceptors.add(
      AuthInterceptor(tokenStorage: tokenStorage, dio: dio),
    );

    return dio;
  }
}
