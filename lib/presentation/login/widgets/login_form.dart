import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/presentation/login/cubit/login_state.dart';
import 'package:graduationproject/presentation/patient_home_dashboard/view/patient_home_dashboard_view.dart';
import 'package:graduationproject/presentation/doctor/view/doctor_home_view.dart';
import '../../role_selection/cubit/role_selection_state.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../forgot_password/view/forgot_password_view.dart';
import '../cubit/login_cubit.dart';
import '../../../data/models/login_model.dart';

class LoginForm extends StatefulWidget {
  final UserRole role;
  const LoginForm({super.key, required this.role});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController(text: 'abdo77@gmail.com');
  final _passwordController = TextEditingController(text: '123456789@#\$Abdo');
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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSize.s40),
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
            buildWhen: (previous, current) =>
                current is LoginPasswordVisibilityChanged,
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => widget.role == UserRole.doctor
                        ? const DoctorHomeView()
                        : const PatientHomeDashboardView(),
                  ),
                  (route) => false,
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
                              LoginRequest(
                                email: _emailController.text
                                    .trim()
                                    .toLowerCase(),
                                password: _passwordController.text.trim(),
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
                  child: state is LoginLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          AppStrings.login,
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
    );
  }
}
