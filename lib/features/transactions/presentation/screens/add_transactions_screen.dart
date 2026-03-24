import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/calendar_date_picker.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/presentation/widgets/category_picker_sheet.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_picker_sheet.dart';
import 'package:pocketree/core/widgets/amount_numpad_sheet.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_event.dart';

enum _TransactionTab { expense, income, transfer }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  _TransactionTab _activeTab = _TransactionTab.expense;
  double _amount = 0;
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategoryObj;
  Account? _selectedAccountObj;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    if (_amount <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return;
    }
    if (_selectedAccountObj == null) {
      _showErrorSnackbar('Please select an account');
      return;
    }
    if (_activeTab != _TransactionTab.transfer && _selectedCategoryObj == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    final bloc = context.read<TransactionBloc>();
    if (_activeTab == _TransactionTab.transfer) {
      _showErrorSnackbar('Transfers are not yet supported in this screen');
      return;
    }

    final transactionType = _activeTab == _TransactionTab.expense
        ? TransactionType.expense
        : TransactionType.income;

    final event = TransactionCreateRequested(
      accountId: _selectedAccountObj!.id,
      type: transactionType,
      amount: _amount,
      date: _selectedDate,
      categoryId: _selectedCategoryObj?.id,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    bloc.add(event);
    GoRouter.of(context).pop();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            //  App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.primaryForest,
                    ),
                    onPressed: () => GoRouter.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Add Transaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownEspresso,
                    ),
                  ),
                ],
              ),
            ),

            //  Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 4),

                  //  Tab Selector
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.neutralSand,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: _TransactionTab.values.map((tab) {
                        final isActive = _activeTab == tab;
                        final label = switch (tab) {
                          _TransactionTab.expense => 'Expense',
                          _TransactionTab.income => 'Income',
                          _TransactionTab.transfer => 'Transfer',
                        };

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTab = tab),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.brownEspresso
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? AppColors.white
                                      : AppColors.brownMocha,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  //  Amount Display
                  GestureDetector(
                    onTap: _pickAmount,
                    child: Column(
                      children: [
                        Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brownMocha,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyFormatter.format(_amount),
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brownEspresso,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  //  Date Row
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _pickDate,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 22,
                            color: AppColors.primaryForest,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _formatDisplayDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brownEspresso,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: AppColors.neutralTaupe,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: AppColors.neutralTaupe.withValues(alpha: 0.3),
                  ),

                  //  Category Row
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _pickCategory,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 22,
                            color: AppColors.primaryForest,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedCategoryObj?.name ?? 'Select category',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: _selectedCategoryObj != null
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: _selectedCategoryObj != null
                                    ? AppColors.brownEspresso
                                    : AppColors.brownMocha,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: AppColors.neutralTaupe,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: AppColors.neutralTaupe.withValues(alpha: 0.3),
                  ),

                  //  Account Row
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _pickAccount,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 22,
                            color: AppColors.primaryForest,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _selectedAccountObj?.name ?? 'Select account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: _selectedAccountObj != null
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                                color: _selectedAccountObj != null
                                    ? AppColors.brownEspresso
                                    : AppColors.brownMocha,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: AppColors.neutralTaupe,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: AppColors.neutralTaupe.withValues(alpha: 0.3),
                  ),

                  //  Note Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          size: 22,
                          color: AppColors.primaryForest,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _noteController,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppColors.brownEspresso,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Write a note...',
                              hintStyle: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppColors.brownMocha,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              filled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: AppColors.neutralTaupe.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),

            //  Save Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryForest,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'SAVE TRANSACTION',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
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

  //  Logic Methods

  Future<void> _pickDate() async {
    final picked = await showCalendarDatePicker(
      context,
      initialDate: _selectedDate,
      maxDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDisplayDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final formatted = DateFormat('d MMM yyyy').format(date);
    return isToday ? 'Today, $formatted' : formatted;
  }

  Future<void> _pickAmount() async {
    final amount = await showAmountNumpad(context, initialValue: _amount);
    if (amount != null && amount > 0) {
      setState(() => _amount = amount);
    }
  }

  Future<void> _pickCategory() async {
    if (_activeTab == _TransactionTab.transfer) return;

    final categoryType = switch (_activeTab) {
      _TransactionTab.expense => CategoryType.expense,
      _TransactionTab.income => CategoryType.income,
      _TransactionTab.transfer => CategoryType.expense,
    };

    final picked = await showCategoryPicker(
      context,
      type: categoryType,
      selected: _selectedCategoryObj,
    );
    if (picked != null) {
      setState(() => _selectedCategoryObj = picked);
    }
  }

  Future<void> _pickAccount() async {
    final picked = await showAccountPicker(
      context,
      selected: _selectedAccountObj,
    );
    if (picked != null) {
      setState(() => _selectedAccountObj = picked);
    }
  }
}
