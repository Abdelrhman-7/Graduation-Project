import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../cubit/patient_registration_cubit.dart';
import '../cubit/patient_registration_state.dart';
import '../widgets/registration_progress_bar.dart';

class PatientRegistrationStep2ViewBody extends StatefulWidget {
  const PatientRegistrationStep2ViewBody({super.key});

  @override
  State<PatientRegistrationStep2ViewBody> createState() =>
      _PatientRegistrationStep2ViewBodyState();
}

class _PatientRegistrationStep2ViewBodyState
    extends State<PatientRegistrationStep2ViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedGender = 'Male';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<PatientRegistrationCubit>();
    _passwordController.text = cubit.password;
    _confirmPasswordController.text = cubit.confirmPassword;
    _selectedGender = cubit.gender;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientRegistrationCubit, PatientRegistrationState>(
      listener: (context, state) {
        if (state is PatientRegistrationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to login or home after successful registration
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is PatientRegistrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PatientRegistrationLoading;

        return Column(
          children: [
            const RegistrationProgressBar(
              progress: 1.0,
              stepText: 'Step 2 of 2',
              percentText: '100% Completed',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p24,
                  vertical: AppPadding.p24,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'Security & Identity',
                        style: GoogleFonts.cairo(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: ColorManager.headlineText,
                        ),
                      ),
                      const SizedBox(height: AppSize.s8),
                      Text(
                        'Create a secure password and confirm your identity details.',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: ColorManager.bodyText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppSize.s32),

                      // Gender Selection
                      Text(
                        'Gender',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.headlineText,
                        ),
                      ),
                      const SizedBox(height: AppSize.s8),
                      Row(
                        children: ['Male', 'Female'].map((gender) {
                          final isSelected = _selectedGender == gender;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedGender = gender);
                                context
                                    .read<PatientRegistrationCubit>()
                                    .updateGender(gender);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                  right: gender == 'Male' ? 8 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? ColorManager.primary
                                      : ColorManager.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSize.s12,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? ColorManager.primary
                                        : ColorManager.borderColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      gender == 'Male'
                                          ? Icons.male_rounded
                                          : Icons.female_rounded,
                                      color: isSelected
                                          ? Colors.white
                                          : ColorManager.bodyText,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      gender,
                                      style: GoogleFonts.cairo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : ColorManager.bodyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSize.s24),

                      // Password Field
                      CustomTextField(
                        label: 'Password',
                        hintText: 'At least 8 characters',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: ColorManager.subtitleText,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        onChanged: (v) => context
                            .read<PatientRegistrationCubit>()
                            .updatePassword(v),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Password is required';
                          }
                          if (val.length < 8) return 'Minimum 8 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSize.s20),

                      // Confirm Password Field
                      CustomTextField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: ColorManager.subtitleText,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        onChanged: (v) => context
                            .read<PatientRegistrationCubit>()
                            .updateConfirmPassword(v),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'The ConfirmPassword field is required.';
                          }
                          if (val != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSize.s16),

                      // Password hint
                      Container(
                        padding: const EdgeInsets.all(AppPadding.p16),
                        decoration: BoxDecoration(
                          color: ColorManager.primary.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(AppSize.s12),
                          border: Border.all(
                            color: ColorManager.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password requirements:',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ColorManager.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...[
                              'At least 8 characters',
                              'Contains uppercase letter',
                              'Contains a number or special character',
                            ].map(
                              (hint) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_outline,
                                      size: 14,
                                      color: ColorManager.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      hint,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        color: ColorManager.bodyText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer with Create Account button
            Container(
              padding: const EdgeInsets.all(AppPadding.p24),
              decoration: const BoxDecoration(
                color: ColorManager.background,
                border: Border(
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
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context
                                    .read<PatientRegistrationCubit>()
                                    .register();
                              }
                            },
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text('Create Account'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
