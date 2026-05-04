import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../role_selection/view/role_selection_view.dart';
import '../cubit/auth_choice_cubit.dart';

class AuthChoiceView extends StatelessWidget {
  const AuthChoiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthChoiceCubit(),
      child: const _AuthChoiceContent(),
    );
  }
}

class _AuthChoiceContent extends StatelessWidget {
  const _AuthChoiceContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
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
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.primary,
                  ),
                ),
                const SizedBox(height: AppSize.s12),
                Text(
                  AppStrings.authChoiceDesc,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                _ChoiceCard(
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
                _ChoiceCard(
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
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isPrimary ? Colors.white : ColorManager.primary,
                    ),
                  ),
                  const SizedBox(height: AppSize.s4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
