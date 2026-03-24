import 'package:dio/dio.dart';
import 'package:pocketree/core/error/exceptions.dart';

String? extractErrorDetail(dynamic responseData) {
  if (responseData is! Map<String, dynamic>) return null;

  final detail = responseData['detail'];

  if (detail is String) return detail;

  if (detail is List && detail.isNotEmpty) {
    final firstError = detail.first;
    if (firstError is Map<String, dynamic>) {
      final msg = firstError['msg'];
      if (msg is String) return msg;
    }
  }

  return null;
}

Never handleDioError(DioException e) {
  if (e.response?.statusCode == 401) {
    throw const UnauthorizedException();
  }

  final detail = extractErrorDetail(e.response?.data);

  switch (e.response?.statusCode) {
    case 400:
      throw ServerException(
        message: detail ?? 'Invalid request',
        statusCode: 400,
      );
    case 403:
      throw ServerException(
        message: detail ?? 'You don\'t have permission to perform this action',
        statusCode: 403,
      );
    case 404:
      throw ServerException(
        message: detail ?? 'Resource not found',
        statusCode: 404,
      );
    case 409:
      throw ServerException(
        message: detail ?? 'Resource already exists',
        statusCode: 409,
      );
    case 422:
      throw ServerException(
        message: detail ?? 'Invalid data provided',
        statusCode: 422,
      );
    default:
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException(message: e.message ?? 'Network error');
      }
      throw ServerException(
        message: detail ?? e.toString(),
        statusCode: e.response?.statusCode,
      );
  }
}