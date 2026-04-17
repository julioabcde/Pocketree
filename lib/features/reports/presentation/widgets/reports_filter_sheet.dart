import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';

class ReportsFilterResult {
  final int? accountId;
  final String type;
  final String groupBy;
  final int topN;
  final int limit;

  const ReportsFilterResult({
    required this.accountId,
    required this.type,
    required this.groupBy,
    required this.topN,
    required this.limit,
  });
}

class ReportsFilterSheet extends StatefulWidget {
  const ReportsFilterSheet({
    super.key,
    required this.initial,
    required this.accounts,
    required this.isLoadingAccounts,
  });

  final ReportsFilterResult initial;
  final List<Account> accounts;
  final bool isLoadingAccounts;

  @override
  State<ReportsFilterSheet> createState() => _ReportsFilterSheetState();
}

class _ReportsFilterSheetState extends State<ReportsFilterSheet> {
  late int? _accountId;
  late String _type;
  late String _groupBy;
  late int _topN;
  late int _limit;

  @override
  void initState() {
    super.initState();
    _accountId = widget.initial.accountId;
    _type = widget.initial.type;
    _groupBy = widget.initial.groupBy;
    _topN = widget.initial.topN;
    _limit = widget.initial.limit;
  }

  void _reset() {
    setState(() {
      _accountId = null;
      _type = 'expense';
      _groupBy = 'day';
      _topN = 10;
      _limit = 5;
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      ReportsFilterResult(
        accountId: _accountId,
        type: _type,
        groupBy: _groupBy,
        topN: _topN,
        limit: _limit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHandle(),
          const SizedBox(height: 16),
          _buildHeader(),
          const SizedBox(height: 20),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionLabel('Account'),
                  const SizedBox(height: 8),
                  _buildAccountSelector(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Transaction type'),
                  const SizedBox(height: 8),
                  _buildTypeSelector(),
                  const SizedBox(height: 20),
                  _buildSectionLabel(
                    'Cashflow grouping',
                    hint: 'Affects the Cashflow chart only',
                  ),
                  const SizedBox(height: 8),
                  _buildGroupBySelector(),
                  const SizedBox(height: 20),
                  _buildSectionLabel(
                    'Top categories',
                    hint: 'Number of items in Category Breakdown',
                  ),
                  const SizedBox(height: 8),
                  _buildStepper(
                    value: _topN,
                    onChanged: (v) => setState(() => _topN = v),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel(
                    'Top transactions',
                    hint: 'Number of rows in Top Transactions',
                  ),
                  const SizedBox(height: 8),
                  _buildStepper(
                    value: _limit,
                    onChanged: (v) => setState(() => _limit = v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.neutralTaupe,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Filters',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
        ),
        TextButton(
          onPressed: _reset,
          child: const Text(
            'Reset',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.brownMocha,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.brownEspresso,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 2),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.brownMocha,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSelector() {
    if (widget.isLoadingAccounts) {
      return Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.neutralSand.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryForest,
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.accounts.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _chip(
              label: 'All accounts',
              selected: _accountId == null,
              onTap: () => setState(() => _accountId = null),
            );
          }
          final account = widget.accounts[index - 1];
          return _chip(
            label: account.name,
            selected: _accountId == account.id,
            onTap: () => setState(() => _accountId = account.id),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return _segmented(
      options: const [
        ('expense', 'Expense'),
        ('income', 'Income'),
      ],
      selected: _type,
      onChanged: (v) => setState(() => _type = v),
    );
  }

  Widget _buildGroupBySelector() {
    return _segmented(
      options: const [
        ('day', 'Day'),
        ('week', 'Week'),
        ('month', 'Month'),
      ],
      selected: _groupBy,
      onChanged: (v) => setState(() => _groupBy = v),
    );
  }

  Widget _buildStepper({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.neutralSand.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          _stepperButton(
            icon: Icons.remove_rounded,
            enabled: value > 1,
            onTap: () => onChanged(value - 1),
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.brownEspresso,
              ),
            ),
          ),
          _stepperButton(
            icon: Icons.add_rounded,
            enabled: value < 20,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: enabled
          ? AppColors.primaryForest
          : AppColors.neutralTaupe.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: AppColors.white),
        ),
      ),
    );
  }

  Widget _segmented({
    required List<(String, String)> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutralSand.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option.$1 == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(option.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brownEspresso
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  option.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.white
                        : AppColors.brownMocha,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected
          ? AppColors.brownEspresso
          : AppColors.neutralSand.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: selected
              ? AppColors.brownEspresso
              : AppColors.neutralTaupe.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.white : AppColors.brownMocha,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _apply,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryForest,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Apply filters',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
