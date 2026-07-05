import 'package:flutter/material.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/forgot_password_cubit.dart';
import '../../../core/widgets/custom_text_field.dart';
class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({super.key});

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
            listener: (context, state) {
              if (state is ForgotPasswordSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reset link sent! Please check your email.')),
                );
                Navigator.maybePop(context);
              } else if (state is ForgotPasswordError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            builder: (context, state) {
              return SizedBox(
                height: AppSize.s56,
                child: ElevatedButton(
                  onPressed: state is ForgotPasswordLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            context.read<ForgotPasswordCubit>().resetPassword(_emailController.text);
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
                  child: state is ForgotPasswordLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          AppStrings.resetPassword,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            },
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
    );
  }
}
