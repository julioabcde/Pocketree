import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/compact_amount_formatter.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_state.dart';

//  Frequency colour palette 
({Color bg, Color icon}) _frequencyColors(RecurringFrequency frequency) =>
    switch (frequency) {
      RecurringFrequency.daily =>
        (bg: const Color(0xFFFFF3E0), icon: const Color(0xFFF57C00)),
      RecurringFrequency.weekly =>
        (bg: const Color(0xFFE3F2FD), icon: const Color(0xFF1565C0)),
      RecurringFrequency.monthly => (
          bg: AppColors.primaryForest,
          icon: AppColors.white,
        ),
      RecurringFrequency.yearly =>
        (bg: const Color(0xFFF3E5F5), icon: const Color(0xFF7B1FA2)),
    };

({Color bg, Color icon}) _itemColors(RecurringTransaction item) {
  if (item.isPaused) {
    return (bg: AppColors.neutralSand, icon: AppColors.neutralTaupe);
  }
  return _frequencyColors(item.frequency);
}

//  Main widget ─
class SubscriptionsTabView extends StatelessWidget {
  const SubscriptionsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RecurringBloc, RecurringState>(
      listener: (context, state) {
        if (state is RecurringActionSuccess) {
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
        if (state is RecurringError) {
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
      builder: (context, state) {
        if (state is RecurringLoading || state is RecurringInitial) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryForest),
          );
        }

        if (state is RecurringError) {
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
                    onPressed: () => context
                        .read<RecurringBloc>()
                        .add(const RecurringDataRequested()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is RecurringLoaded) {
          return _SubscriptionsContent(state: state);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

//  Content 
class _SubscriptionsContent extends StatelessWidget {
  final RecurringLoaded state;

  const _SubscriptionsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RecurringBloc>();
    final sorted = state.sorted;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      children: [
        //  Monthly Commitment Summary 
        _RecurringSummaryHeader(state: state),
        const SizedBox(height: 24),

        Divider(
          color: AppColors.neutralTaupe.withValues(alpha: 0.3),
          thickness: 1,
        ),
        const SizedBox(height: 16),

        //  Frequency Legend 
        const _FrequencyLegend(),
        const SizedBox(height: 20),

        //  Active Subscriptions Section 
        if (sorted.isEmpty)
          _buildEmpty()
        else ...[
          const Text(
            'ACTIVE SUBSCRIPTIONS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.brownMocha,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          ...sorted.map(
            (item) => _SubscriptionListItem(
              item: item,
              onDeactivate: () => _confirmDeactivate(context, bloc, item),
              onExecute: () =>
                  bloc.add(RecurringExecuteRequested(recurringId: item.id)),
              onActivate: () =>
                  bloc.add(RecurringActivateRequested(recurringId: item.id)),
              onEdit: () => _showEditSheet(context, bloc, item),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Column(
          children: [
            Icon(
              Icons.autorenew_rounded,
              size: 48,
              color: AppColors.neutralTaupe.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'No subscriptions yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.brownEspresso,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Recurring transactions will appear here',
              style: TextStyle(fontSize: 14, color: AppColors.brownMocha),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate(
    BuildContext context,
    RecurringBloc bloc,
    RecurringTransaction item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nonaktifkan Subscription'),
        content: Text(
          'Yakin ingin menonaktifkan "${item.note ?? 'subscription ini'}"? '
          'Transaksi tidak akan dibuat secara otomatis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB3261E)),
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(RecurringDeleteRequested(recurringId: item.id));
    }
  }

  void _showEditSheet(
    BuildContext context,
    RecurringBloc bloc,
    RecurringTransaction item,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _EditRecurringSheet(item: item, bloc: bloc),
    );
  }
}

//  Summary Header (3 columns) 
class _RecurringSummaryHeader extends StatelessWidget {
  final RecurringLoaded state;

  const _RecurringSummaryHeader({required this.state});

  static const _labelStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.brownMocha,
    letterSpacing: 1,
  );

  static const _valueBaseStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  @override
  Widget build(BuildContext context) {
    final net = state.netMonthlyCommitment;
    return Row(
      children: [
        _buildColumn(
          label: 'INCOME',
          value: CompactAmountFormatter.format(state.totalMonthlyIncome),
          color: AppColors.primaryForest,
        ),
        _buildColumn(
          label: 'EXPENSE',
          value: CompactAmountFormatter.format(state.totalMonthlyExpense),
          color: AppColors.brownEspresso,
        ),
        _buildColumn(
          label: 'NET',
          value: CompactAmountFormatter.formatSigned(net),
          color: net >= 0 ? AppColors.primaryForest : const Color(0xFFB3261E),
        ),
      ],
    );
  }

  Widget _buildColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: _labelStyle),
          const SizedBox(height: 4),
          Text(value, style: _valueBaseStyle.copyWith(color: color)),
        ],
      ),
    );
  }
}

//  Frequency Legend ─
class _FrequencyLegend extends StatelessWidget {
  const _FrequencyLegend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: RecurringFrequency.values.map((freq) {
        final colors = _frequencyColors(freq);
        final label = switch (freq) {
          RecurringFrequency.daily => 'Daily',
          RecurringFrequency.weekly => 'Weekly',
          RecurringFrequency.monthly => 'Monthly',
          RecurringFrequency.yearly => 'Yearly',
        };
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.bg,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: colors.icon.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.brownMocha,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

//  List Item 
class _SubscriptionListItem extends StatelessWidget {
  final RecurringTransaction item;
  final VoidCallback onDeactivate;
  final VoidCallback onExecute;
  final VoidCallback onActivate;
  final VoidCallback onEdit;

  const _SubscriptionListItem({
    required this.item,
    required this.onDeactivate,
    required this.onExecute,
    required this.onActivate,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isPaused = item.isPaused;
    final colors = _itemColors(item);
    final nextBilling = DateFormat('d MMM').format(item.nextDueDate);
    final frequencyLabel = switch (item.frequency) {
      RecurringFrequency.daily => 'Daily',
      RecurringFrequency.weekly => 'Weekly',
      RecurringFrequency.monthly => 'Monthly',
      RecurringFrequency.yearly => 'Yearly',
    };

    return Opacity(
      opacity: isPaused ? 0.55 : 1.0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                //  Frequency-coloured icon 
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.bg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.autorenew_rounded,
                    size: 22,
                    color: colors.icon,
                  ),
                ),
                const SizedBox(width: 14),

                //  Name + subtitle 
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.note ?? frequencyLabel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isPaused
                              ? AppColors.brownMocha
                              : AppColors.brownEspresso,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isPaused ? 'Tidak aktif' : 'Tagihan: $nextBilling',
                        style: TextStyle(
                          fontSize: 13,
                          color: isPaused
                              ? AppColors.neutralTaupe
                              : AppColors.primaryForest,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                //  Amount + badge 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${_formatAmount(item.amount)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isPaused
                            ? AppColors.brownMocha
                            : AppColors.brownEspresso,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isPaused
                            ? AppColors.neutralSand
                            : AppColors.primaryForest.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPaused ? 'PAUSED' : frequencyLabel.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isPaused
                              ? AppColors.brownMocha
                              : AppColors.primaryForest,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 4),

                //  Three-dot menu 
                GestureDetector(
                  onTap: () => _showOptions(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.more_vert_rounded,
                      size: 20,
                      color: AppColors.neutralTaupe,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: AppColors.neutralTaupe.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1e9) return '${(amount / 1e9).toStringAsFixed(1)}B';
    if (amount >= 1e6) return '${(amount / 1e6).toStringAsFixed(1)}M';
    if (amount >= 1e3) return '${(amount / 1e3).toStringAsFixed(0)}k';
    return amount.toStringAsFixed(0);
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
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
                if (!item.isPaused) ...[
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryForest,
                    ),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.primaryForest,
                    ),
                    title: const Text('Jalankan Sekarang'),
                    onTap: () {
                      Navigator.pop(context);
                      onExecute();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.pause_circle_outline_rounded,
                      color: Color(0xFFB3261E),
                    ),
                    title: const Text(
                      'Nonaktifkan',
                      style: TextStyle(color: Color(0xFFB3261E)),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onDeactivate();
                    },
                  ),
                ] else ...[
                  ListTile(
                    leading: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.primaryForest,
                    ),
                    title: const Text(
                      'Aktifkan Kembali',
                      style: TextStyle(color: AppColors.primaryForest),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onActivate();
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.brownDriftwood,
                    ),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

//  Edit Sheet 
class _EditRecurringSheet extends StatefulWidget {
  final RecurringTransaction item;
  final RecurringBloc bloc;

  const _EditRecurringSheet({required this.item, required this.bloc});

  @override
  State<_EditRecurringSheet> createState() => _EditRecurringSheetState();
}

class _EditRecurringSheetState extends State<_EditRecurringSheet> {
  late final TextEditingController _noteController;
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.note ?? '');
    _amountController = TextEditingController(
      text: widget.item.amount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.neutralTaupe,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Edit Subscription',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
          const SizedBox(height: 20),

          // Note field
          const Text(
            'Catatan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brownMocha,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Nama atau catatan',
              filled: true,
              fillColor: AppColors.neutralSand,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),

          // Amount field
          const Text(
            'Jumlah',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brownMocha,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '0',
              prefixText: 'Rp ',
              filled: true,
              fillColor: AppColors.neutralSand,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() {
    final newNote = _noteController.text.trim();
    final newAmountRaw = double.tryParse(_amountController.text);
    final newAmount =
        (newAmountRaw != null && newAmountRaw > 0) ? newAmountRaw : null;

    widget.bloc.add(RecurringUpdateRequested(
      recurringId: widget.item.id,
      amount: newAmount,
      note: newNote.isNotEmpty ? newNote : null,
    ));

    Navigator.pop(context);
  }
}
