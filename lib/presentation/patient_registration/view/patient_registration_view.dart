import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_chip.dart';
import '../cubit/patient_registration_cubit.dart';
import '../cubit/patient_registration_state.dart';
import '../widgets/registration_footer.dart';
import '../widgets/registration_progress_bar.dart';
import 'patient_registration_step_2_view.dart';

class PatientRegistrationView extends StatelessWidget {
  const PatientRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientRegistrationCubit(),
      child: const _PatientRegistrationContent(),
    );
  }
}

class _PatientRegistrationContent extends StatelessWidget {
  const _PatientRegistrationContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(theme, context),
      body: SafeArea(
        child: Column(
          children: [
            const RegistrationProgressBar(
              progress: 0.5,
              stepText: AppStrings.step1Of2,
              percentText: AppStrings.completed50,
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
                      AppStrings.patientRegistration,
                      style: theme.textTheme.displayLarge?.copyWith(fontSize: 30),
                    ),
                    const SizedBox(height: AppSize.s8),
                    Text(
                      AppStrings.patientRegistrationDesc,
                      style: GoogleFonts.notoSans(
                        fontSize: 16,
                        color: ColorManager.bodyText,
                      ),
                    ),
                    const SizedBox(height: AppSize.s32),

                    // Form Fields
                    const CustomTextField(
                      label: AppStrings.fullName,
                      hintText: AppStrings.fullNameHint,
                    ),
                    const SizedBox(height: AppSize.s20),
                    const CustomTextField(
                      label: AppStrings.emailAddress,
                      hintText: AppStrings.emailHint,
                    ),
                    const SizedBox(height: AppSize.s20),
                    const CustomTextField(
                      label: AppStrings.dateOfBirth,
                      hintText: 'mm / dd / yyyy',
                      suffixIcon: Icon(Icons.calendar_today_outlined, color: ColorManager.subtitleText),
                    ),
                    const SizedBox(height: AppSize.s32),

                    // Medical History Section
                    Text(
                      AppStrings.medicalHistory,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSize.s16),
                    
                    _buildAllergiesSection(context),
                    const SizedBox(height: AppSize.s24),
                    _buildConditionsSection(context),
                    const SizedBox(height: AppSize.s24),

                    // Other Notes
                    const CustomTextField(
                      label: AppStrings.otherNotes,
                      hintText: AppStrings.otherNotesHint,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
            RegistrationFooter(
              onCreateAccountPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientRegistrationStep2View()),
                );
              },
              onLoginPressed: () {
                // TODO: Navigate to Login
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
      centerTitle: true,
      title: Text(
        AppStrings.createAccount,
        style: theme.textTheme.headlineMedium?.copyWith(fontSize: 16),
      ),
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

  Widget _buildAllergiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.knownAllergies,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorManager.bodyText,
          ),
        ),
        const SizedBox(height: AppSize.s12),
        BlocBuilder<PatientRegistrationCubit, PatientRegistrationState>(
          builder: (context, state) {
            final cubit = context.read<PatientRegistrationCubit>();
            return Wrap(
              spacing: AppSize.s8,
              runSpacing: AppSize.s8,
              children: [
                CustomChip(
                  label: 'Peanuts',
                  isSelected: cubit.hasAllergy('Peanuts'),
                  onTap: () => cubit.toggleAllergy('Peanuts'),
                ),
                CustomChip(
                  label: 'Penicillin',
                  isSelected: cubit.hasAllergy('Penicillin'),
                  onTap: () => cubit.toggleAllergy('Penicillin'),
                ),
                CustomChip(
                  label: 'Pollen',
                  isSelected: cubit.hasAllergy('Pollen'),
                  onTap: () => cubit.toggleAllergy('Pollen'),
                ),
                CustomChip(
                  label: AppStrings.add,
                  isSelected: false,
                  isAddButton: true,
                  onTap: () {
                    // Handle add allergy
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildConditionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.chronicConditions,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: ColorManager.bodyText,
          ),
        ),
        const SizedBox(height: AppSize.s12),
        BlocBuilder<PatientRegistrationCubit, PatientRegistrationState>(
          builder: (context, state) {
            final cubit = context.read<PatientRegistrationCubit>();
            return Wrap(
              spacing: AppSize.s8,
              runSpacing: AppSize.s8,
              children: [
                CustomChip(
                  label: 'Asthma',
                  isSelected: cubit.hasCondition('Asthma'),
                  onTap: () => cubit.toggleCondition('Asthma'),
                ),
                CustomChip(
                  label: 'Diabetes',
                  isSelected: cubit.hasCondition('Diabetes'),
                  onTap: () => cubit.toggleCondition('Diabetes'),
                ),
                CustomChip(
                  label: AppStrings.add,
                  isSelected: false,
                  isAddButton: true,
                  onTap: () {
                    // Handle add condition
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
