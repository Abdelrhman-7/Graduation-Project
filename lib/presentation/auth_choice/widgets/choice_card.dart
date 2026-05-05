import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const ChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppPadding.p20),
        decoration: BoxDecoration(
          color: isPrimary ? ColorManager.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSize.s24),
          border: isPrimary ? null : Border.all(color: ColorManager.primary.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: (isPrimary ? ColorManager.primary : Colors.black).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppPadding.p12),
              decoration: BoxDecoration(
                color: isPrimary ? Colors.white.withOpacity(0.2) : ColorManager.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.s16),
              ),
              child: Icon(
                icon,
                color: isPrimary ? Colors.white : ColorManager.primary,
                size: AppSize.s28,
              ),
            ),
            const SizedBox(width: AppSize.s20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : ColorManager.primary,
                    ),
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isPrimary ? Colors.white.withOpacity(0.8) : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? Colors.white.withOpacity(0.5) : ColorManager.primary.withOpacity(0.3),
              size: AppSize.s16,
            ),
          ],
        ),
      ),
    );
  }
}
