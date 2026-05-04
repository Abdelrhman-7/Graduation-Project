import 'package:flutter/material.dart';
import '../resources/color_manager.dart';
import '../resources/values_manager.dart';

class CustomChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isAddButton;
  final VoidCallback onTap;

  const CustomChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isAddButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppPadding.p16,
          vertical: AppPadding.p8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorManager.primaryOpacity10 : ColorManager.white,
          borderRadius: BorderRadius.circular(9999), // Pill shape
          border: isAddButton
              ? null // For dashed border we would need custom painter, fallback to normal border
              : Border.all(
                  color: isSelected ? ColorManager.primary : ColorManager.borderColor,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAddButton) ...[
              const Icon(
                Icons.add,
                size: AppSize.s16,
                color: ColorManager.subtitleText,
              ),
              const SizedBox(width: AppSize.s4),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isAddButton
                    ? ColorManager.subtitleText
                    : (isSelected ? ColorManager.primary : ColorManager.bodyText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
