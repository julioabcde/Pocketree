import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/splitbill/presentation/models/charge_entry.dart';
import 'package:pocketree/features/splitbill/presentation/models/item_entry.dart';

class FormRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  final VoidCallback onTap;

  const FormRow({
    super.key,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.brownMocha),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    ),
  );
}

class BillItemRow extends StatelessWidget {
  final ItemEntry item;
  final VoidCallback onTap;

  const BillItemRow({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.neutralSand,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.primaryForest,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.isEmpty ? 'Unnamed item' : item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: item.name.isEmpty
                              ? AppColors.neutralTaupe
                              : AppColors.brownEspresso,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.quantity}x  ${_num(item.price)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.brownMocha,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _num(item.subtotal),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brownEspresso,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryForest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.neutralTaupe,
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          color: AppColors.neutralTaupe.withValues(alpha: 0.25),
        ),
      ],
    );
  }

  String _num(double amount) {
    final s = amount.toStringAsFixed(0);
    final buf = StringBuffer();
    final len = s.length;
    for (var i = 0; i < len; i++) {
      if (i > 0 && (len - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class BillChargeRow extends StatelessWidget {
  final ChargeEntry charge;
  final VoidCallback onTap;

  const BillChargeRow({super.key, required this.charge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final display = charge.isPercentage
        ? '${charge.value.toStringAsFixed(0)}%'
        : CurrencyFormatter.format(charge.value);

    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.neutralSand,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '%',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownDriftwood,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    charge.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brownEspresso,
                    ),
                  ),
                ),
                Text(
                  display,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.brownMocha,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.neutralTaupe,
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          color: AppColors.neutralTaupe.withValues(alpha: 0.25),
        ),
      ],
    );
  }
}

class NoteRow extends StatelessWidget {
  final String note;
  final VoidCallback onTap;

  const NoteRow({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Icon(Icons.notes_rounded, color: AppColors.brownMocha, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              note.isEmpty ? 'Add a note...' : note,
              style: TextStyle(
                fontSize: 15,
                color: note.isEmpty ? AppColors.neutralTaupe : AppColors.brownDriftwood,
              ),
            ),
          ),
          const Icon(Icons.edit, size: 18, color: AppColors.brownMocha),
        ],
      ),
    ),
  );
}

class AddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddRowButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryForest,
            ),
            child: const Icon(Icons.add, color: AppColors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryForest,
            ),
          ),
        ],
      ),
    ),
  );
}

class CreateBillBottomBar extends StatelessWidget {
  final double total;
  final VoidCallback onNext;

  const CreateBillBottomBar({super.key, required this.total, required this.onNext});

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.darkDeepPine,
    padding: EdgeInsets.only(
      left: 24,
      right: 24,
      top: 16,
      bottom: MediaQuery.of(context).padding.bottom + 16,
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TOTAL BILL',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.frost,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              CurrencyFormatter.format(total),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onNext,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: const Text(
            'NEXT',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryFern,
            foregroundColor: AppColors.white,
            minimumSize: const Size(0, 56),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
        ),
      ],
    ),
  );
}

class QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const QtyButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.neutralSand,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.brownEspresso, size: 20),
    ),
  );
}

class ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ToggleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryForest : AppColors.neutralSand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.white : AppColors.brownMocha,
        ),
      ),
    ),
  );
}
