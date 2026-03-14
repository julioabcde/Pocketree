import 'package:dartz/dartz.dart';
import 'package:pocketree/core/error/error_mapper.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/core/storage/token_storage.dart';
import 'package:pocketree/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pocketree/features/auth/domain/entities/user.dart';
import 'package:pocketree/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokenModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      await tokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      final userModel = await remoteDataSource.getMe();
      return Right(userModel.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final tokenModel = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      await tokenStorage.saveTokens(
        accessToken: tokenModel.accessToken,
        refreshToken: tokenModel.refreshToken,
      );
      final userModel = await remoteDataSource.getMe();
      return Right(userModel.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await tokenStorage.clearTokens();
      return const Right(null);
    } catch (e) {
      await tokenStorage.clearTokens();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getMe();
      return Right(userModel.toEntity());
    } catch (e) {
      return mapExceptionToFailure(e);
    }
  }
}