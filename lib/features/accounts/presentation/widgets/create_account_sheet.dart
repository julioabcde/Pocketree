import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_event.dart';

class CreateAccountSheet extends StatefulWidget {
  const CreateAccountSheet({super.key});

  @override
  State<CreateAccountSheet> createState() => _CreateAccountSheetState();
}

class _CreateAccountSheetState extends State<CreateAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  AccountType _selectedType = AccountType.cash;

  bool _hasSubmitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!_hasSubmitted) return null;
    if (value == null || value.trim().isEmpty) return 'Account name is required';
    if (value.trim().length > 100) return 'Name must be 100 characters or less';
    return null;
  }

  String? _validateBalance(String? value) {
    if (!_hasSubmitted) return null;
    if (value == null || value.trim().isEmpty) return null;

    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return 'Balance cannot be negative';

    if (value.contains('.')) {
      final decimals = value.split('.').last;
      if (decimals.length > 2) return 'Maximum 2 decimal places';
    }

    return null;
  }

  void _submit() {
    setState(() => _hasSubmitted = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final balanceText = _balanceController.text.trim();
    final balance =
        balanceText.isNotEmpty ? double.tryParse(balanceText) : null;

    Navigator.pop(context);
    context.read<AccountBloc>().add(AccountCreateRequested(
          name: name,
          type: _selectedType,
          initialBalance: balance,
        ));
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
              'Create Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.brownEspresso,
              ),
            ),
            const SizedBox(height: 20),

            // Account Name
            const Text(
              'Account Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDriftwood,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              autovalidateMode: _hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              validator: _validateName,
              decoration: const InputDecoration(
                hintText: 'e.g., BCA Savings',
              ),
            ),
            const SizedBox(height: 16),

            // Account Type
            const Text(
              'Account Type',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDriftwood,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.neutralSand,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AccountType>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: AppColors.white,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.brownMocha,
                  ),
                  items: AccountType.values.map((type) {
                    final label = switch (type) {
                      AccountType.cash => 'Cash',
                      AccountType.bankAccount => 'Bank Account',
                      AccountType.eWallet => 'E-Wallet',
                      AccountType.creditCard => 'Credit Card',
                    };
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        label,
                        style: const TextStyle(color: AppColors.brownEspresso),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Initial Balance
            const Text(
              'Initial Balance (optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDriftwood,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _balanceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              autovalidateMode: _hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              validator: _validateBalance,
              decoration: const InputDecoration(
                hintText: '0',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryForest.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}