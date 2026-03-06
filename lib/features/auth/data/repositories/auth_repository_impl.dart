import 'package:pocketree/core/storage/token_storage.dart';
import 'package:pocketree/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pocketree/features/auth/domain/entities/user.dart';
import 'package:pocketree/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthRepositoryImpl(this.remoteDataSource, this.tokenStorage);

  @override
  Future<User> login({required String email, required String password}) async {
    final tokenModel = await remoteDataSource.login(
      email: email,
      password: password,
    );
    await tokenStorage.saveTokens(
      accessToken: tokenModel.accessToken,
      refreshToken: tokenModel.refreshToken,
    );
    final userModel = await remoteDataSource.getMe();
    return userModel.toEntity();
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
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
    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await tokenStorage.clearTokens();
  }

  @override
  Future<User> getCurrentUser() async {
    final userModel = await remoteDataSource.getMe();
    return userModel.toEntity();
  }
}
