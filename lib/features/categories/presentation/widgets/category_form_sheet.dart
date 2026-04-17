import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';

class CategoryFormResult {
  final String name;
  final String? icon;
  final String? color;

  const CategoryFormResult({required this.name, this.icon, this.color});
}

Future<CategoryFormResult?> showCategoryFormSheet(
  BuildContext context, {
  required CategoryType type,
  Category? existing,
  Category? parent,
}) {
  return showModalBottomSheet<CategoryFormResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        _CategoryFormSheet(type: type, existing: existing, parent: parent),
  );
}

class _CategoryFormSheet extends StatefulWidget {
  final CategoryType type;
  final Category? existing;
  final Category? parent;

  const _CategoryFormSheet({required this.type, this.existing, this.parent});

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _iconController;
  late final TextEditingController _colorController;

  bool _hasSubmitted = false;

  static const String _defaultColor = '#808080';
  static final RegExp _hexRegex = RegExp(r'^#([0-9A-Fa-f]{6})$');

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _iconController = TextEditingController(text: widget.existing?.icon ?? '');
    _colorController = TextEditingController(
      text: widget.existing?.color ?? _defaultColor,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (!_hasSubmitted) return null;
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Name is required';
    if (trimmed.length > 100) return 'Maximum 100 characters';
    return null;
  }

  String? _validateIcon(String? value) {
    if (!_hasSubmitted) return null;
    if (value == null) return null;
    if (value.length > 50) return 'Maximum 50 characters';
    return null;
  }

  String? _validateColor(String? value) {
    if (!_hasSubmitted) return null;
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (!_hexRegex.hasMatch(trimmed)) return 'Use #RRGGBB format';
    return null;
  }

  void _submit() {
    setState(() => _hasSubmitted = true);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final iconRaw = _iconController.text.trim();
    final colorRaw = _colorController.text.trim();

    Navigator.pop(
      context,
      CategoryFormResult(
        name: name,
        icon: iconRaw.isEmpty ? null : iconRaw,
        color: colorRaw.isEmpty ? null : colorRaw,
      ),
    );
  }

  String _titleText() {
    if (_isEdit) return 'Edit Category';
    if (widget.parent != null) return 'Add Subcategory';
    return widget.type == CategoryType.income
        ? 'New Income Category'
        : 'New Expense Category';
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
            Text(
              _titleText(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.brownEspresso,
              ),
            ),
            if (widget.parent != null) ...[
              const SizedBox(height: 6),
              Text(
                'Under ${widget.parent!.name}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.brownMocha,
                ),
              ),
            ],
            const SizedBox(height: 20),

            const Text(
              'Name',
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
              decoration: const InputDecoration(hintText: 'e.g., Groceries'),
            ),
            const SizedBox(height: 16),

            const Text(
              'Icon (emoji or short text)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDriftwood,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _iconController,
              maxLength: 50,
              autovalidateMode: _hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              validator: _validateIcon,
              decoration: const InputDecoration(
                hintText: 'e.g., 🛒',
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Color (#RRGGBB, optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.brownDriftwood,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _colorController,
              autovalidateMode: _hasSubmitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              validator: _validateColor,
              decoration: const InputDecoration(hintText: '#808080'),
            ),
            const SizedBox(height: 24),

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
                  child: Text(
                    _isEdit ? 'Save Changes' : 'Create Category',
                    style: const TextStyle(
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
