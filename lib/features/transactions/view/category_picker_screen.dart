import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/widgets/app_header_bar.dart';
import 'package:fintrack/core/widgets/empty_state.dart';
import 'package:fintrack/core/widgets/sticky_cta.dart';
import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/model/transaction_type.dart';
import 'package:fintrack/features/transactions/view/widgets/category_tile.dart';
import 'package:fintrack/features/transactions/view/widgets/type_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryPickerArgs {
  const CategoryPickerArgs({required this.type, this.selectedId});

  final TransactionType type;
  final String? selectedId;
}

class CategoryPickerScreen extends StatefulWidget {
  const CategoryPickerScreen({super.key, required this.args});

  final CategoryPickerArgs args;

  @override
  State<CategoryPickerScreen> createState() => _CategoryPickerScreenState();
}

class _CategoryPickerScreenState extends State<CategoryPickerScreen> {
  late TransactionType _type = widget.args.type;
  late String? _selectedId = widget.args.selectedId;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Category> get _categories => DefaultCategories.forType(_type);

  List<Category> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _categories;
    return _categories
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q))
        .toList();
  }

  Category? get _selected {
    for (final c in _categories) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _type = type;
      _selectedId = _selected?.id;
    });
  }

  void _confirm() {
    final selected = _selected;
    if (selected == null) return;
    context.pop(selected);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + AppHeaderBar.height;
    final items = _visible;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                SizedBox(height: topPadding),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TypeSegmentedControl(
                    variant: SegmentedVariant.soft,
                    type: _type,
                    onChanged: _onTypeChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Choose a category for this transaction',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.lavender,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${_categories.length} options', style: AppTextStyles.label),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: items.isEmpty
                      ? const Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: EmptyState(
                              icon: Icons.search_off_rounded,
                              title: 'No categories found',
                              message: 'Try a different search.',
                            ),
                          ),
                        )
                      : GridView.builder(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            mainAxisExtent: 124,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final category = items[index];
                            return CategoryTile(
                              category: category,
                              selected: category.id == _selectedId,
                              onTap: () => setState(() => _selectedId = category.id),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppHeaderBar(
              title: 'Select Category',
              onBack: () => context.pop(),
              trailing: IconButton(
                onPressed: _selected == null ? null : _confirm,
                tooltip: 'Confirm',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 44, height: 44),
                icon: Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: _selected == null
                      ? AppColors.textSecondary.withValues(alpha: 0.4)
                      : AppColors.primary,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyCta(
              label: 'Confirm Category',
              trailingIcon: Icons.check_circle_outline_rounded,
              height: 48,
              onPressed: _selected == null ? null : _confirm,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0),
        decoration: InputDecoration(
          hintText: 'Search category...',
          hintStyle: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}