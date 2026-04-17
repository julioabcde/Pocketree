import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/core/utils/string_utils.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_debt.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_detail.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_participant.dart';

enum ParticipantStatus { payer, owes, settled, noDebt }

class DetailHeaderSection extends StatelessWidget {
  final SplitBillDetail detail;
  final VoidCallback onReceiptTap;

  const DetailHeaderSection({
    super.key,
    required this.detail,
    required this.onReceiptTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'SPLIT WITH FRIENDS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.brownMocha,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          detail.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.brownEspresso,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: AppColors.brownMocha,
            ),
            const SizedBox(width: 6),
            Text(
              DateFormat('EEEE, d MMM yyyy').format(detail.date),
              style: const TextStyle(fontSize: 14, color: AppColors.brownMocha),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onReceiptTap,
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text(
              'VIEW DIGITALIZED RECEIPT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryForest,
              side: const BorderSide(
                color: AppColors.primaryForest,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class NoCalculationBanner extends StatelessWidget {
  final VoidCallback onCalculateTap;
  const NoCalculationBanner({super.key, required this.onCalculateTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 40,
            color: AppColors.primaryForest.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Split not calculated yet',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.brownEspresso,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Assign participants to calculate who owes what',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCalculateTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Assign & Calculate'),
          ),
        ],
      ),
    );
  }
}

class ParticipantCard extends StatelessWidget {
  final SplitBillParticipant participant;
  final SplitBillDebt? debt;
  final ParticipantStatus status;
  final VoidCallback? onSettle;

  const ParticipantCard({
    super.key,
    required this.participant,
    required this.debt,
    required this.status,
    this.onSettle,
  });

  Color get _avatarBg => switch (status) {
    ParticipantStatus.payer => AppColors.primaryForest,
    ParticipantStatus.owes => const Color(0xFFF5A623).withValues(alpha: 0.18),
    ParticipantStatus.settled => AppColors.neutralSand,
    ParticipantStatus.noDebt => AppColors.neutralSand,
  };

  Color get _avatarText => switch (status) {
    ParticipantStatus.payer => Colors.white,
    ParticipantStatus.owes => const Color(0xFFC87D00),
    ParticipantStatus.settled => AppColors.brownMocha,
    ParticipantStatus.noDebt => AppColors.brownMocha,
  };

  String get _statusLabel => switch (status) {
    ParticipantStatus.payer => 'Paid the bill',
    ParticipantStatus.owes => 'Owes ${debt?.creditorName ?? ''}',
    ParticipantStatus.settled => 'Settled',
    ParticipantStatus.noDebt => 'No debt',
  };

  Color get _statusColor => switch (status) {
    ParticipantStatus.payer => AppColors.primaryForest,
    ParticipantStatus.owes => const Color(0xFFC87D00),
    ParticipantStatus.settled => AppColors.brownMocha,
    ParticipantStatus.noDebt => AppColors.brownMocha,
  };

  bool get _isSettled => status == ParticipantStatus.settled;
  bool get _isDimmed =>
      status == ParticipantStatus.settled || status == ParticipantStatus.noDebt;

  double get _displayAmount => switch (status) {
    ParticipantStatus.payer => participant.paidAmount,
    _ => participant.finalAmount ?? 0.0,
  };

  double get _allocatedTaxAndService {
    if (participant.finalAmount == null) return 0.0;
    final itemsTotal = participant.items.fold(
      0.0,
      (sum, i) => sum + i.allocatedSubtotal,
    );
    final diff = participant.finalAmount! - itemsTotal;
    return diff > 0.01 ? diff : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ParticipantAvatar(
                  name: participant.name,
                  bg: _avatarBg,
                  textColor: _avatarText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        participant.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _isDimmed
                              ? AppColors.brownEspresso.withValues(alpha: 0.5)
                              : AppColors.brownEspresso,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _statusColor.withValues(
                            alpha: _isDimmed ? 0.6 : 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      CurrencyFormatter.format(_displayAmount),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _isDimmed
                            ? AppColors.brownEspresso.withValues(alpha: 0.4)
                            : AppColors.brownEspresso,
                        decoration: _isSettled
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.brownEspresso.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                    if (status == ParticipantStatus.owes ||
                        status == ParticipantStatus.settled) ...[
                      const SizedBox(width: 10),
                      SettleCheckbox(checked: _isSettled, onTap: onSettle),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (participant.hasItemBreakdown || _allocatedTaxAndService > 0)
            ItemBreakdown(
              items: participant.items,
              taxAndService: _allocatedTaxAndService,
              isSettled: _isSettled,
            ),
        ],
      ),
    );
  }
}

class ParticipantAvatar extends StatelessWidget {
  final String name;
  final Color bg;
  final Color textColor;

  const ParticipantAvatar({
    super.key,
    required this.name,
    required this.bg,
    required this.textColor,
  });

  String get _initials => nameToInitials(name);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class SettleCheckbox extends StatelessWidget {
  final bool checked;
  final VoidCallback? onTap;

  const SettleCheckbox({super.key, required this.checked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: checked ? AppColors.primaryForest : Colors.transparent,
          border: Border.all(
            color: checked ? AppColors.primaryForest : AppColors.neutralTaupe,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: checked
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class ItemBreakdown extends StatelessWidget {
  final List items;
  final double taxAndService;
  final bool isSettled;

  const ItemBreakdown({
    super.key,
    required this.items,
    required this.taxAndService,
    required this.isSettled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEAE3D5), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 2,
              margin: const EdgeInsets.only(right: 12, top: 2),
              color: AppColors.neutralTaupe.withValues(alpha: 0.5),
              height: (items.length + (taxAndService > 0 ? 1 : 0)) * 26.0,
            ),
            Expanded(
              child: Column(
                children: [
                  ...items.map(
                    (item) => BreakdownItemRow(
                      label: '${item.itemName} (${item.portion}x)',
                      amount: item.allocatedSubtotal,
                      strikethrough: isSettled,
                    ),
                  ),
                  if (taxAndService > 0)
                    BreakdownItemRow(
                      label: 'Tax & Service',
                      amount: taxAndService,
                      strikethrough: isSettled,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BreakdownItemRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool strikethrough;

  const BreakdownItemRow({
    super.key,
    required this.label,
    required this.amount,
    required this.strikethrough,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 13,
      color: AppColors.brownMocha.withValues(alpha: strikethrough ? 0.5 : 0.85),
      decoration: strikethrough ? TextDecoration.lineThrough : null,
      decorationColor: AppColors.brownMocha.withValues(alpha: 0.5),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(CurrencyFormatter.format(amount), style: style),
        ],
      ),
    );
  }
}

class BillSummarySection extends StatelessWidget {
  final SplitBillDetail detail;
  const BillSummarySection({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    final taxAndFees = detail.totalAmount - detail.subtotal;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              children: [
                BillSummaryRow(
                  label: 'Total Consumables',
                  amount: detail.subtotal,
                ),
                const SizedBox(height: 10),
                BillSummaryRow(label: 'Tax & Fees', amount: taxAndFees),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xFFEAE3D5)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                const Text(
                  'Total Bill',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownEspresso,
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.format(detail.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryForest,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BillSummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  const BillSummaryRow({super.key, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.brownMocha),
        ),
        const Spacer(),
        Text(
          CurrencyFormatter.format(amount),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.brownEspresso,
          ),
        ),
      ],
    );
  }
}

class CopySummaryBox extends StatefulWidget {
  final SplitBillDetail detail;
  const CopySummaryBox({super.key, required this.detail});

  @override
  State<CopySummaryBox> createState() => _CopySummaryBoxState();
}

class _CopySummaryBoxState extends State<CopySummaryBox> {
  bool _expanded = false;

  String _buildSummaryText() {
    final detail = widget.detail;
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id').format(detail.date);
    final payer = detail.participants.where((p) => p.isPayer).firstOrNull;
    final extraCharges = detail.totalAmount - detail.subtotal;

    final buf = StringBuffer();
    buf.writeln(detail.title);
    buf.writeln(dateStr);
    buf.writeln();
    buf.writeln(
      'Total tagihan : ${CurrencyFormatter.format(detail.totalAmount)}',
    );
    buf.writeln('Dibayar oleh  : ${payer?.name ?? '-'}');

    if (detail.debts.isNotEmpty) {
      buf.writeln();
      buf.writeln('Settlement');
      for (final d in detail.debts) {
        final amount = d.isSettled
            ? '${CurrencyFormatter.format(d.amount)} (Settled)'
            : CurrencyFormatter.format(
                d.remainingAmount < d.amount ? d.remainingAmount : d.amount,
              );
        buf.writeln('${d.debtorName} -> ${d.creditorName} $amount');
      }
    }

    buf.writeln();
    buf.writeln('Rincian pesanan');

    for (final p in detail.participants) {
      buf.writeln(p.name);
      for (final item in p.items) {
        buf.writeln(
          '- ${item.itemName} (${item.portion}x) ${CurrencyFormatter.format(item.allocatedSubtotal)}',
        );
      }
      final subtotal = p.items.fold(0.0, (sum, i) => sum + i.allocatedSubtotal);
      buf.writeln(
        'Subtotal item ${p.name} ${CurrencyFormatter.format(subtotal)}',
      );
      buf.writeln();
    }

    buf.writeln('Total item ${CurrencyFormatter.format(detail.subtotal)}');
    buf.writeln(
      'Biaya tambahan (service/tax) ${CurrencyFormatter.format(extraCharges)}',
    );
    buf.writeln('Grand total ${CurrencyFormatter.format(detail.totalAmount)}');
    return buf.toString().trimRight();
  }

  @override
  Widget build(BuildContext context) {
    final summaryText = _buildSummaryText();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'COPY SUMMARY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownMocha,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: _buildSummaryText()),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Summary copied!'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.content_copy_rounded,
                      size: 18,
                      color: AppColors.primaryForest,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.brownMocha,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBeige,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      summaryText,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.brownEspresso,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
