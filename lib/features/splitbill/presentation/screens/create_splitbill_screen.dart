import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/snackbar_helper.dart';
import 'package:pocketree/core/utils/calendar_date_picker.dart';
import 'package:pocketree/features/splitbill/presentation/args/assign_items_args.dart';
import 'package:pocketree/features/splitbill/presentation/args/create_splitbill_args.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_bloc.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_event.dart';
import 'package:pocketree/features/splitbill/presentation/bloc/splitbill_state.dart';
import 'package:pocketree/features/splitbill/presentation/models/charge_entry.dart';
import 'package:pocketree/features/splitbill/presentation/models/item_entry.dart';
import 'package:pocketree/features/splitbill/presentation/widgets/create_bill_widgets.dart';


class CreateSplitbillScreen extends StatefulWidget {
  const CreateSplitbillScreen({super.key, this.args});

  final CreateSplitbillArgs? args;

  @override
  State<CreateSplitbillScreen> createState() => _CreateSplitbillScreenState();
}

class _CreateSplitbillScreenState extends State<CreateSplitbillScreen> {
  String _title = '';
  DateTime _selectedDate = DateTime.now();
  String _note = '';

  final List<ItemEntry> _items = [];
  final List<ChargeEntry> _charges = [];

  @override
  void initState() {
    super.initState();
    final source = widget.args?.source;

    final prefill = widget.args?.prefillItems;
    if (prefill != null && prefill.isNotEmpty) {
      _items.addAll(
        prefill.map(
          (e) => ItemEntry(
            id: _uniqueId(),
            name: e.name,
            price: e.price,
            quantity: e.qty,
            isFromOCR: e.isFromOCR,
            scanSource: e.isFromOCR ? source : null,
          ),
        ),
      );
    }

    final prefillCharges = widget.args?.prefillCharges;
    if (prefillCharges != null && prefillCharges.isNotEmpty) {
      _charges.addAll(
        prefillCharges.map(
          (c) => ChargeEntry(
            id: _uniqueId(),
            type: c.type,
            name: c.name,
            value: c.amount,
            isPercentage: false,
          ),
        ),
      );
    }
  }


  double get _itemsSubtotal => _items.fold(0.0, (sum, i) => sum + i.subtotal);

  double get _chargesTotal =>
      _charges.fold(0.0, (sum, c) => sum + c.computedAmount(_itemsSubtotal));

  double get _totalBill => _itemsSubtotal + _chargesTotal;

  static int _idCounter = 0;
  String _uniqueId() => 'entry_${++_idCounter}';


  void _showError(String message) {
    showErrorSnackBar(context, message);
  }

  bool _validate() {
    if (_title.trim().isEmpty) {
      _showError('Please enter a bill name');
      return false;
    }
    if (_items.isEmpty) {
      _showError('Please add at least one item');
      return false;
    }
    if (_items.any((i) => !i.isValid)) {
      _showError('All items must have a name and a price greater than 0');
      return false;
    }
    return true;
  }

  void _submit() {
    if (!_validate()) return;

    context.read<SplitBillBloc>().add(
      SplitBillCreateRequested(
        title: _title.trim(),
        date: _selectedDate,
        items: _items
            .map(
              (i) =>
                  (name: i.name.trim(), price: i.price, quantity: i.quantity),
            )
            .toList(),
        charges: _charges
            .map(
              (c) => (
                type: c.type,
                name: c.name.trim(),
                amount: c.computedAmount(_itemsSubtotal),
              ),
            )
            .toList(),
        note: _note.trim().isEmpty ? null : _note.trim(),
      ),
    );
  }


  Future<void> _showEditTitleDialog() async {
    final controller = TextEditingController(text: _title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Bill Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Team Dinner'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _title = result);
  }

  Future<void> _pickDate() async {
    final picked = await showCalendarDatePicker(
      context,
      initialDate: _selectedDate,
      maxDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _showEditNoteDialog() async {
    final controller = TextEditingController(text: _note);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Add a note...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _note = result);
  }


  Future<void> _showItemSheet({ItemEntry? existing}) async {
    final isNew = existing == null;
    final entry =
        existing ??
        ItemEntry(id: _uniqueId(), name: '', price: 0.0, quantity: 1);

    final nameCtrl = TextEditingController(text: entry.name);
    final priceCtrl = TextEditingController(
      text: entry.price > 0 ? entry.price.toStringAsFixed(0) : '',
    );
    var qty = entry.quantity;
    var submitted = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DragHandle(),
              Text(
                isNew ? 'Add Item' : 'Edit Item',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownEspresso,
                ),
              ),
              const SizedBox(height: 20),

              const _FieldLabel('Item Name'),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                autofocus: isNew,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g. Nasi Goreng',
                  errorText: submitted && nameCtrl.text.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
              ),
              const SizedBox(height: 14),

              const _FieldLabel('Unit Price (Rp)'),
              const SizedBox(height: 6),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: 'Rp ',
                  errorText:
                      submitted && (double.tryParse(priceCtrl.text) ?? 0) <= 0
                      ? 'Enter a valid price'
                      : null,
                ),
              ),
              const SizedBox(height: 14),

              const _FieldLabel('Quantity'),
              const SizedBox(height: 10),
              Row(
                children: [
                  QtyButton(
                    icon: Icons.remove,
                    onTap: () {
                      if (qty > 1) setSheet(() => qty--);
                    },
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '$qty',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brownEspresso,
                    ),
                  ),
                  const SizedBox(width: 24),
                  QtyButton(
                    icon: Icons.add,
                    onTap: () => setSheet(() => qty++),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  if (!isNew) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _items.remove(entry));
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorRed,
                          side: const BorderSide(color: AppColors.errorRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 52),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        setSheet(() => submitted = true);
                        final name = nameCtrl.text.trim();
                        final price = double.tryParse(priceCtrl.text) ?? 0;
                        if (name.isEmpty || price <= 0) return;

                        setState(() {
                          final updated = entry.copyWith(
                            name: name,
                            price: price,
                            quantity: qty,
                            isFromOCR: false,
                          );
                          if (isNew) {
                            _items.add(updated);
                          } else {
                            final idx = _items.indexWhere((e) => e.id == entry.id);
                            if (idx != -1) _items[idx] = updated;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryForest,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: const Text(
                        'Save Item',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _showChargeSheet({ChargeEntry? existing}) async {
    final isNew = existing == null;
    final entry =
        existing ??
        ChargeEntry(
          id: _uniqueId(),
          type: 'tax',
          name: 'Tax',
          value: 0.0,
          isPercentage: true,
        );

    final nameCtrl = TextEditingController(text: entry.name);
    final valueCtrl = TextEditingController(
      text: entry.value > 0 ? entry.value.toStringAsFixed(0) : '',
    );
    var type = entry.type;
    var isPercentage = entry.isPercentage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DragHandle(),
              Text(
                isNew ? 'Add Charge' : 'Edit Charge',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brownEspresso,
                ),
              ),
              const SizedBox(height: 20),

              const _FieldLabel('Type'),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.neutralSand,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: type,
                    isExpanded: true,
                    dropdownColor: AppColors.white,
                    items: const [
                      DropdownMenuItem(value: 'tax', child: Text('Tax')),
                      DropdownMenuItem(
                        value: 'service',
                        child: Text('Service Charge'),
                      ),
                      DropdownMenuItem(value: 'tip', child: Text('Tip')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setSheet(() {
                        type = v;
                        if (nameCtrl.text.isEmpty) {
                          nameCtrl.text = switch (v) {
                            'tax' => 'Tax',
                            'service' => 'Service Charge',
                            'tip' => 'Tip',
                            _ => '',
                          };
                        }
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),

              const _FieldLabel('Display Name'),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. PPN 11%'),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  const _FieldLabel('Value Type'),
                  const Spacer(),
                  ToggleChip(
                    label: '%',
                    selected: isPercentage,
                    onTap: () => setSheet(() => isPercentage = true),
                  ),
                  const SizedBox(width: 8),
                  ToggleChip(
                    label: 'Rp',
                    selected: !isPercentage,
                    onTap: () => setSheet(() => isPercentage = false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: valueCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: isPercentage ? null : 'Rp ',
                  suffixText: isPercentage ? '%' : null,
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  if (!isNew) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _charges.remove(entry));
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorRed,
                          side: const BorderSide(color: AppColors.errorRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 52),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        final val = double.tryParse(valueCtrl.text) ?? 0;
                        if (val <= 0) return;

                        setState(() {
                          final chargeName = nameCtrl.text.trim().isEmpty
                              ? switch (type) {
                                  'tax' => 'Tax',
                                  'service' => 'Service Charge',
                                  'tip' => 'Tip',
                                  _ => 'Charge',
                                }
                              : nameCtrl.text.trim();
                          final updated = entry.copyWith(
                            type: type,
                            name: chargeName,
                            value: val,
                            isPercentage: isPercentage,
                          );
                          if (isNew) {
                            _charges.add(updated);
                          } else {
                            final idx = _charges.indexWhere((e) => e.id == entry.id);
                            if (idx != -1) _charges[idx] = updated;
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryForest,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: const Text(
                        'Save Charge',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<SplitBillBloc, SplitBillState>(
      listener: (context, state) {
        if (state is SplitBillCreateSuccess) {
          GoRouter.of(context).pushReplacement(
            '/assign-items',
            extra: AssignItemsArgs(billId: state.createdBill.id, isNewBill: true),
          );
        }
        if (state is SplitBillError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutralCream,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.primaryForest,
                      ),
                      onPressed: () => GoRouter.of(context).pop(),
                    ),
                    const Expanded(
                      child: Text(
                        'Split Bill',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryForest,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: AppColors.brownEspresso,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 8),

                  FormRow(
                    label: 'Bill Name',
                    onTap: _showEditTitleDialog,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            _title.isEmpty ? 'Tap to name' : _title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _title.isEmpty
                                  ? AppColors.neutralTaupe
                                  : AppColors.brownEspresso,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit,
                          size: 18,
                          color: AppColors.brownMocha,
                        ),
                      ],
                    ),
                  ),

                  _Divider(),

                  FormRow(
                    label: 'Date',
                    onTap: _pickDate,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.brownEspresso,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppColors.neutralTaupe,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  const _SectionLabel('DYNAMIC ITEM LIST'),
                  const SizedBox(height: 12),

                  ..._items.map(
                    (item) => BillItemRow(
                      key: ValueKey(item.id),
                      item: item,
                      onTap: () => _showItemSheet(existing: item),
                    ),
                  ),

                  AddRowButton(
                    label: 'Add another item',
                    onTap: () => _showItemSheet(),
                  ),

                  const SizedBox(height: 24),

                  const _SectionLabel('OPTIONAL CHARGES SECTION'),
                  const SizedBox(height: 12),

                  ..._charges.map(
                    (charge) => BillChargeRow(
                      key: ValueKey(charge.id),
                      charge: charge,
                      onTap: () => _showChargeSheet(existing: charge),
                    ),
                  ),

                  AddRowButton(
                    label: 'Add tax or fee',
                    onTap: () => _showChargeSheet(),
                  ),

                  const SizedBox(height: 24),

                  const _SectionLabel('OPTIONAL NOTE'),
                  const SizedBox(height: 12),
                  NoteRow(note: _note, onTap: _showEditNoteDialog),

                  const SizedBox(height: 32),
                ],
              ),
            ),

            CreateBillBottomBar(total: _totalBill, onNext: _submit),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final formatted = DateFormat('d MMM yyyy').format(date);
    return isToday ? 'Today, $formatted' : formatted;
  }
}


class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.neutralTaupe,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.brownDriftwood,
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.brownMocha,
      letterSpacing: 1,
    ),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    color: AppColors.neutralTaupe.withValues(alpha: 0.25),
  );
}

