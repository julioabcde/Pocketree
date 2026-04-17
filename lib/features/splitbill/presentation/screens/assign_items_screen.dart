import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/snackbar_helper.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pocketree/features/auth/presentation/bloc/auth_state.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_item.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_detail_bloc.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_detail_event.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_detail_state.dart';
import 'package:pocketree/features/accounts/domain/entities/account.dart';
import 'package:pocketree/features/accounts/presentation/widgets/account_picker_sheet.dart';
import 'package:pocketree/features/splitbill/presentation/models/participant.dart';
import 'package:pocketree/features/splitbill/presentation/widgets/assign_items_widgets.dart';


class AssignItemsScreen extends StatefulWidget {
  final int billId;
  final bool isNewBill;

  const AssignItemsScreen({
    super.key,
    required this.billId,
    required this.isNewBill,
  });

  @override
  State<AssignItemsScreen> createState() => _AssignItemsScreenState();
}

class _AssignItemsScreenState extends State<AssignItemsScreen> {
  AssignMode _mode = AssignMode.equal;

  final List<Participant> _participants = [];
  int _payerIndex = -1;
  int _selectedIndex = 0;

  final Map<int, Set<int>> _itemAssignments = {};

  Account? _selectedAccount;

  bool _itemsInitialised = false;


  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _participants.add(Participant(
        name: authState.user.name,
        isPayer: true,
        userId: authState.user.id,
      ));
      _payerIndex = 0;
      _selectedIndex = 0;
    }

    context.read<SplitBillDetailBloc>().add(
      SplitBillDetailRequested(billId: widget.billId),
    );
  }

  void _initItemAssignments(List<SplitBillItem> items) {
    if (_itemsInitialised) return;
    _itemsInitialised = true;
    for (final item in items) {
      _itemAssignments[item.id] = {};
    }
  }


  void _addParticipant() async {
    final name = await _showAddParticipantDialog();
    if (name == null || name.trim().isEmpty) return;
    setState(() {
      _participants.add(Participant(name: name.trim()));
      _selectedIndex = _participants.length - 1;
    });
  }

  void _selectParticipant(int index) {
    setState(() => _selectedIndex = index);
  }

  void _setAsPayer(int index) {
    setState(() {
      for (int i = 0; i < _participants.length; i++) {
        _participants[i] = _participants[i].copyWith(isPayer: i == index);
      }
      _payerIndex = index;
    });
  }

  void _removeParticipant(int index) {
    if (index == _payerIndex) {
      showErrorSnackBar(
        context,
        'Set another participant as payer before removing this one',
      );
      return;
    }
    setState(() {
      for (final set in _itemAssignments.values) {
        set.remove(index);
        final above = set.where((i) => i > index).toList();
        for (final i in above) {
          set.remove(i);
          set.add(i - 1);
        }
      }
      _participants.removeAt(index);

      if (_payerIndex == index) {
        _payerIndex = -1;
      } else if (_payerIndex > index) {
        _payerIndex--;
      }

      if (_participants.isEmpty) {
        _selectedIndex = 0;
      } else if (_selectedIndex >= _participants.length) {
        _selectedIndex = _participants.length - 1;
      }
    });
  }


  void _toggleItemForSelected(int itemId) {
    if (_mode != AssignMode.byItem) return;
    if (_participants.isEmpty) return;
    setState(() {
      final set = _itemAssignments[itemId]!;
      if (set.contains(_selectedIndex)) {
        set.remove(_selectedIndex);
      } else {
        set.add(_selectedIndex);
      }
    });
  }

  void _resetAssignments() {
    setState(() {
      for (final key in _itemAssignments.keys) {
        _itemAssignments[key] = {};
      }
    });
  }


  bool _itemChecked(int itemId) {
    if (_mode == AssignMode.equal) return true;
    return _itemAssignments[itemId]?.contains(_selectedIndex) ?? false;
  }

  bool get _allItemsAssigned {
    if (_mode == AssignMode.equal) return true;
    return _itemAssignments.values.every((s) => s.isNotEmpty);
  }

  bool get _canFinish {
    if (_participants.isEmpty) return false;
    if (_payerIndex == -1) return false;
    final hasNonPayer = _participants.any((p) => !p.isPayer);
    return hasNonPayer && _allItemsAssigned;
  }

  double _totalAssigned(List<SplitBillItem> items, double subtotal) {
    if (_mode == AssignMode.equal) return subtotal;
    return items
        .where((item) => (_itemAssignments[item.id]?.isNotEmpty ?? false))
        .fold(0.0, (sum, item) => sum + item.price * item.quantity);
  }


  void _finish(List<SplitBillItem> items, double totalAmount) {
    if (!_canFinish) return;

    final participantRecords = _participants
        .asMap()
        .entries
        .map(
          (e) => (
            name: e.value.name,
            isPayer: e.key == _payerIndex,
            paidAmount: e.key == _payerIndex ? totalAmount : 0.0,
            userId: e.value.userId,
          ),
        )
        .toList();

    List<
      ({
        int participantIndex,
        List<int>? itemIds,
        double? customAmount,
        Map<String, int>? sharePortions,
      })
    >?
    shares;

    if (_mode == AssignMode.byItem) {
      final perParticipant = <int, List<int>>{};
      for (final entry in _itemAssignments.entries) {
        for (final pi in entry.value) {
          perParticipant.putIfAbsent(pi, () => []).add(entry.key);
        }
      }

      shares = perParticipant.entries.map((e) {
        final itemIds = e.value;
        return (
          participantIndex: e.key,
          itemIds: itemIds,
          customAmount: null,
          sharePortions: <String, int>{
            for (final id in itemIds) id.toString(): 1,
          },
        );
      }).toList();
    }

    context.read<SplitBillDetailBloc>().add(
      SplitBillCalculateRequested(
        participants: participantRecords,
        shares: shares,
        accountId: _selectedAccount?.id,
      ),
    );
  }


  Future<void> _pickAccount() async {
    final picked = await showAccountPicker(context, selected: _selectedAccount);
    if (picked != null) setState(() => _selectedAccount = picked);
  }


  Future<String?> _showAddParticipantDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Participant'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryForest,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(ctrl.text),
            child: const Text(
              'Add',
              style: TextStyle(color: AppColors.primaryForest),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SplitBillDetailBloc, SplitBillDetailState>(
      listener: (context, state) {
        if (state is SplitBillDetailLoaded) {
          _initItemAssignments(state.detail.items);
        }
        if (state is SplitBillDetailActionSuccess) {
          if (widget.isNewBill) {
            GoRouter.of(
              context,
            ).pushReplacement('/splitbill-detail', extra: widget.billId);
          } else {
            GoRouter.of(context).pop();
          }
        }
        if (state is SplitBillDetailError) {
          showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is SplitBillDetailLoading ||
            (state is SplitBillDetailLoaded && state.isPerformingAction);

        final detail = state is SplitBillDetailLoaded ? state.detail : null;
        final items = detail?.items ?? <SplitBillItem>[];

        return Scaffold(
          backgroundColor: AppColors.scaffoldBeige,
          appBar: _buildAppBar(),
          body: isLoading && items.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryForest,
                  ),
                )
              : _buildBody(
                  items,
                  isLoading,
                  detail?.subtotal ?? 0,
                  detail?.totalAmount ?? 0,
                ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.scaffoldBeige,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () => GoRouter.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.primaryForest,
        ),
      ),
      title: const Text(
        'Assign Items',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryForest,
        ),
      ),
      centerTitle: false,
      actions: [
        TextButton(
          onPressed: _resetAssignments,
          child: const Text(
            'RESET',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryForest,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    List<SplitBillItem> items,
    bool isLoading,
    double subtotal,
    double totalAmount,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: AssignModeToggle(
                  mode: _mode,
                  onChanged: (m) => setState(() => _mode = m),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LINK EXPENSE (OPTIONAL)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownMocha,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: _pickAccount,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.neutralTaupe),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.primaryForest,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _selectedAccount?.name ??
                                    'Tap to link an account',
                                style: TextStyle(
                                  color: _selectedAccount != null
                                      ? AppColors.brownEspresso
                                      : AppColors.brownMocha,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (_selectedAccount != null)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedAccount = null),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: AppColors.brownMocha,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PARTICIPANTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownMocha,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ParticipantRow(
                      participants: _participants,
                      payerIndex: _payerIndex,
                      selectedIndex: _selectedIndex,
                      onAdd: _addParticipant,
                      onTap: _selectParticipant,
                      onLongPress: _setAsPayer,
                      onRemove: _removeParticipant,
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
                child: const Text(
                  'RECEIPT ITEMS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brownMocha,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final item = items[i];
                  final checked = _itemChecked(item.id);
                  final assignees = _mode == AssignMode.equal
                      ? List.generate(_participants.length, (i) => i)
                      : (_itemAssignments[item.id]?.toList() ?? []);

                  return AssignItemRow(
                    item: item,
                    checked: checked,
                    assignees: assignees,
                    participants: _participants,
                    showDivider: i < items.length - 1,
                    onTap: () => _toggleItemForSelected(item.id),
                  );
                }, childCount: items.length),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),

        if (isLoading && items.isNotEmpty)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.15),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryForest,
                ),
              ),
            ),
          ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AssignBottomBar(
            totalAssigned: _totalAssigned(items, subtotal),
            billSubtotal: subtotal,
            canFinish: _canFinish,
            onFinish: () => _finish(items, totalAmount),
          ),
        ),
      ],
    );
  }
}
