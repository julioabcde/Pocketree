import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/snackbar_helper.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_summary.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_bloc.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_event.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_state.dart';
import 'package:pocketree/features/splitbill/presentation/widgets/bill_list_widgets.dart';

class SplitBillListScreen extends StatefulWidget {
  const SplitBillListScreen({super.key});

  @override
  State<SplitBillListScreen> createState() => _SplitBillListScreenState();
}

class _SplitBillListScreenState extends State<SplitBillListScreen> {
  bool _showSettled = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplitBillBloc, SplitBillState>(
      listener: (context, state) {
        if (state is SplitBillActionSuccess) {
          showSuccessSnackBar(context, state.message);
          context
              .read<SplitBillBloc>()
              .add(const SplitBillSummaryRequested());
        }
        if (state is SplitBillError) {
          showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is SplitBillLoading || state is SplitBillInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryForest),
          );
        }
        if (state is SplitBillError) {
          return _buildError(context, state.message);
        }
        if (state is SplitBillSummaryLoaded) {
          if (state.active.isEmpty && state.settled.isEmpty) {
            return _buildEmpty(context);
          }
          return _buildContent(context, state, _showSettled);
        }
        return const SizedBox.shrink();
      },
    );
  }


  Widget _buildContent(BuildContext context, SplitBillSummaryLoaded state, bool showSettled) {
    return RefreshIndicator(
      color: AppColors.primaryForest,
      backgroundColor: AppColors.white,
      onRefresh: () {
        final event = SplitBillDataRefreshed();
        context.read<SplitBillBloc>().add(event);
        return event.completer.future;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: TotalHeader(totalToCollect: state.totalToCollect),
          ),
        ),

        if (state.active.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Row(
                children: [
                  const Text(
                    'ACTIVE SPLITS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownMocha,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _showSettled = !_showSettled),
                    child: Icon(
                      Icons.filter_list_rounded,
                      size: 20,
                      color: showSettled
                          ? AppColors.primaryForest
                          : AppColors.brownMocha,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final bill = state.active[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: ActiveBillCard(
                    bill: bill,
                    onTap: () => _navigateToDetail(context, bill),
                    onDelete: () => _confirmDelete(context, bill),
                  ),
                );
              },
              childCount: state.active.length,
            ),
          ),
        ],

        if (showSettled && state.settled.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: const Text(
                'SETTLED HISTORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownMocha,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final bill = state.settled[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                  child: SettledBillCard(
                    bill: bill,
                    onTap: () => _navigateToDetail(context, bill),
                  ),
                );
              },
              childCount: state.settled.length,
            ),
          ),
        ],

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
      ),
    );
  }


  void _navigateToDetail(BuildContext context, SplitBillSummary summary) {
    GoRouter.of(context).push('/splitbill-detail', extra: summary.id);
  }


  Future<void> _confirmDelete(
    BuildContext context,
    SplitBillSummary bill,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Bill'),
        content: Text('Delete "${bill.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context
          .read<SplitBillBloc>()
          .add(SplitBillDeleteRequested(billId: bill.id));
    }
  }


  Widget _buildEmpty(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryForest,
      backgroundColor: AppColors.white,
      onRefresh: () {
        final event = SplitBillDataRefreshed();
        context.read<SplitBillBloc>().add(event);
        return event.completer.future;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(48, 120, 48, 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primaryForest.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 32,
                    color: AppColors.primaryForest.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No split bills yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brownEspresso,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Scan a receipt or create one manually',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.brownMocha),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.brownDriftwood),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<SplitBillBloc>()
                  .add(const SplitBillSummaryRequested()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


