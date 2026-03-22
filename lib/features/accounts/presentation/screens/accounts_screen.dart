import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_event.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_state.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_list_section.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_summary_card.dart';
import 'package:pocketree/features/accounts/presentation/widgets/create_account_sheet.dart';
import 'package:pocketree/features/accounts/presentation/widgets/edit_account_sheet.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountBloc>()..add(const AccountDataRequested()),
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: const Text('My Wallets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateSheet(context),
          ),
        ],
      ),
      body: BlocConsumer<AccountBloc, AccountState>(
        listener: (context, state) {
          if (state is AccountActionSuccess) {
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
        },
        builder: (context, state) {
          if (state is AccountLoading || state is AccountInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryForest),
            );
          }

          if (state is AccountError) {
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
                      onPressed: () => context.read<AccountBloc>().add(
                        const AccountDataRequested(),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AccountLoaded) {
            return Stack(
              children: [
                _buildContent(context, state),

                if (state.isPerformingAction)
                  Container(
                    color: AppColors.neutralCream.withValues(alpha: 0.6),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryForest,
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AccountLoaded state) {
    final cashAccounts = state.cashAccounts;
    final bankAccounts = state.bankAccounts;
    final eWalletAccounts = state.eWalletAccounts;
    final creditCardAccounts = state.creditCardAccounts;
    final isEmpty = state.accounts.isEmpty;

    return ListView(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 32),
      children: [
        // Summary Card
        AccountSummaryCard(summary: state.summary),

        // Cash Section
        if (cashAccounts.isNotEmpty) ...[
          const SizedBox(height: 28),
          AccountListSection(
            title: 'CASH',
            accounts: cashAccounts,
            onAccountOptionsTap: (account) =>
                _showAccountOptions(context, account),
          ),
        ],

        // Bank Account Section
        if (bankAccounts.isNotEmpty) ...[
          const SizedBox(height: 28),
          AccountListSection(
            title: 'BANK ACCOUNT',
            accounts: bankAccounts,
            onAccountOptionsTap: (account) =>
                _showAccountOptions(context, account),
          ),
        ],

        // E-Wallet Section
        if (eWalletAccounts.isNotEmpty) ...[
          const SizedBox(height: 28),
          AccountListSection(
            title: 'E-WALLET',
            accounts: eWalletAccounts,
            onAccountOptionsTap: (account) =>
                _showAccountOptions(context, account),
          ),
        ],

        // Credit Card Section
        if (creditCardAccounts.isNotEmpty) ...[
          const SizedBox(height: 28),
          AccountListSection(
            title: 'CREDIT CARDS',
            accounts: creditCardAccounts,
            onAccountOptionsTap: (account) =>
                _showAccountOptions(context, account),
          ),
        ],

        // Empty State
        if (isEmpty) ...[
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: AppColors.neutralTaupe,
                ),
                const SizedBox(height: 12),
                Text(
                  'No accounts yet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brownDriftwood,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + to create your first account',
                  style: TextStyle(fontSize: 14, color: AppColors.brownMocha),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showCreateSheet(BuildContext context) {
    final bloc = context.read<AccountBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: const CreateAccountSheet(),
        );
      },
    );
  }

  void _showAccountOptions(BuildContext context, Account account) {
    final bloc = context.read<AccountBloc>();

    showModalBottomSheet(
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
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutralTaupe,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Edit
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.brownDriftwood,
                  ),
                  title: const Text('Edit Account'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditSheet(context, bloc, account);
                  },
                ),

                // Delete
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFB3261E),
                  ),
                  title: const Text(
                    'Delete Account',
                    style: TextStyle(color: Color(0xFFB3261E)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, bloc, account);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context, AccountBloc bloc, Account account) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: EditAccountSheet(account: account),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AccountBloc bloc,
    Account account,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Account'),
          content: Text(
            'Are you sure you want to delete "${account.name}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                bloc.add(AccountDeleteRequested(accountId: account.id));
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFB3261E)),
              ),
            ),
          ],
        );
      },
    );
  }
}
