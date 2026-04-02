import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/home/presentation/bloc/home_bloc.dart';
import 'package:pocketree/features/home/presentation/bloc/home_event.dart';
import 'package:pocketree/features/home/presentation/bloc/home_state.dart';
import 'package:pocketree/features/home/presentation/widgets/home_header.dart';
import 'package:pocketree/features/home/presentation/widgets/transaction_header_delegate.dart';
import 'package:pocketree/features/home/presentation/widgets/transaction_item.dart';
import 'package:pocketree/features/home/presentation/widgets/wallet_carousel.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:pocketree/core/di/injection_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<HomeBloc>()..add(const HomeDataRequested())),
        BlocProvider(create: (_) => sl<TransactionBloc>()),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralLinen,
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.brownEspresso,
          boxShadow: [
            BoxShadow(
              color: AppColors.brownEspresso.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          heroTag: 'addTransaction',
          onPressed: () async {
            final created = await GoRouter.of(
              context,
            ).push<bool>('/add-transaction');
            if (created == true && context.mounted) {
              context.read<HomeBloc>().add(const HomeDataRequested());
            }
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
          shape: const CircleBorder(),
          child: const Icon(
            Icons.add_rounded,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return BlocListener<TransactionBloc, TransactionState>(
            listener: (context, transactionState) {
              if (transactionState is TransactionActionSuccess) {
                context.read<HomeBloc>().add(const HomeDataRequested());
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(transactionState.message),
                      backgroundColor: AppColors.primaryForest,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              }

              if (transactionState is TransactionError) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(transactionState.message),
                      backgroundColor: const Color(0xFFB3261E),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              }
            },
            child: Builder(
              builder: (context) {
                if (state is HomeLoading || state is HomeInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryForest,
                    ),
                  );
                }

                if (state is HomeError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.brownDriftwood,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<HomeBloc>().add(
                            const HomeDataRequested(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is HomeLoaded) {
                  return _buildContent(context, state);
                }

                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    final accounts = state.data.accounts;
    final transactions = state.data.todayTransactions;
    final accountNameById = {
      for (final account in accounts) account.id: account.name,
    };
    final transactionById = {
      for (final transaction in transactions) transaction.id: transaction,
    };

    return RefreshIndicator(
      color: AppColors.primaryForest,
      backgroundColor: AppColors.white,
      onRefresh: () {
        final event = HomeDataRefreshed();
        context.read<HomeBloc>().add(event);
        return event.completer.future;
      },
      child: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(child: HomeHeader()),

          // Wallet
          if (accounts.isNotEmpty)
            SliverPersistentHeader(
              pinned: true,
              delegate: WalletSectionDelegate(
                height: 280,
                accounts: accounts,
                currentPage: _currentPage,
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
              ),
            ),

          // Transaction Header
          SliverPersistentHeader(
            pinned: true,
            delegate: TransactionHeaderDelegate(height: 72),
          ),

          // Transaction List
          if (transactions.isEmpty)
            SliverToBoxAdapter(child: _buildEmpty())
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final transaction = transactions[index];

                return TransactionItem(
                  transaction: transaction,
                  showDivider: index < transactions.length - 1,
                  transferMetaLabel: _buildTransferMetaLabel(
                    transaction: transaction,
                    transactionById: transactionById,
                    accountNameById: accountNameById,
                  ),
                  onOptionsTap: transaction.isTransfer
                      ? null
                      : () => _showTransactionOptions(context, transaction),
                );
              }, childCount: transactions.length),
            ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(color: AppColors.neutralCream),
          ),
        ],
      ),
    );
  }

  String? _buildTransferMetaLabel({
    required Transaction transaction,
    required Map<int, Transaction> transactionById,
    required Map<int, String> accountNameById,
  }) {
    if (!transaction.isTransfer) {
      return null;
    }

    final pairId = transaction.transferId;
    if (pairId == null) {
      return transaction.isIncome ? 'Transfer in' : 'Transfer out';
    }

    final counterpart = transactionById[pairId];
    if (counterpart == null) {
      return transaction.isIncome ? 'Transfer in' : 'Transfer out';
    }

    final counterpartAccountName =
        accountNameById[counterpart.accountId] ??
        'Account #${counterpart.accountId}';

    return transaction.isIncome
        ? 'From $counterpartAccountName'
        : 'To $counterpartAccountName';
  }

  Future<void> _showTransactionOptions(
    BuildContext context,
    Transaction transaction,
  ) async {
    if (transaction.isTransfer) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutralTaupe,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.brownDriftwood,
                  ),
                  title: const Text('Edit Transaction'),
                  onTap: () async {
                    Navigator.pop(context);
                    final updated = await GoRouter.of(
                      context,
                    ).push<bool>('/edit-transaction', extra: transaction);
                    if (updated == true && context.mounted) {
                      context.read<HomeBloc>().add(const HomeDataRequested());
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB3261E),
                  ),
                  title: const Text(
                    'Delete Transaction',
                    style: TextStyle(color: Color(0xFFB3261E)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteTransaction(context, transaction.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteTransaction(
    BuildContext context,
    int transactionId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: const Text(
            'Are you sure you want to delete this transaction?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB3261E),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<TransactionBloc>().add(
        TransactionDeleteRequested(transactionId: transactionId),
      );
    }
  }

  // Empty state
  Widget _buildEmpty() {
    return Container(
      color: AppColors.neutralCream,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: AppColors.neutralTaupe.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            const Text(
              'No transactions today',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.brownMocha,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
