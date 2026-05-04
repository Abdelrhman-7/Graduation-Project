import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(),
      child: const _ForgotPasswordContent(),
    );
  }
}

class _ForgotPasswordContent extends StatefulWidget {
  const _ForgotPasswordContent();

  @override
  State<_ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<_ForgotPasswordContent> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(AppPadding.p8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorManager.white,
              boxShadow: [
                BoxShadow(
                  color: ColorManager.blackOpacity05,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: ColorManager.headlineText,
              size: AppSize.s20,
            ),
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: ColorManager.primary,
                      size: AppSize.s0,
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
                const SizedBox(height: AppSize.s48),

                // Email Field
                Text(
                  AppStrings.emailAddress,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSize.s8),
                CustomTextField(
                  controller: _emailController,
                  hintText: AppStrings.emailHint,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSize.s40),

                // Reset Button
                SizedBox(
                  height: AppSize.s56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Implement Forgot Password API call
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Reset link sent! Please check your email.',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSize.s16),
                      ),
                      elevation: 8,
                      shadowColor: ColorManager.primaryOpacity15,
                    ),
                    child: const Text(
                      AppStrings.resetPassword,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s32),

                // Back to Login
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: Text(
                      AppStrings.backToLogin,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: ColorManager.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
