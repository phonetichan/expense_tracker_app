import 'package:flutter/material.dart';
import '../../utils/category_icon_utils.dart';

class CategoryIconSelector extends StatelessWidget {
  final String selectedIcon;
  final ValueChanged<String> onIconChanged;

  const CategoryIconSelector({
    super.key,
    required this.selectedIcon,
    required this.onIconChanged,
  });

  static const List<String> icons = [
    'restaurant',
    'directions_car',
    'shopping_bag',
    'home',
    'receipt',
    'movie',
    'health_and_safety',
    'school',
    'flight',
    'person',
    'pets',
    'work',
    'fitness_center',
    'local_cafe',
    'build',
    'checkroom',
    'sports_esports',
    'inventory_2',
    'payments',
    'computer',
    'business',
    'trending_up',
    'card_giftcard',
    'savings',
    'category',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: icons.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final iconName = icons[index];
          final selected = iconName == selectedIcon;

          return GestureDetector(
            onTap: () => onIconChanged(iconName),
            child: Container(
              decoration: BoxDecoration(
                color: selected
                    ? Colors.deepPurple.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? Colors.deepPurple : Colors.transparent,
                ),
              ),
              child: Icon(
                getCategoryIcon(iconName),
                color: selected ? Colors.deepPurple : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
