import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData; // Using IconData as fallback for SVG
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(AppSize.s16),
          border: Border.all(
            color: isSelected ? ColorManager.primary : Colors.transparent,
            width: AppSize.s2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? ColorManager.primaryOpacity15 : ColorManager.blackOpacity05,
              offset: isSelected ? const Offset(0, 8) : const Offset(0, 1),
              blurRadius: isSelected ? 20 : 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient Overlay for Selected State
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.s14), // Inner border radius
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ColorManager.primary.withValues(alpha: 0),
                        ColorManager.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Content
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppPadding.p24,
                horizontal: AppPadding.p16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Circle
                  Container(
                    width: AppSize.s80,
                    height: AppSize.s80,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorManager.primaryOpacity10
                          : ColorManager.unselectedCardBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        iconData,
                        size: AppSize.s40,
                        color: isSelected ? ColorManager.primary : ColorManager.subtitleText,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSize.s16),
                  
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSize.s4),
                  
                  // Description
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // Selection Badge Top Right
            Positioned(
              top: AppSize.s14,
              right: AppSize.s14,
              child: Container(
                width: AppSize.s24,
                height: AppSize.s24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? ColorManager.primary : ColorManager.subtitleText.withValues(alpha: 0.3),
                    width: AppSize.s2,
                  ),
                  color: isSelected ? ColorManager.primary : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: AppSize.s16,
                        color: ColorManager.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
