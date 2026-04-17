import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/home/presentation/widgets/transaction_item.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/calender_state.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:pocketree/features/transactions/presentation/widgets/calendar_month_header.dart';
import 'package:pocketree/features/transactions/presentation/widgets/calender_grid.dart';
import 'package:pocketree/features/transactions/presentation/widgets/daily_transaction_header_delegate.dart';

class CalendarTabView extends StatelessWidget {
  const CalendarTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionActionSuccess) {
          final calendarState = context.read<CalendarBloc>().state;
          if (calendarState is CalendarLoaded) {
            context.read<CalendarBloc>()
              ..add(CalendarMonthRequested(month: calendarState.currentMonth))
              ..add(CalendarDaySelected(date: calendarState.selectedDate));
          }

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.primaryForest,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
        }
        if (state is TransactionError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFB3261E),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: BlocBuilder<CalendarBloc, CalendarState>(
        builder: (context, state) {
          if (state is CalendarLoading || state is CalendarInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryForest),
            );
          }

          if (state is CalendarError) {
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
                      onPressed: () => context.read<CalendarBloc>().add(
                        CalendarMonthRequested(month: DateTime.now()),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CalendarLoaded) {
            return _CalendarContent(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  final CalendarLoaded state;

  const _CalendarContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryForest,
      backgroundColor: AppColors.white,
      onRefresh: () {
        final event = CalendarDataRefreshed();
        context.read<CalendarBloc>().add(event);
        return event.completer.future;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: CalendarMonthHeader(summary: state.monthlySummary),
          ),
        ),

        SliverToBoxAdapter(
          child: Divider(
            height: 1,
            thickness: 1,
            color: AppColors.neutralTaupe.withValues(alpha: 0.3),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: CalendarGrid(
              currentMonth: state.currentMonth,
              selectedDate: state.selectedDate,
              dailySummaries: state.dailySummaries,
              onDayTapped: (date) {
                context.read<CalendarBloc>().add(
                  CalendarDaySelected(date: date),
                );
              },
              onPreviousMonth: () {
                final prev = DateTime(
                  state.currentMonth.year,
                  state.currentMonth.month - 1,
                );
                context.read<CalendarBloc>().add(
                  CalendarMonthRequested(month: prev),
                );
              },
              onNextMonth: () {
                final next = DateTime(
                  state.currentMonth.year,
                  state.currentMonth.month + 1,
                );
                context.read<CalendarBloc>().add(
                  CalendarMonthRequested(month: next),
                );
              },
            ),
          ),
        ),

        SliverPersistentHeader(
          pinned: true,
          delegate: DailyTransactionHeaderDelegate(
            selectedDate: state.selectedDate,
          ),
        ),

        if (state.isLoadingDay)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 32),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryForest,
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        else if (state.selectedDayTransactions.isEmpty)
          SliverToBoxAdapter(child: _buildEmpty())
        else
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final transactions = state.selectedDayTransactions;
              final transaction = transactions[index];

              final transactionById = {for (final t in transactions) t.id: t};

              final transferMetaLabel = _buildTransferMetaLabel(
                transaction: transaction,
                transactionById: transactionById,
              );

              return TransactionItem(
                transaction: transaction,
                showDivider: index < transactions.length - 1,
                transferMetaLabel: transferMetaLabel,
                onOptionsTap: transaction.isTransfer
                    ? null
                    : () => _showTransactionOptions(context, transaction),
              );
            }, childCount: state.selectedDayTransactions.length),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
      ),
    );
  }

  String? _buildTransferMetaLabel({
    required Transaction transaction,
    required Map<int, Transaction> transactionById,
  }) {
    if (!transaction.isTransfer) return null;

    final pairId = transaction.transferId;
    if (pairId == null) {
      return transaction.isIncome ? 'Transfer in' : 'Transfer out';
    }

    final counterpart = transactionById[pairId];
    if (counterpart == null) {
      return transaction.isIncome ? 'Transfer in' : 'Transfer out';
    }

    return transaction.isIncome ? 'Transfer in' : 'Transfer out';
  }

  Widget _buildEmpty() {
    return Container(
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
              'No transactions on this day',
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

  Future<void> _showTransactionOptions(
    BuildContext context,
    Transaction transaction,
  ) async {
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
                      final calendarState = context.read<CalendarBloc>().state;
                      if (calendarState is CalendarLoaded) {
                        context.read<CalendarBloc>()
                          ..add(CalendarMonthRequested(
                              month: calendarState.currentMonth))
                          ..add(CalendarDaySelected(
                              date: calendarState.selectedDate));
                      }
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
                    _confirmDelete(context, transaction.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, int transactionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<TransactionBloc>().add(
        TransactionDeleteRequested(transactionId: transactionId),
      );
    }
  }
}
