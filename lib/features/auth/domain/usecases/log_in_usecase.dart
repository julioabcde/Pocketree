import 'package:pocketree/features/auth/domain/entities/user.dart';
import 'package:pocketree/features/auth/domain/repositories/auth_repository.dart';

class LogInUseCase {
  final AuthRepository repository;

  LogInUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }){
    return repository.login(
      email: email,
      password: password,
    );
  }
}