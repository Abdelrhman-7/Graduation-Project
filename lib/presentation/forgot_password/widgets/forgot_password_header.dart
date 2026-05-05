import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: AppSize.s32),
        // Icon Header
        Center(
          child: Container(
            padding: const EdgeInsets.all(AppPadding.p24),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: ColorManager.primary,
              size: AppSize.s40,
            ),
          ),
        ),
        const SizedBox(height: AppSize.s40),
        Text(
          AppStrings.forgotPasswordTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(height: AppSize.s12),
        Text(
          AppStrings.forgotPasswordSubtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
