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
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:pocketree/features/transactions/presentation/widgets/source_account_card.dart';

enum _TransactionTab { income, expense, transfer }

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
  Account? _selectedToAccountObj;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  //  Reset

  void _resetSelections() {
    setState(() {
      _amount = 0;
      _selectedDate = DateTime.now();
      _selectedCategoryObj = null;
      _selectedAccountObj = null;
      _selectedToAccountObj = null;
      _noteController.clear();
    });
  }

  //  Save

  void _saveTransaction() {
    if (_amount <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return;
    }

    final bloc = context.read<TransactionBloc>();

    // Transfer mode
    if (_activeTab == _TransactionTab.transfer) {
      if (_selectedAccountObj == null) {
        _showErrorSnackbar('Please select a source account');
        return;
      }
      if (_selectedToAccountObj == null) {
        _showErrorSnackbar('Please select a destination account');
        return;
      }
      if (_selectedAccountObj!.id == _selectedToAccountObj!.id) {
        _showErrorSnackbar('Source and destination must be different');
        return;
      }

      bloc.add(
        TransactionTransferRequested(
          fromAccountId: _selectedAccountObj!.id,
          toAccountId: _selectedToAccountObj!.id,
          amount: _amount,
          date: _selectedDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
      return;
    }

    // Income / Expense
    if (_selectedAccountObj == null) {
      _showErrorSnackbar('Please select an account');
      return;
    }
    if (_selectedCategoryObj == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    final transactionType = _activeTab == _TransactionTab.expense
        ? TransactionType.expense
        : TransactionType.income;

    bloc.add(
      TransactionCreateRequested(
        accountId: _selectedAccountObj!.id,
        type: transactionType,
        amount: _amount,
        date: _selectedDate,
        categoryId: _selectedCategoryObj?.id,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  //  Build

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionActionSuccess) {
            GoRouter.of(context).pop(true);
          }

          if (state is TransactionError) {
            _showErrorSnackbar(state.message);
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
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

              // Scrollable Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 4),

                    // Tab Selector (shared)
                    _buildTabSelector(),

                    const SizedBox(height: 32),

                    // Conditional layout
                    if (_activeTab == _TransactionTab.transfer)
                      ..._buildTransferFields()
                    else
                      ..._buildIncomeExpenseFields(),
                  ],
                ),
              ),

              // Save Button
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  //  Tab Selector

  Widget _buildTabSelector() {
    return Container(
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
              onTap: () {
                if (tab == _activeTab) return;
                _activeTab = tab;
                _resetSelections();
              },
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
                    color: isActive ? AppColors.white : AppColors.brownMocha,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  //  Income / Expense Fields

  List<Widget> _buildIncomeExpenseFields() {
    return [
      // Amount Display
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

      // Date
      _buildDateRow(),
      _buildDivider(),

      // Category
      _buildCategoryRow(),
      _buildDivider(),

      // Account
      _buildAccountRow(),
      _buildDivider(),

      // Note
      _buildNoteRow(),
      _buildDivider(),
    ];
  }

  //  Transfer Fields

  List<Widget> _buildTransferFields() {
    return [
      // Source Account Card
      SourceAccountCard(account: _selectedAccountObj, onTap: _pickAccount),
      const SizedBox(height: 28),

      // Amount Row
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pickAmount,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 22,
                color: AppColors.primaryForest,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brownMocha,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(_amount),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownEspresso,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 20,
                color: AppColors.neutralTaupe,
              ),
            ],
          ),
        ),
      ),
      _buildDivider(),

      // Transfer To Row
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pickToAccount,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                size: 22,
                color: AppColors.primaryForest,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transfer to',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.brownMocha,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedToAccountObj?.name ?? 'Select destination',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: _selectedToAccountObj != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _selectedToAccountObj != null
                            ? AppColors.brownEspresso
                            : AppColors.brownMocha,
                      ),
                    ),
                  ],
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
      _buildDivider(),

      // Date (shared)
      _buildDateRow(),
      _buildDivider(),

      // Note (shared)
      _buildNoteRow(),
      _buildDivider(),
    ];
  }

  //  Shared Row Builders

  Widget _buildDateRow() {
    return GestureDetector(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDisplayDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.brownEspresso,
                    ),
                  ),
                ],
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
    );
  }

  Widget _buildCategoryRow() {
    return GestureDetector(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 2),
                  Text(
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
                ],
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
    );
  }

  Widget _buildAccountRow() {
    return GestureDetector(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  Text(
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
                ],
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
    );
  }

  Widget _buildNoteRow() {
    return Padding(
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
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      color: AppColors.neutralTaupe.withValues(alpha: 0.3),
    );
  }

  //  Bottom Button

  Widget _buildBottomButton() {
    final isTransfer = _activeTab == _TransactionTab.transfer;

    return Padding(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isTransfer ? 'TRANSFER FUNDS' : 'SAVE TRANSACTION',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //  Picker Logic

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
      setState(() {
        _selectedAccountObj = picked;

        if (_selectedToAccountObj?.id == picked.id) {
          _selectedToAccountObj = null;
        }
      });
    }
  }

  Future<void> _pickToAccount() async {
    final picked = await showAccountPicker(
      context,
      selected: _selectedToAccountObj,
      excludeId: _selectedAccountObj?.id,
    );
    if (picked != null) {
      setState(() => _selectedToAccountObj = picked);
    }
  }
}
