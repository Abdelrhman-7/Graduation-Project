import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../role_selection/cubit/role_selection_state.dart';
import '../../forgot_password/view/forgot_password_view.dart';
import '../cubit/login_cubit.dart';

class LoginView extends StatelessWidget {
  final UserRole role;

  const LoginView({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(),
      child: _LoginContent(role: role),
    );
  }
}

class _LoginContent extends StatefulWidget {
  final UserRole role;

  const _LoginContent({required this.role});

  @override
  State<_LoginContent> createState() => _LoginContentState();
}

class _LoginContentState extends State<_LoginContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPatient = widget.role == UserRole.patient;

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
                const SizedBox(height: AppSize.s40),
                
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
                const SizedBox(height: AppSize.s20),
                
                // Password Field
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.password,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordView(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: ColorManager.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s8),
                BlocBuilder<LoginCubit, LoginState>(
                  buildWhen: (previous, current) => current is LoginPasswordVisibilityChanged,
                  builder: (context, state) {
                    final cubit = context.read<LoginCubit>();
                    return CustomTextField(
                      controller: _passwordController,
                      hintText: AppStrings.passwordHint,
                      prefixIcon: Icons.lock_outline,
                      obscureText: cubit.isObscure,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          cubit.isObscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                        ),
                        onPressed: () => cubit.togglePasswordVisibility(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSize.s40),
                
                // Login Button
                BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    if (state is LoginSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login successful!')),
                      );
                    }
                  },
                  builder: (context, state) {
                    return SizedBox(
                      height: AppSize.s56,
                      child: ElevatedButton(
                        onPressed: state is LoginLoading 
                          ? null 
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<LoginCubit>().login(
                                  _emailController.text,
                                  _passwordController.text,
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
                        child: state is LoginLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              AppStrings.login,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSize.s32),
                
                // Don't have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.dontHaveAccount,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.maybePop(context);
                      },
                      child: Text(
                        AppStrings.register,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: ColorManager.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.s24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
