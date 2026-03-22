import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_list_item.dart';

class AccountListSection extends StatelessWidget {
  final String title;
  final List<Account> accounts;
  final void Function(Account account) onAccountOptionsTap;

  const AccountListSection({
    super.key,
    required this.title,
    required this.accounts,
    required this.onAccountOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.primaryForest,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryForest,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Account items
        ...accounts.map(
          (account) => AccountListItem(
            account: account,
            onOptionsTap: () => onAccountOptionsTap(account),
          ),
        ),
      ],
    );
  }
}