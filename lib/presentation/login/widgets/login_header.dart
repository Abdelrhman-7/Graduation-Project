import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../role_selection/cubit/role_selection_state.dart';

class LoginHeader extends StatelessWidget {
  final UserRole role;

  const LoginHeader({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPatient = role == UserRole.patient;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSize.s32),
        Text(
          AppStrings.welcomeBack,
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: ColorManager.primary,
          ),
        ),
        const SizedBox(height: AppSize.s8),
        Text(
          isPatient
              ? AppStrings.loginDescPatient
              : AppStrings.loginDescProvider,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
