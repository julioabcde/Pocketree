import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:pocketree/features/home/presentation/bloc/home_event.dart';
import 'package:pocketree/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase getHomeData;

  HomeBloc({required this.getHomeData}) : super(const HomeInitial()) {
    on<HomeDataRequested>(_onHomeDataRequested);
    on<HomeDataRefreshed>(_onHomeDataRefreshed);
  }

  Future<void> _onHomeDataRequested(
    HomeDataRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final result = await getHomeData();
    result.fold(
      (failure) => emit(HomeError(_mapFailureToMessage(failure))),
      (data) => emit(HomeLoaded(data)),
    );
  }

  Future<void> _onHomeDataRefreshed(
    HomeDataRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    final result = await getHomeData();
    result.fold(
      (failure) => emit(HomeError(_mapFailureToMessage(failure))),
      (data) => emit(HomeLoaded(data)),
    );
    event.completer.complete();
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      ServerFailure f => f.message,
      NetworkFailure _ =>
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      UnauthorizedFailure _ => failure.message,
      CacheFailure _ => 'Terjadi kesalahan lokal. Silakan coba lagi.',
    };
  }
}
