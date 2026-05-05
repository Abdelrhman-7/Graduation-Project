// ignore_for_file: duplicate_ignore, deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../role_selection/view/role_selection_view.dart';
import 'choice_card.dart';

class AuthChoiceViewBody extends StatelessWidget {
  const AuthChoiceViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            // ignore: deprecated_member_use
            ColorManager.primary.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // App Logo Placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(AppSize.s20),
                  boxShadow: [
                    BoxShadow(
                      color: ColorManager.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: AppSize.s40,
                ),
              ),
              const SizedBox(height: AppSize.s32),
              Text(
                AppStrings.welcome,
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorManager.primary,
                ),
              ),
              const SizedBox(height: AppSize.s12),
              Text(
                AppStrings.authChoiceDesc,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const Spacer(),
              ChoiceCard(
                title: AppStrings.login,
                subtitle: 'Already have an account? Sign in here.',
                icon: Icons.login_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoleSelectionView(isLogin: true),
                    ),
                  );
                },
                isPrimary: true,
              ),
              const SizedBox(height: AppSize.s20),
              ChoiceCard(
                title: AppStrings.register,
                subtitle: 'New here? Create your account today.',
                icon: Icons.person_add_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RoleSelectionView(isLogin: false),
                    ),
                  );
                },
                isPrimary: false,
              ),
              const SizedBox(height: AppSize.s40),
            ],
          ),
        ),
      ),
    );
  }
}
