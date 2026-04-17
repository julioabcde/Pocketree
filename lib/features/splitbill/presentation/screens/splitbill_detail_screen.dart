import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/snackbar_helper.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_picker_sheet.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_debt.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_participant.dart';
import 'package:pocketree/features/splitbill/presentation/args/assign_items_args.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_detail_bloc.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_detail_event.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_detail_state.dart';
import 'package:pocketree/features/splitbill/presentation/widgets/detail_widgets.dart';
import 'package:pocketree/features/splitbill/presentation/widgets/receipt_detail_sheet.dart';


class SplitbillDetailScreen extends StatefulWidget {
  final int billId;
  const SplitbillDetailScreen({super.key, required this.billId});

  @override
  State<SplitbillDetailScreen> createState() => _SplitbillDetailScreenState();
}

class _SplitbillDetailScreenState extends State<SplitbillDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplitBillDetailBloc>().add(
          SplitBillDetailRequested(billId: widget.billId),
        );
  }


  Future<void> _navigateToCalculate(SplitBillDetail detail) async {
    await GoRouter.of(context).push(
      '/assign-items',
      extra: AssignItemsArgs(
        billId: widget.billId,
        isNewBill: false,
      ),
    );
    if (mounted) {
      context.read<SplitBillDetailBloc>().add(
            SplitBillDetailRequested(billId: widget.billId),
          );
    }
  }

  void _showReceiptSheet(SplitBillDetail detail) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptDetailSheet(detail: detail),
    );
  }

  Future<void> _onSettleDebt(SplitBillDebt debt) async {
    final result = await _showSettleDialog(debt);
    if (result == null || !mounted) return;
    context.read<SplitBillDetailBloc>().add(
          SplitBillSettleRequested(
            billId: widget.billId,
            debtId: debt.id,
            amount: result.amount,
            accountId: result.accountId,
          ),
        );
  }

  Future<({double amount, int? accountId})?> _showSettleDialog(
      SplitBillDebt debt) async {
    final controller = TextEditingController(
      text: debt.remainingAmount.toStringAsFixed(2),
    );
    Account? selectedAccount;
    return showDialog<({double amount, int? accountId})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            String? errorText;
            final parsed = double.tryParse(controller.text);
            if (controller.text.isNotEmpty) {
              if (parsed == null || parsed <= 0) {
                errorText = 'Enter a valid amount';
              } else if (parsed > debt.remainingAmount) {
                errorText =
                    'Cannot exceed Rp ${debt.remainingAmount.toStringAsFixed(2)}';
              }
            }
            final isValid =
                parsed != null && parsed > 0 && parsed <= debt.remainingAmount;

            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Settle Debt'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${debt.debtorName} owes ${debt.creditorName}',
                    style: const TextStyle(color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setDialogState(() {}),
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      errorText: errorText,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: AppColors.primaryForest, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showAccountPicker(ctx,
                          selected: selectedAccount);
                      if (picked != null) {
                        setDialogState(() => selectedAccount = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBeige,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neutralTaupe),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primaryForest,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedAccount?.name ??
                                  'Link to account (optional)',
                              style: TextStyle(
                                fontSize: 13,
                                color: selectedAccount != null
                                    ? AppColors.brownEspresso
                                    : AppColors.brownMocha,
                              ),
                            ),
                          ),
                          if (selectedAccount != null)
                            GestureDetector(
                              onTap: () =>
                                  setDialogState(() => selectedAccount = null),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppColors.brownMocha,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: isValid
                      ? () => Navigator.of(ctx).pop(
                          (amount: parsed, accountId: selectedAccount?.id))
                      : null,
                  child: const Text('Settle',
                      style: TextStyle(color: AppColors.primaryForest)),
                ),
              ],
            );
          },
        ),
      );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Bill'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<SplitBillDetailBloc>().add(
            SplitBillDetailDeleteRequested(billId: widget.billId),
          );
    }
  }

  void _showMoreOptions(SplitBillDetail detail) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.neutralTaupe,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (!detail.hasCalculation ||
                  detail.settlements.isEmpty)
                ListTile(
                  leading: const Icon(Icons.calculate_outlined,
                      color: AppColors.brownDriftwood),
                  title: const Text('Recalculate'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToCalculate(detail);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.errorRed),
                title: const Text('Delete Bill',
                    style: TextStyle(color: AppColors.errorRed)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplitBillDetailBloc, SplitBillDetailState>(
      listener: (context, state) {
        if (state is SplitBillDetailActionSuccess) {
          showSuccessSnackBar(context, state.message);
          if (state.message == 'Bill deleted') {
            GoRouter.of(context).pop();
          }
        }
        if (state is SplitBillDetailError) {
          showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        final detail = state is SplitBillDetailLoaded ? state.detail : null;
        final isLoading = state is SplitBillDetailLoading ||
            (state is SplitBillDetailLoaded && state.isPerformingAction);

        return Scaffold(
          backgroundColor: AppColors.scaffoldBeige,
          appBar: _buildAppBar(detail),
          body: isLoading && detail == null
              ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryForest),
                )
              : state is SplitBillDetailError && detail == null
                  ? _buildError(context, state.message)
                  : detail != null
                      ? _buildBody(context, detail, isLoading)
                      : const SizedBox.shrink(),
          bottomNavigationBar: detail != null
              ? _buildBottomBar(detail)
              : null,
        );
      },
    );
  }

  AppBar _buildAppBar(SplitBillDetail? detail) {
    return AppBar(
      backgroundColor: AppColors.scaffoldBeige,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => GoRouter.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.primaryForest),
      ),
      title: const Text(
        'Bill Details',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryForest,
        ),
      ),
      centerTitle: true,
      actions: [
        if (detail != null)
          IconButton(
            onPressed: () => _showMoreOptions(detail),
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.brownEspresso),
          ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    SplitBillDetail detail,
    bool isLoading,
  ) {
    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primaryForest,
          backgroundColor: AppColors.white,
          onRefresh: () {
            final event = SplitBillDetailRefreshed(billId: widget.billId);
            context.read<SplitBillDetailBloc>().add(event);
            return event.completer.future;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DetailHeaderSection(
                detail: detail,
                onReceiptTap: () => _showReceiptSheet(detail),
              ),
              const SizedBox(height: 28),

              if (detail.hasCalculation) ...[
                CopySummaryBox(detail: detail),
                const SizedBox(height: 28),
              ],

              if (!detail.hasCalculation)
                NoCalculationBanner(
                  onCalculateTap: () => _navigateToCalculate(detail),
                )
              else ...[
                const Text(
                  'PAYMENT STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownMocha,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...detail.participants.map((p) {
                  final debt = _debtFor(p.id, detail.debts);
                  final status = _resolveStatus(p, detail.debts);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: ParticipantCard(
                      participant: p,
                      debt: debt,
                      status: status,
                      onSettle:
                          (status == ParticipantStatus.owes && debt != null)
                              ? () => _onSettleDebt(debt)
                              : null,
                    ),
                  );
                }),
              ],

              const SizedBox(height: 12),

              BillSummarySection(detail: detail),

            ],
          ),
          ),
        ),

        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primaryForest),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar(SplitBillDetail detail) {
    final hasPendingDebts =
        detail.debts.any((d) => !d.isSettled);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: hasPendingDebts
                ? () {
                    showSuccessSnackBar(context, 'Notifications coming soon!');
                  }
                : null,
            icon: const Icon(Icons.notifications_rounded, size: 20),
            label: const Text(
              'Notify Pending Debts',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  AppColors.primaryForest.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
          ),
        ),
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
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.brownDriftwood)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<SplitBillDetailBloc>().add(
                    SplitBillDetailRequested(billId: widget.billId),
                  ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }


  SplitBillDebt? _debtFor(int participantId, List<SplitBillDebt> debts) {
    for (final d in debts) {
      if (d.debtorParticipantId == participantId) return d;
    }
    return null;
  }

  ParticipantStatus _resolveStatus(
    SplitBillParticipant p,
    List<SplitBillDebt> debts,
  ) {
    if (p.isPayer) return ParticipantStatus.payer;
    final debt = _debtFor(p.id, debts);
    if (debt == null) return ParticipantStatus.noDebt;
    return debt.isSettled
        ? ParticipantStatus.settled
        : ParticipantStatus.owes;
  }
}

