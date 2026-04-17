import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketree/core/di/injection_container.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/features/categories/domain/entities/category.dart';
import 'package:pocketree/features/categories/domain/entities/category_type.dart';
import 'package:pocketree/features/categories/domain/usecases/get_categories_usecase.dart';

Future<Category?> showCategoryPicker(
  BuildContext context, {
  required CategoryType type,
  Category? selected,
}) {
  return showModalBottomSheet<Category>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.neutralCream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _CategoryPickerSheet(type: type, selected: selected),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  final CategoryType type;
  final Category? selected;

  const _CategoryPickerSheet({required this.type, this.selected});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final GetCategoriesUseCase _getCategories = sl<GetCategoriesUseCase>();

  List<Category> _parents = [];
  List<Category> _subcategories = [];
  Category? _selectedParent;
  Category? _selectedCategory;
  bool _isLoadingParents = true;
  bool _isLoadingSubcategories = false;

  @override
  void initState() {
    super.initState();
    _fetchParents();
  }

  Future<void> _fetchParents() async {
    final result = await _getCategories(type: widget.type);
    result.fold((_) => setState(() => _isLoadingParents = false), (categories) {
      final parents = categories.where((c) => c.parentId == null).toList();
      setState(() {
        _parents = parents;
        _isLoadingParents = false;
      });

      if (parents.isNotEmpty) {
        if (widget.selected != null) {
          final parentId = widget.selected!.parentId ?? widget.selected!.id;
          final matchingParent = parents.where((p) => p.id == parentId);
          if (matchingParent.isNotEmpty) {
            _selectParent(matchingParent.first);
            if (widget.selected!.parentId != null) {
              _selectedCategory = widget.selected;
            }
            return;
          }
        }
        _selectParent(parents.first);
      }
    });
  }

  Future<void> _selectParent(Category parent) async {
    setState(() {
      _selectedParent = parent;
      _selectedCategory = null;
      _subcategories = [];
      _isLoadingSubcategories = true;
    });

    final result = await _getCategories(type: widget.type, parentId: parent.id);
    result.fold(
      (_) => setState(() => _isLoadingSubcategories = false),
      (subcategories) => setState(() {
        _subcategories = subcategories;
        _isLoadingSubcategories = false;
      }),
    );
  }

  void _confirm() {
    final result = _selectedCategory ?? _selectedParent;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brownEspresso,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.primaryForest,
                    ),
                    onPressed: () async {
                      await GoRouter.of(context).push('/category-management');
                      if (mounted) {
                        setState(() {
                          _isLoadingParents = true;
                          _selectedCategory = null;
                        });
                        _fetchParents();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: AppColors.brownDriftwood,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoadingParents
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryForest,
                      ),
                    )
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: _parents.length,
                          itemBuilder: (context, index) {
                            final parent = _parents[index];
                            final isSelected = _selectedParent?.id == parent.id;

                            return GestureDetector(
                              onTap: () => _selectParent(parent),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.primaryForest
                                          : AppColors.white,
                                    ),
                                    child: Center(
                                      child: parent.icon.isNotEmpty
                                          ? Text(
                                              parent.icon,
                                              style: const TextStyle(
                                                fontSize: 24,
                                              ),
                                            )
                                          : Icon(
                                              Icons.category_outlined,
                                              size: 24,
                                              color: isSelected
                                                  ? AppColors.white
                                                  : AppColors.primaryForest,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    parent.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppColors.primaryForest
                                          : AppColors.brownMocha,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        if (_isLoadingSubcategories)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primaryForest,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else if (_subcategories.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.neutralSand,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(_subcategories.length, (
                                index,
                              ) {
                                final sub = _subcategories[index];
                                final isSelected =
                                    _selectedCategory?.id == sub.id;

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () =>
                                      setState(() => _selectedCategory = sub),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.neutralLinen
                                          : Colors.transparent,
                                      borderRadius: index == 0
                                          ? const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            )
                                          : index == _subcategories.length - 1
                                          ? const BorderRadius.vertical(
                                              bottom: Radius.circular(16),
                                            )
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        if (sub.icon.isNotEmpty)
                                          Text(
                                            sub.icon,
                                            style: const TextStyle(
                                              fontSize: 18,
                                            ),
                                          )
                                        else
                                          Icon(
                                            Icons
                                                .subdirectory_arrow_right_rounded,
                                            size: 18,
                                            color: AppColors.primaryForest,
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            sub.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: AppColors.primaryForest,
                                            ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 22,
                                            color: AppColors.primaryForest,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )
                        else if (_selectedParent != null)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No subcategories',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.brownMocha,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: (_selectedCategory ?? _selectedParent) != null
                          ? _confirm
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Confirm Category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
