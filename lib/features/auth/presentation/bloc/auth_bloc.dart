import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/log_in_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/log_out_usecase.dart';
import 'package:pocketree/features/auth/domain/usecases/register_usecase.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_event.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LogInUseCase logIn;
  final LogOutUseCase logOut;
  final RegisterUseCase register;
  final GetCurrentUserUseCase getCurrentUser;

  AuthBloc({
    required this.logIn,
    required this.logOut,
    required this.register,
    required this.getCurrentUser,
  }) : super(const AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await getCurrentUser();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await logIn(email: event.email, password: event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await logOut();
    } catch (_) {
      // Clear local session even if server call fails
    }
    emit(const AuthUnauthenticated());
  }
}