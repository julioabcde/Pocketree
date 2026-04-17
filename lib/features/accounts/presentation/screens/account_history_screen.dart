import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';
import 'package:pocketree/features/home/presentation/widgets/transaction_item.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_filter.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';

class AccountHistoryScreen extends StatelessWidget {
  final Account account;

  const AccountHistoryScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, now.day);
    final filter = TransactionFilter(
      accountId: account.id,
      startDate: startDate,
      endDate: now,
    );

    return BlocProvider(
      create: (_) => sl<TransactionBloc>()
        ..add(TransactionDataRequested(filter: filter)),
      child: _AccountHistoryView(account: account, startDate: startDate),
    );
  }
}

class _AccountHistoryView extends StatelessWidget {
  final Account account;
  final DateTime startDate;

  const _AccountHistoryView({required this.account, required this.startDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralCream,
      appBar: AppBar(
        backgroundColor: AppColors.neutralCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.brownEspresso,
          ),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text(
          'Account History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.brownEspresso,
          ),
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading || state is TransactionInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryForest),
            );
          }

          if (state is TransactionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
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
                      onPressed: () {
                        final now = DateTime.now();
                        context.read<TransactionBloc>().add(
                          TransactionDataRequested(
                            filter: TransactionFilter(
                              accountId: account.id,
                              startDate: startDate,
                              endDate: now,
                            ),
                          ),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is TransactionLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionLoaded state) {
    final groups = _groupByDate(state.transactions);

    return RefreshIndicator(
      color: AppColors.primaryForest,
      backgroundColor: AppColors.white,
      onRefresh: () {
        final event = TransactionDataRefreshed(filter: state.filter);
        context.read<TransactionBloc>().add(event);
        return event.completer.future;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: _AccountSummaryCard(
              account: account,
              startDate: startDate,
              totalIncome: state.summary.totalIncome,
              totalExpense: state.summary.totalExpense,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TRANSACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownMocha,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '${state.summary.transactionCount} entries',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.brownMocha,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (groups.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyHistory(),
          )
        else
          ..._buildGroupedSlivers(groups),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
      ),
    );
  }

  List<Widget> _buildGroupedSlivers(Map<DateTime, List<Transaction>> groups) {
    final slivers = <Widget>[];
    final sortedDates = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      slivers.add(
        SliverToBoxAdapter(
          child: Container(
            color: AppColors.neutralCream,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              _formatDateHeader(date),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.brownDriftwood,
              ),
            ),
          ),
        ),
      );

      final txs = groups[date]!;
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => TransactionItem(
              transaction: txs[index],
              showDivider: index < txs.length - 1,
            ),
            childCount: txs.length,
          ),
        ),
      );
    }

    return slivers;
  }

  Map<DateTime, List<Transaction>> _groupByDate(List<Transaction> txs) {
    final map = <DateTime, List<Transaction>>{};
    for (final tx in txs) {
      final key = DateTime(tx.date.year, tx.date.month, tx.date.day);
      map.putIfAbsent(key, () => []).add(tx);
    }
    return map;
  }

  String _formatDateHeader(DateTime date) {
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final yesterday = today.subtract(const Duration(days: 1));
    final isYesterday =
        date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }
}

class _AccountSummaryCard extends StatelessWidget {
  final Account account;
  final DateTime startDate;
  final double totalIncome;
  final double totalExpense;

  const _AccountSummaryCard({
    required this.account,
    required this.startDate,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (account.type) {
      AccountType.cash => 'CASH',
      AccountType.bankAccount => 'BANK ACCOUNT',
      AccountType.eWallet => 'E-WALLET',
      AccountType.creditCard => 'CREDIT CARD',
    };

    final endDate = DateTime.now();
    final rangeLabel =
        '${DateFormat('dd MMM').format(startDate)} – ${DateFormat('dd MMM yyyy').format(endDate)}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkDeepPine, AppColors.darkPine],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            typeLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            account.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.format(account.balance),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current balance',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 1,
            color: AppColors.white.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 14),
          Text(
            rangeLabel.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.white.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricColumn(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Income',
                  amount: totalIncome,
                  color: AppColors.activityLow,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: AppColors.white.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _MetricColumn(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Expense',
                  amount: totalExpense,
                  color: AppColors.neutralSand,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final bool alignEnd;

  const _MetricColumn({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!alignEnd) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.white.withValues(alpha: 0.7),
                letterSpacing: 1,
              ),
            ),
            if (alignEnd) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: color),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: AppColors.neutralTaupe.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            const Text(
              'No transactions in the last month',
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
