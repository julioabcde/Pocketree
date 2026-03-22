import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';

class AccountListItem extends StatelessWidget {
  final Account account;
  final VoidCallback onOptionsTap;

  const AccountListItem({
    super.key,
    required this.account,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = switch (account.type) {
      AccountType.cash => 'Cash',
      AccountType.bankAccount => 'Bank Account',
      AccountType.eWallet => 'E-Wallet',
      AccountType.creditCard => 'Credit Card',
    };

    final typeIcon = switch (account.type) {
      AccountType.cash => Icons.payments_outlined,
      AccountType.bankAccount => Icons.account_balance_outlined,
      AccountType.eWallet => Icons.smartphone_outlined,
      AccountType.creditCard => Icons.credit_card_outlined,
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.neutralSand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  typeIcon,
                  color: AppColors.brownDriftwood,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),

              // Name + type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownEspresso,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.brownMocha,
                      ),
                    ),
                  ],
                ),
              ),

              // Balance
              Text(
                CurrencyFormatter.format(account.balance),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brownEspresso,
                ),
              ),
              const SizedBox(width: 4),

              // Dot indicator
              GestureDetector(
                onTap: onOptionsTap,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: AppColors.neutralTaupe,
                    size: 20,
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
    );
  }
}