import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/calendar_date_picker.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/core/widgets/amount_numpad_sheet.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_picker_sheet.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/presentation/widgets/category_picker_sheet.dart';
import 'package:pocketree/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_event.dart';
import 'package:pocketree/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:pocketree/features/transactions/domain/entities/transaction_type.dart';

enum _RecurringTab { expense, income }

class AddRecurringScreen extends StatefulWidget {
  const AddRecurringScreen({super.key});

  @override
  State<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends State<AddRecurringScreen> {
  _RecurringTab _activeTab = _RecurringTab.expense;
  double _amount = 0;
  Category? _selectedCategory;
  Account? _selectedAccount;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _autoCreate = true;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _saveRecurring() {
    if (_amount <= 0) {
      _showErrorSnackbar('Please enter a valid amount');
      return;
    }
    if (_selectedAccount == null) {
      _showErrorSnackbar('Please select an account');
      return;
    }
    if (_selectedCategory == null) {
      _showErrorSnackbar('Please select a category');
      return;
    }

    final type = _activeTab == _RecurringTab.expense
        ? TransactionType.expense
        : TransactionType.income;

    context.read<RecurringBloc>().add(
          RecurringCreateRequested(
            accountId: _selectedAccount!.id,
            categoryId: _selectedCategory!.id,
            type: type,
            amount: _amount,
            frequency: _frequency,
            startDate: _startDate,
            endDate: _endDate,
            autoCreate: _autoCreate,
            note: _noteController.text.isEmpty ? null : _noteController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<RecurringBloc, RecurringState>(
        listener: (context, state) {
          if (state is RecurringActionSuccess) {
            GoRouter.of(context).pop(true);
          }
          if (state is RecurringError) {
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
                      'Recurring',
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
                    _buildTabSelector(),
                    const SizedBox(height: 32),
                    _buildAmountDisplay(),
                    const SizedBox(height: 40),
                    _buildCategoryRow(),
                    _buildDivider(),
                    _buildAccountRow(),
                    _buildDivider(),
                    _buildNoteRow(),
                    _buildDivider(),
                    const SizedBox(height: 28),
                    _buildScheduleSection(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

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
        children: _RecurringTab.values.map((tab) {
          final isActive = _activeTab == tab;
          final label = switch (tab) {
            _RecurringTab.expense => 'Expense',
            _RecurringTab.income => 'Income',
          };

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (tab == _activeTab) return;
                setState(() {
                  _activeTab = tab;
                  _selectedCategory = null;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.brownEspresso : Colors.transparent,
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

  //  Amount Display 

  Widget _buildAmountDisplay() {
    return GestureDetector(
      onTap: _pickAmount,
      child: Column(
        children: [
          const Text(
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
    );
  }

  //  Field Rows 

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
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedCategory?.name ?? 'Select category',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _selectedCategory != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: _selectedCategory != null
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
                  const Text(
                    'Account',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedAccount?.name ?? 'Select account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: _selectedAccount != null
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: _selectedAccount != null
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

  //  Schedule Section 

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SCHEDULE SETUP',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.brownMocha,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        _buildFrequencyRow(),
        _buildDivider(),
        _buildStartDateRow(),
        _buildDivider(),
        _buildEndDateRow(),
        _buildDivider(),
        _buildAutoCreateRow(),
        _buildDivider(),
      ],
    );
  }

  Widget _buildFrequencyRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickFrequency,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            const Icon(
              Icons.repeat_rounded,
              size: 22,
              color: AppColors.primaryForest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequency',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _frequencyLabel(_frequency),
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

  Widget _buildStartDateRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickStartDate,
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
                  const Text(
                    'Start Date',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDisplayDate(_startDate),
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

  Widget _buildEndDateRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _pickEndDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            const Icon(
              Icons.event_busy_outlined,
              size: 22,
              color: AppColors.primaryForest,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Date',
                    style: TextStyle(fontSize: 13, color: AppColors.brownMocha),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _endDate != null
                        ? DateFormat('d MMM yyyy').format(_endDate!)
                        : 'Never (Ongoing)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _endDate != null
                          ? AppColors.brownEspresso
                          : AppColors.brownMocha,
                    ),
                  ),
                ],
              ),
            ),
            if (_endDate != null)
              GestureDetector(
                onTap: () => setState(() => _endDate = null),
                child: const Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppColors.neutralTaupe,
                ),
              )
            else
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

  Widget _buildAutoCreateRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 22,
            color: AppColors.primaryForest,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-create transaction',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.brownEspresso,
                  ),
                ),
                Text(
                  'Automatically deduct from balance',
                  style: TextStyle(fontSize: 12, color: AppColors.brownMocha),
                ),
              ],
            ),
          ),
          Switch(
            value: _autoCreate,
            onChanged: (val) => setState(() => _autoCreate = val),
            activeThumbColor: AppColors.primaryForest,
            activeTrackColor: AppColors.primaryForest.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  //  Bottom Button ─

  Widget _buildBottomButton() {
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
            onPressed: _saveRecurring,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'SAVE RECURRING',
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
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 0.5,
      thickness: 0.5,
      color: AppColors.neutralTaupe.withValues(alpha: 0.3),
    );
  }

  //  Pickers 

  Future<void> _pickAmount() async {
    final amount = await showAmountNumpad(context, initialValue: _amount);
    if (amount != null && amount > 0) {
      setState(() => _amount = amount);
    }
  }

  Future<void> _pickCategory() async {
    final categoryType = _activeTab == _RecurringTab.expense
        ? CategoryType.expense
        : CategoryType.income;

    final picked = await showCategoryPicker(
      context,
      type: categoryType,
      selected: _selectedCategory,
    );
    if (picked != null) setState(() => _selectedCategory = picked);
  }

  Future<void> _pickAccount() async {
    final picked = await showAccountPicker(context, selected: _selectedAccount);
    if (picked != null) setState(() => _selectedAccount = picked);
  }

  Future<void> _pickFrequency() async {
    final picked = await showModalBottomSheet<RecurringFrequency>(
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
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.neutralTaupe,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...RecurringFrequency.values.map((freq) {
                  final isSelected = freq == _frequency;
                  return ListTile(
                    leading: Icon(
                      Icons.repeat_rounded,
                      color: isSelected
                          ? AppColors.primaryForest
                          : AppColors.brownMocha,
                    ),
                    title: Text(
                      _frequencyLabel(freq),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primaryForest
                            : AppColors.brownEspresso,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.primaryForest,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, freq),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) setState(() => _frequency = picked);
  }

  Future<void> _pickStartDate() async {
    final picked = await showCalendarDatePicker(
      context,
      initialDate: _startDate,
      maxDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _startDate.isAfter(_endDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showCalendarDatePicker(
      context,
      initialDate: _endDate ?? _startDate,
      minDate: _startDate,
      maxDate: DateTime(2100),
    );
    if (picked != null) {
      if (picked.isBefore(_startDate)) {
        _showErrorSnackbar('End date cannot be before start date');
        return;
      }
      setState(() => _endDate = picked);
    }
  }

  //  Helpers 

  String _frequencyLabel(RecurringFrequency freq) => switch (freq) {
        RecurringFrequency.daily => 'Daily',
        RecurringFrequency.weekly => 'Weekly',
        RecurringFrequency.monthly => 'Monthly',
        RecurringFrequency.yearly => 'Yearly',
      };

  String _formatDisplayDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final formatted = DateFormat('d MMM yyyy').format(date);
    return isToday ? 'Today, $formatted' : formatted;
  }
}
