import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../cubit/patient_registration_cubit.dart';
import '../cubit/patient_registration_state.dart';
import '../widgets/registration_progress_bar.dart';
import '../widgets/registration_terms_footer.dart';
import '../widgets/password_rule_item.dart';

class PatientRegistrationStep2ViewBody extends StatefulWidget {
  const PatientRegistrationStep2ViewBody({super.key});

  @override
  State<PatientRegistrationStep2ViewBody> createState() => _PatientRegistrationStep2ViewBodyState();
}

class _PatientRegistrationStep2ViewBodyState extends State<PatientRegistrationStep2ViewBody> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const RegistrationProgressBar(
          progress: 1.0,
          stepText: AppStrings.step2Of2,
          percentText: AppStrings.completed100,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p24,
              vertical: AppPadding.p24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Headline Section
                Text(
                  AppStrings.completeYourProfile,
                  style: theme.textTheme.displayLarge?.copyWith(fontSize: 30),
                ),
                const SizedBox(height: AppSize.s8),
                Text(
                  AppStrings.completeYourProfileDesc,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: ColorManager.bodyText,
                  ),
                ),
                const SizedBox(height: AppSize.s32),

                // Age and Gender
                const CustomTextField(
                  label: AppStrings.age,
                  hintText: AppStrings.ageHint,
                ),
                const SizedBox(height: AppSize.s20),
                CustomDropdownField<String>(
                  label: AppStrings.gender,
                  hintText: AppStrings.genderHint,
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      context.read<PatientRegistrationCubit>().updateGender(value);
                    }
                  },
                ),
                const SizedBox(height: AppSize.s32),

                // Security Settings
                Text(
                  AppStrings.securitySettings,
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSize.s16),
                
                CustomTextField(
                  label: AppStrings.createPassword,
                  hintText: AppStrings.createPasswordHint,
                  obscureText: _obscurePassword,
                  onChanged: (v) => context.read<PatientRegistrationCubit>().updatePassword(v),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: ColorManager.subtitleText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSize.s20),
                
                CustomTextField(
                  label: AppStrings.confirmPassword,
                  hintText: AppStrings.confirmPasswordHint,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: ColorManager.subtitleText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                const SizedBox(height: AppSize.s24),

                // Password Rules
                const PasswordRuleItem(text: AppStrings.rule8Chars),
                const PasswordRuleItem(text: AppStrings.ruleNumber),
                const PasswordRuleItem(text: AppStrings.ruleSpecialChar),
              ],
            ),
          ),
        ),
        BlocConsumer<PatientRegistrationCubit, PatientRegistrationState>(
          listener: (context, state) {
            if (state is PatientRegistrationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'Registration Successful')),
              );
              // Navigate to home or login
            } else if (state is PatientRegistrationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            return RegistrationTermsFooter(
              onCompleteRegistration: state is PatientRegistrationLoading
                  ? null
                  : () {
                      context.read<PatientRegistrationCubit>().register();
                    },
            );
          },
        ),
      ],
    );
  }
}
