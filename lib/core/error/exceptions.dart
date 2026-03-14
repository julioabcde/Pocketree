sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException({required String message, this.statusCode})
    : super(message);
}

class NetworkException extends AppException {
  const NetworkException({required String message})
    : super(message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('Unauthorized');
}
