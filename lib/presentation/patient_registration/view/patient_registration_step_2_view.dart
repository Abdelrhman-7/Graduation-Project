import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_dropdown_field.dart';
import '../widgets/registration_progress_bar.dart';
import '../widgets/registration_terms_footer.dart';
import '../widgets/password_rule_item.dart';

class PatientRegistrationStep2View extends StatefulWidget {
  const PatientRegistrationStep2View({super.key});

  @override
  State<PatientRegistrationStep2View> createState() => _PatientRegistrationStep2ViewState();
}

class _PatientRegistrationStep2ViewState extends State<PatientRegistrationStep2View> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme, context),
      body: SafeArea(
        child: Column(
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
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                      ],
                      onChanged: (value) {},
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
            RegistrationTermsFooter(
              onCompleteRegistration: () {
                // TODO: Call registration API
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registration complete!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(ThemeData theme, BuildContext context) {
    return AppBar(
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
    );
  }
}
