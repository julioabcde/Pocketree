import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransactionBloc>()..add(const TransactionDataRequested()),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralCream,
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
          onPressed: () => GoRouter.of(context).push('/transactions/add'),
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoading || state is TransactionInitial) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryForest),
                    );
                  }

                  if (state is TransactionError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.brownDriftwood),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<TransactionBloc>()
                                .add(const TransactionDataRequested()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is TransactionLoaded) {
                    return _buildContent(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: const Text(
        'Transactions',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.brownEspresso,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionLoaded state) {
    if (state.transactions.isEmpty) {
      return _buildEmpty();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            !state.hasReachedEnd &&
            !state.isLoadingMore) {
          context.read<TransactionBloc>().add(const TransactionNextPageRequested());
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
        itemCount: state.transactions.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.transactions.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primaryForest),
              ),
            );
          }
          return _buildTransactionItem(state.transactions[index]);
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.neutralTaupe,
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.brownMocha,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap + to add your first transaction',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutralTaupe,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.isTransfer;

    final Color iconBg = isTransfer
        ? AppColors.neutralSand
        : isIncome
            ? AppColors.primaryForest.withValues(alpha: 0.1)
            : AppColors.brownEspresso.withValues(alpha: 0.08);

    final Color iconColor = isTransfer
        ? AppColors.brownMocha
        : isIncome
            ? AppColors.primaryForest
            : AppColors.brownEspresso;

    final IconData icon = isTransfer
        ? Icons.swap_horiz_rounded
        : isIncome
            ? Icons.arrow_downward_rounded
            : Icons.arrow_upward_rounded;

    final Color amountColor = isTransfer
        ? AppColors.brownDriftwood
        : isIncome
            ? AppColors.primaryForest
            : AppColors.brownEspresso;

    final String amountPrefix = isTransfer ? '' : isIncome ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.note?.isNotEmpty == true
                        ? transaction.note!
                        : isTransfer
                            ? 'Transfer'
                            : isIncome
                                ? 'Income'
                                : 'Expense',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brownEspresso,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d MMM yyyy').format(transaction.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.brownMocha,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
