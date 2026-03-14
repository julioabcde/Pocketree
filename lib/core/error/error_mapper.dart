import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/exceptions.dart';
import 'package:pocketree/core/error/failures.dart';

Left<Failure, T> mapExceptionToFailure<T>(Object exception) {
  if (exception is! AppException) {
    return Left(ServerFailure(exception.toString()));
  }

  return switch (exception) {
    ServerException e       => Left(ServerFailure(e.message, statusCode: e.statusCode)),
    NetworkException e      => Left(NetworkFailure(e.message)),
    UnauthorizedException _ => Left(const UnauthorizedFailure()),
  };
}