import 'package:flutter/material.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_accounts_usecase.dart';

Future<Account?> showAccountPicker(
  BuildContext context, {
  Account? selected,
  int? excludeId,
}) {
  return showModalBottomSheet<Account>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.neutralCream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        _AccountPickerSheet(selected: selected, excludeId: excludeId),
  );
}

class _AccountPickerSheet extends StatefulWidget {
  final Account? selected;
  final int? excludeId;

  const _AccountPickerSheet({this.selected, this.excludeId});

  @override
  State<_AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends State<_AccountPickerSheet> {
  final GetAccountsUseCase _getAccounts = sl<GetAccountsUseCase>();

  List<Account> _accounts = [];
  Account? _selectedAccount;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.selected;
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    final result = await _getAccounts();
    result.fold((_) => setState(() => _isLoading = false), (accounts) {
      final filtered = widget.excludeId != null
          ? accounts.where((a) => a.id != widget.excludeId).toList()
          : accounts;
      setState(() {
        _accounts = filtered;
        _isLoading = false;
      });
    });
  }

  void _confirm() {
    Navigator.pop(context, _selectedAccount);
  }

  Map<AccountType, List<Account>> get _groupedAccounts {
    final map = <AccountType, List<Account>>{};
    for (final account in _accounts) {
      map.putIfAbsent(account.type, () => []).add(account);
    }
    return map;
  }

  String _typeLabel(AccountType type) {
    return switch (type) {
      AccountType.cash => 'Cash',
      AccountType.bankAccount => 'Bank Account',
      AccountType.eWallet => 'E-Wallet',
      AccountType.creditCard => 'Credit Card',
    };
  }

  IconData _typeIcon(AccountType type) {
    return switch (type) {
      AccountType.cash => Icons.payments_outlined,
      AccountType.bankAccount => Icons.account_balance_outlined,
      AccountType.eWallet => Icons.account_balance_wallet_outlined,
      AccountType.creditCard => Icons.credit_card_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            //  Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Account',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownEspresso,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: AppColors.brownDriftwood,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            //  Account List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryForest,
                      ),
                    )
                  : _accounts.isEmpty
                  ? const Center(
                      child: Text(
                        'No accounts found',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.brownMocha,
                        ),
                      ),
                    )
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      children: _buildGroupedList(),
                    ),
            ),

            //  Confirm Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: _selectedAccount != null ? _confirm : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Confirm Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildGroupedList() {
    final grouped = _groupedAccounts;
    final widgets = <Widget>[];

    for (final type in AccountType.values) {
      final accounts = grouped[type];
      if (accounts == null || accounts.isEmpty) continue;

      // Section header
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Row(
            children: [
              Icon(_typeIcon(type), size: 16, color: AppColors.brownMocha),
              const SizedBox(width: 8),
              Text(
                _typeLabel(type),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownMocha,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      );

      // Account cards
      widgets.add(
        Container(
          decoration: BoxDecoration(
            color: AppColors.neutralSand,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(accounts.length, (index) {
              final account = accounts[index];
              final isSelected = _selectedAccount?.id == account.id;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedAccount = account),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.neutralLinen
                        : Colors.transparent,
                    borderRadius: index == 0
                        ? const BorderRadius.vertical(top: Radius.circular(16))
                        : index == accounts.length - 1
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          account.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppColors.primaryForest,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(account.balance),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? AppColors.brownEspresso
                              : AppColors.brownMocha,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 22,
                          color: AppColors.primaryForest,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );

      widgets.add(const SizedBox(height: 12));
    }

    return widgets;
  }
}
