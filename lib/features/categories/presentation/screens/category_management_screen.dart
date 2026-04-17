import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/snackbar_helper.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/domain/usecases/get_categories_usecase.dart';
import 'package:pocketree/features/categories/presentation/bloc/category_bloc.dart';
import 'package:pocketree/features/categories/presentation/bloc/category_event.dart';
import 'package:pocketree/features/categories/presentation/bloc/category_state.dart';
import 'package:pocketree/features/categories/presentation/widgets/category_form_sheet.dart';

class CategoryManagementScreen extends StatelessWidget {
  const CategoryManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryBloc>(),
      child: const _CategoryManagementView(),
    );
  }
}

class _CategoryManagementView extends StatefulWidget {
  const _CategoryManagementView();

  @override
  State<_CategoryManagementView> createState() =>
      _CategoryManagementViewState();
}

class _CategoryManagementViewState extends State<_CategoryManagementView> {
  final GetCategoriesUseCase _getCategories = sl<GetCategoriesUseCase>();

  CategoryType _activeType = CategoryType.expense;

  bool _isLoading = true;
  String? _error;
  List<Category> _parents = const [];
  Map<int, List<Category>> _subsByParentId = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final parentsResult = await _getCategories(type: _activeType);

    await parentsResult.fold(
      (failure) async {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Failed to load categories';
        });
      },
      (parents) async {
        final subs = <int, List<Category>>{};
        for (final parent in parents) {
          final subResult = await _getCategories(
            type: _activeType,
            parentId: parent.id,
          );
          subResult.fold(
            (_) => subs[parent.id] = const [],
            (list) => subs[parent.id] = list,
          );
        }
        if (!mounted) return;
        setState(() {
          _parents = parents;
          _subsByParentId = subs;
          _isLoading = false;
        });
      },
    );
  }

  void _onTypeChanged(CategoryType type) {
    if (_activeType == type) return;
    setState(() => _activeType = type);
    _load();
  }

  Future<void> _onCreateTopLevel() async {
    final result = await showCategoryFormSheet(context, type: _activeType);
    if (result == null || !mounted) return;
    context.read<CategoryBloc>().add(
      CategoryCreateRequested(
        name: result.name,
        type: _activeType,
        icon: result.icon,
        color: result.color,
      ),
    );
  }

  Future<void> _onCreateSubcategory(Category parent) async {
    final result = await showCategoryFormSheet(
      context,
      type: _activeType,
      parent: parent,
    );
    if (result == null || !mounted) return;
    context.read<CategoryBloc>().add(
      CategoryCreateRequested(
        name: result.name,
        type: _activeType,
        icon: result.icon,
        color: result.color,
        parentId: parent.id,
      ),
    );
  }

  Future<void> _onEdit(Category category) async {
    final result = await showCategoryFormSheet(
      context,
      type: category.type,
      existing: category,
    );
    if (result == null || !mounted) return;
    context.read<CategoryBloc>().add(
      CategoryUpdateRequested(
        categoryId: category.id,
        name: result.name,
        icon: result.icon,
        color: result.color,
      ),
    );
  }

  Future<void> _onDelete(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Delete Category'),
          content: Text(
            'Are you sure you want to delete "${category.name}"? '
            'Existing transactions using this category will keep their reference.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    context.read<CategoryBloc>().add(
      CategoryDeleteRequested(categoryId: category.id),
    );
  }

  void _showOptions(Category category, {bool canAddSub = false}) {
    if (category.isSystem && !canAddSub) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
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
                if (canAddSub)
                  ListTile(
                    leading: const Icon(
                      Icons.add_rounded,
                      color: AppColors.primaryForest,
                    ),
                    title: const Text('Add Subcategory'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _onCreateSubcategory(category);
                    },
                  ),
                if (!category.isSystem) ...[
                  ListTile(
                    leading: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.brownDriftwood,
                    ),
                    title: const Text('Edit Category'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _onEdit(category);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.errorRed,
                    ),
                    title: const Text(
                      'Delete Category',
                      style: TextStyle(color: AppColors.errorRed),
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _onDelete(category);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryActionSuccess) {
          showSuccessSnackBar(context, state.message);
          _load();
        }
        if (state is CategoryError) {
          showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.neutralCream,
        appBar: AppBar(
          backgroundColor: AppColors.neutralCream,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.brownEspresso,
            ),
            onPressed: () => GoRouter.of(context).pop(),
          ),
          title: const Text(
            'Manage Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.brownEspresso,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'addCategory',
          backgroundColor: AppColors.brownEspresso,
          onPressed: _onCreateTopLevel,
          child: const Icon(Icons.add_rounded, color: AppColors.white),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: _TypeSwitcher(
                  active: _activeType,
                  onChanged: _onTypeChanged,
                ),
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryForest),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.brownDriftwood),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_parents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No categories yet. Tap + to create one.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.brownMocha),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryForest,
      backgroundColor: AppColors.white,
      onRefresh: _load,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
        itemCount: _parents.length,
        itemBuilder: (context, index) {
          final parent = _parents[index];
          final subs = _subsByParentId[parent.id] ?? const [];
          return _CategoryCard(
            parent: parent,
            subcategories: subs,
            onParentTap: () => _showOptions(parent, canAddSub: true),
            onSubTap: (sub) => _showOptions(sub),
            onAddSubTap: () => _onCreateSubcategory(parent),
          );
        },
      ),
    );
  }
}

class _TypeSwitcher extends StatelessWidget {
  final CategoryType active;
  final ValueChanged<CategoryType> onChanged;

  const _TypeSwitcher({required this.active, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.neutralSand,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: CategoryType.values.map((type) {
          final isActive = active == type;
          final label = type == CategoryType.income ? 'Income' : 'Expense';
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(type),
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
}

class _CategoryCard extends StatelessWidget {
  final Category parent;
  final List<Category> subcategories;
  final VoidCallback onParentTap;
  final ValueChanged<Category> onSubTap;
  final VoidCallback onAddSubTap;

  const _CategoryCard({
    required this.parent,
    required this.subcategories,
    required this.onParentTap,
    required this.onSubTap,
    required this.onAddSubTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neutralTaupe.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          _CategoryRow(
            category: parent,
            isParent: true,
            onTap: onParentTap,
          ),
          if (subcategories.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                color: AppColors.neutralTaupe.withValues(alpha: 0.25),
              ),
            ),
          ...subcategories.map(
            (sub) => _CategoryRow(
              category: sub,
              isParent: false,
              onTap: () => onSubTap(sub),
            ),
          ),
          InkWell(
            onTap: onAddSubTap,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_rounded,
                    size: 18,
                    color: AppColors.primaryForest,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add subcategory',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryForest,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Category category;
  final bool isParent;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.category,
    required this.isParent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = category.icon.isNotEmpty
        ? Text(category.icon, style: const TextStyle(fontSize: 20))
        : Icon(
            isParent
                ? Icons.category_outlined
                : Icons.subdirectory_arrow_right_rounded,
            size: 20,
            color: AppColors.primaryForest,
          );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          isParent ? 16 : 32,
          14,
          12,
          14,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.neutralSand,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: iconWidget,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: isParent ? 15 : 14,
                        fontWeight:
                            isParent ? FontWeight.w600 : FontWeight.w500,
                        color: AppColors.brownEspresso,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (category.isSystem) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neutralLinen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'System',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brownDriftwood,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.more_vert_rounded,
              size: 20,
              color: AppColors.neutralTaupe,
            ),
          ],
        ),
      ),
    );
  }
}
