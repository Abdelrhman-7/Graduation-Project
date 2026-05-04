import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';

class RegistrationFooter extends StatelessWidget {
  final VoidCallback onCreateAccountPressed;
  final VoidCallback onLoginPressed;

  const RegistrationFooter({
    super.key,
    required this.onCreateAccountPressed,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppPadding.p24),
      decoration: BoxDecoration(
        color: ColorManager.background,
        border: const Border(
          top: BorderSide(color: ColorManager.borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: AppSize.s56,
            child: ElevatedButton(
              onPressed: onCreateAccountPressed,
              child: const Text(AppStrings.createAccount),
            ),
          ),
          const SizedBox(height: AppSize.s16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppStrings.alreadyHaveAccount,
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: ColorManager.bodyText,
                ),
              ),
              GestureDetector(
                onTap: onLoginPressed,
                child: Text(
                  AppStrings.login,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ColorManager.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
