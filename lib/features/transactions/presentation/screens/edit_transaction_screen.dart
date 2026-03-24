import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/calendar_date_picker.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/core/widgets/amount_numpad_sheet.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/domain/usecases/get_account_by_id_usecase.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_picker_sheet.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/domain/usecases/get_category_by_id_usecase.dart';
import 'package:pocketree/features/categories/presentation/widgets/category_picker_sheet.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:pocketree/features/transactions/presentation/bloc/transaction_state.dart';

enum _TransactionTab { expense, income, transfer }

class EditTransactionScreen extends StatefulWidget {
  final Transaction transaction;

  const EditTransactionScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late _TransactionTab _activeTab;
  late double _amount;
  late DateTime _selectedDate;
  Category? _selectedCategoryObj;
  Account? _selectedAccountObj;
  late final TextEditingController _noteController;

  final GetAccountByIdUseCase _getAccountById = sl<GetAccountByIdUseCase>();
  final GetCategoryByIdUseCase _getCategoryById = sl<GetCategoryByIdUseCase>();

  bool get _isTransferTransaction => widget.transaction.isTransfer;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.transaction.isTransfer
        ? _TransactionTab.transfer
        : widget.transaction.type == TransactionType.expense
        ? _TransactionTab.expense
        : _TransactionTab.income;
    _amount = widget.transaction.amount;
    _selectedDate = widget.transaction.date;
    _noteController = TextEditingController(text: widget.transaction.note ?? '');
    _loadInitialSelections();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialSelections() async {
    final accountResult = await _getAccountById(widget.transaction.accountId);
    if (!mounted) return;

    accountResult.fold(
      (_) {},
      (account) => _selectedAccountObj = account,
    );

    final categoryId = widget.transaction.categoryId;
    if (categoryId != null) {
      final categoryResult = await _getCategoryById(categoryId);
      if (!mounted) return;
      categoryResult.fold(
        (_) {},
        (category) => _selectedCategoryObj = category,
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _saveTransaction() {
    if (_amount <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return;
    }

    if (_isTransferTransaction) {
      _showErrorSnackbar('Transfer transactions cannot be edited');
      return;
    }

    if (_selectedCategoryObj == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    final bloc = context.read<TransactionBloc>();

    final event = TransactionUpdateRequested(
      transactionId: widget.transaction.id,
      accountId: _selectedAccountObj?.id,
      amount: _amount,
      date: _selectedDate,
      categoryId: _selectedCategoryObj?.id,
      note: _noteController.text.isEmpty ? null : _noteController.text,
    );

    bloc.add(event);
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
                    'Edit Transaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownEspresso,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 4),
                  Opacity(
                    opacity: 0.7,
                    child: Container(
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
                          child: IgnorePointer(
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
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _isTransferTransaction ? null : _pickAmount,
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
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _isTransferTransaction ? null : _pickDate,
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
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: _isTransferTransaction
                                ? AppColors.neutralTaupe.withValues(alpha: 0.5)
                                : AppColors.neutralTaupe,
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
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _isTransferTransaction ? null : _pickCategory,
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
                              _selectedCategoryObj?.name ??
                                  (widget.transaction.categoryId != null
                                      ? 'Category #${widget.transaction.categoryId}'
                                      : 'Select category'),
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
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: _isTransferTransaction
                                ? AppColors.neutralTaupe.withValues(alpha: 0.5)
                                : AppColors.neutralTaupe,
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
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _isTransferTransaction ? null : _pickAccount,
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
                              _selectedAccountObj?.name ??
                                  'Account #${widget.transaction.accountId}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.brownEspresso,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: _isTransferTransaction
                                ? AppColors.neutralTaupe.withValues(alpha: 0.5)
                                : AppColors.neutralTaupe,
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
                            enabled: !_isTransferTransaction,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    final isLoading =
                        state is TransactionLoaded && state.isPerformingAction;

                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: _isTransferTransaction
                            ? AppColors.neutralTaupe
                            : AppColors.primaryForest,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: (_isTransferTransaction || isLoading)
                            ? null
                            : _saveTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                _isTransferTransaction
                                    ? 'TRANSFER CANNOT BE EDITED'
                                    : 'UPDATE TRANSACTION',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showCalendarDatePicker(
      context,
      initialDate: _selectedDate,
      maxDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
    if (_isTransferTransaction) {
      return;
    }

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
    if (_isTransferTransaction) {
      return;
    }

    final picked = await showAccountPicker(
      context,
      selected: _selectedAccountObj,
    );

    if (picked != null) {
      setState(() => _selectedAccountObj = picked);
    }
  }

}
