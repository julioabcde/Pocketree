import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/entities/account_type.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:pocketree/features/accounts/presentation/bloc/account_event.dart';

class EditAccountSheet extends StatefulWidget {
  final Account account;

  const EditAccountSheet({super.key, required this.account});

  @override
  State<EditAccountSheet> createState() => _EditAccountSheetState();
}

class _EditAccountSheetState extends State<EditAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late AccountType _selectedType;

  bool _hasSubmitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _selectedType = widget.account.type;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!_hasSubmitted) return null;
    if (value == null || value.trim().isEmpty) return 'Account name is required';
    if (value.trim().length > 100) return 'Name must be 100 characters or less';
    return null;
  }

  void _submit() {
    setState(() => _hasSubmitted = true);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();

    final newName = name != widget.account.name ? name : null;
    final newType = _selectedType != widget.account.type ? _selectedType : null;

    if (newName == null && newType == null) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context);
    context.read<AccountBloc>().add(AccountUpdateRequested(
          accountId: widget.account.id,
          name: newName,
          type: newType,
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
              'Edit Account',
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
            const SizedBox(height: 24),

            // Save Button
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
                    'Save Changes',
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