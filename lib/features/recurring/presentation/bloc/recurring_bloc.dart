import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/recurring/domain/usecases/create_recurring_usecase.dart';
import 'package:pocketree/features/recurring/domain/usecases/delete_recurring_usecase.dart';
import 'package:pocketree/features/recurring/domain/usecases/execute_recurring_usecase.dart';
import 'package:pocketree/features/recurring/domain/usecases/get_recurring_usecase.dart';
import 'package:pocketree/features/recurring/domain/usecases/update_recurring_usecase.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_state.dart';

class RecurringBloc extends Bloc<RecurringEvent, RecurringState> {
  final GetRecurringUseCase getRecurring;
  final DeleteRecurringUseCase deleteRecurring;
  final CreateRecurringUseCase createRecurring;
  final UpdateRecurringUseCase updateRecurring;
  final ExecuteRecurringUseCase executeRecurring;

  RecurringBloc({
    required this.getRecurring,
    required this.deleteRecurring,
    required this.createRecurring,
    required this.updateRecurring,
    required this.executeRecurring,
  }) : super(const RecurringInitial()) {
    on<RecurringDataRequested>(_onDataRequested);
    on<RecurringDeleteRequested>(_onDeleteRequested);
    on<RecurringCreateRequested>(_onCreateRequested);
    on<RecurringExecuteRequested>(_onExecuteRequested);
    on<RecurringActivateRequested>(_onActivateRequested);
    on<RecurringUpdateRequested>(_onUpdateRequested);
  }

  Future<void> _onDataRequested(
    RecurringDataRequested event,
    Emitter<RecurringState> emit,
  ) async {
    if (state is! RecurringLoaded) emit(const RecurringLoading());

    final result = await getRecurring();
    result.fold(
      (failure) => emit(RecurringError(_mapFailure(failure))),
      (items) => emit(RecurringLoaded(items)),
    );
  }

  Future<void> _onDeleteRequested(
    RecurringDeleteRequested event,
    Emitter<RecurringState> emit,
  ) async {
    final result = await deleteRecurring(event.recurringId);
    result.fold(
      (failure) => emit(RecurringError(_mapFailure(failure))),
      (_) {
        emit(const RecurringActionSuccess('Subscription dinonaktifkan'));
        add(const RecurringDataRequested());
      },
    );
  }

  Future<void> _onCreateRequested(
    RecurringCreateRequested event,
    Emitter<RecurringState> emit,
  ) async {
    final result = await createRecurring(
      accountId: event.accountId,
      type: event.type,
      amount: event.amount,
      frequency: event.frequency,
      startDate: event.startDate,
      categoryId: event.categoryId,
      endDate: event.endDate,
      timezone: event.timezone,
      autoCreate: event.autoCreate,
      note: event.note,
    );
    result.fold(
      (failure) => emit(RecurringError(_mapFailure(failure))),
      (_) {
        emit(const RecurringActionSuccess('Recurring transaction created'));
        add(const RecurringDataRequested());
      },
    );
  }

  Future<void> _onExecuteRequested(
    RecurringExecuteRequested event,
    Emitter<RecurringState> emit,
  ) async {
    final result = await executeRecurring(event.recurringId);
    result.fold(
      (failure) => emit(RecurringError(_mapFailure(failure))),
      (_) {
        emit(const RecurringActionSuccess('Transaksi berhasil dijalankan'));
        add(const RecurringDataRequested());
      },
    );
  }

  Future<void> _onActivateRequested(
    RecurringActivateRequested event,
    Emitter<RecurringState> emit,
  ) async {
    final result = await updateRecurring(event.recurringId, isActive: true);
    result.fold(
      (failure) => emit(RecurringError(_mapFailure(failure))),
      (_) {
        emit(const RecurringActionSuccess('Subscription diaktifkan kembali'));
        add(const RecurringDataRequested());
      },
    );
  }

  Future<void> _onUpdateRequested(
    RecurringUpdateRequested event,
    Emitter<RecurringState> emit,
  ) async {
    final result = await updateRecurring(
      event.recurringId,
      amount: event.amount,
      note: event.note,
    );
    result.fold(
      (failure) => emit(RecurringError(_mapFailure(failure))),
      (_) {
        emit(const RecurringActionSuccess('Subscription diperbarui'));
        add(const RecurringDataRequested());
      },
    );
  }

  String _mapFailure(Failure failure) => switch (failure) {
    ServerFailure f => f.message,
    NetworkFailure _ =>
      'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
    UnauthorizedFailure _ => failure.message,
    CacheFailure _ => 'Terjadi kesalahan lokal. Silakan coba lagi.',
  };
}
