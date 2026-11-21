import 'package:fintrack/core/constants/app_colors.dart';
import 'package:fintrack/core/theme/app_text_styles.dart';
import 'package:fintrack/core/widgets/app_card.dart';
import 'package:fintrack/features/transactions/model/category.dart';
import 'package:fintrack/features/transactions/view/category_style.dart';
import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = CategoryStyle.of(category.id);

    return Semantics(
      button: true,
      selected: selected,
      child: AppCard(
        padding: const EdgeInsets.all(12),
        radius: 12,
        onTap: onTap,
        child: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: style.tint,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x0D000000), blurRadius: 1, offset: Offset(0, 1)),
                      ],
                    ),
                    child: Icon(style.icon, size: 22, color: style.iconColor),
                  ),
                  if (selected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}