import 'package:pocketree/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pocketree/features/auth/domain/entities/user.dart';
import 'package:pocketree/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<User> login({required String email, required String password}) async {
    final userModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    // implement later
    throw UnimplementedError();
  }
}
