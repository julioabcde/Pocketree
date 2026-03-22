import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/error/failures.dart';
import 'package:pocketree/features/accounts/domain/usecases/create_account_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/delete_account_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_account_summary_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_accounts_usecase.dart';
import 'package:pocketree/features/accounts/domain/usecases/update_account_usecase.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_event.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccountsUseCase getAccounts;
  final GetAccountSummaryUseCase getAccountSummary;
  final CreateAccountUseCase createAccount;
  final UpdateAccountUseCase updateAccount;
  final DeleteAccountUseCase deleteAccount;

  AccountBloc({
    required this.getAccounts,
    required this.getAccountSummary,
    required this.createAccount,
    required this.updateAccount,
    required this.deleteAccount,
  }) : super(const AccountInitial()) {
    on<AccountDataRequested>(_onDataRequested);
    on<AccountCreateRequested>(_onCreateRequested);
    on<AccountUpdateRequested>(_onUpdateRequested);
    on<AccountDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onDataRequested(
    AccountDataRequested event,
    Emitter<AccountState> emit,
  ) async {
    if (state is! AccountLoaded) {
      emit(const AccountLoading());
    }

    final accountsResult = await getAccounts();
    final summaryResult = await getAccountSummary();

    accountsResult.fold(
      (failure) => emit(AccountError(_mapFailureToMessage(failure))),
      (accounts) => summaryResult.fold(
        (failure) => emit(AccountError(_mapFailureToMessage(failure))),
        (summary) => emit(AccountLoaded(
          accounts: accounts,
          summary: summary,
        )),
      ),
    );
  }

  Future<void> _onCreateRequested(
    AccountCreateRequested event,
    Emitter<AccountState> emit,
  ) async {
    if (state is AccountLoaded) {
      emit((state as AccountLoaded).copyWith(isPerformingAction: true));
    }

    final result = await createAccount(
      name: event.name,
      type: event.type,
      initialBalance: event.initialBalance,
    );

    result.fold(
      (failure) => emit(AccountError(_mapFailureToMessage(failure))),
      (_) {
        emit(const AccountActionSuccess('Account created successfully'));
        add(const AccountDataRequested());
      },
    );
  }

  Future<void> _onUpdateRequested(
    AccountUpdateRequested event,
    Emitter<AccountState> emit,
  ) async {
    if (state is AccountLoaded) {
      emit((state as AccountLoaded).copyWith(isPerformingAction: true));
    }

    final result = await updateAccount(
      accountId: event.accountId,
      name: event.name,
      type: event.type,
    );

    result.fold(
      (failure) => emit(AccountError(_mapFailureToMessage(failure))),
      (_) {
        emit(const AccountActionSuccess('Account updated successfully'));
        add(const AccountDataRequested());
      },
    );
  }

  Future<void> _onDeleteRequested(
    AccountDeleteRequested event,
    Emitter<AccountState> emit,
  ) async {
    if (state is AccountLoaded) {
      emit((state as AccountLoaded).copyWith(isPerformingAction: true));
    }

    final result = await deleteAccount(event.accountId);

    result.fold(
      (failure) => emit(AccountError(_mapFailureToMessage(failure))),
      (_) {
        emit(const AccountActionSuccess('Account deleted successfully'));
        add(const AccountDataRequested());
      },
    );
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