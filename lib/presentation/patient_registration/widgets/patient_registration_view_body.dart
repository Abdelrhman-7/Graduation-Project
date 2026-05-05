import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/presentation/patient_registration/view/patient_registration_step_2_view.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_chip.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/patient_registration_cubit.dart';
import '../cubit/patient_registration_state.dart';
import '../widgets/registration_footer.dart';
import '../widgets/registration_progress_bar.dart';

import 'package:intl/intl.dart';

class PatientRegistrationViewBody extends StatefulWidget {
  const PatientRegistrationViewBody({super.key});

  @override
  State<PatientRegistrationViewBody> createState() => _PatientRegistrationViewBodyState();
}

class _PatientRegistrationViewBodyState extends State<PatientRegistrationViewBody> {
  final TextEditingController _dobController = TextEditingController();

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
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
                  style: theme.textTheme.displayLarge,
                ),
                const SizedBox(height: AppSize.s8),
                Text(
                  AppStrings.patientRegistrationDesc,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: ColorManager.bodyText,
                  ),
                ),
                const SizedBox(height: AppSize.s32),

                // Form Fields
                CustomTextField(
                  label: AppStrings.fullName,
                  hintText: AppStrings.fullNameHint,
                  onChanged: (v) => context.read<PatientRegistrationCubit>().updateFullName(v),
                ),
                const SizedBox(height: AppSize.s20),
                CustomTextField(
                  label: AppStrings.emailAddress,
                  hintText: AppStrings.emailHint,
                  onChanged: (v) => context.read<PatientRegistrationCubit>().updateEmail(v),
                ),
                const SizedBox(height: AppSize.s20),
                CustomTextField(
                  label: AppStrings.phoneNumber,
                  hintText: AppStrings.phoneNumberHint,
                  onChanged: (v) => context.read<PatientRegistrationCubit>().updatePhoneNumber(v),
                ),
                const SizedBox(height: AppSize.s20),
                CustomTextField(
                  label: AppStrings.address,
                  hintText: AppStrings.addressHint,
                  onChanged: (v) => context.read<PatientRegistrationCubit>().updateAddress(v),
                ),
                const SizedBox(height: AppSize.s20),
                GestureDetector(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _dobController.text = DateFormat('MM / dd / yyyy').format(picked);
                      });
                      if (mounted) {
                        // Backend typically expects yyyy-MM-dd for dates
                        context.read<PatientRegistrationCubit>().updateDateOfBirth(
                          DateFormat('yyyy-MM-dd').format(picked),
                        );
                      }
                    }
                  },
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: _dobController,
                      label: AppStrings.dateOfBirth,
                      hintText: 'mm / dd / yyyy',
                      readOnly: true,
                      suffixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: ColorManager.subtitleText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSize.s20),
                _buildImagePicker(context),
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
            final cubit = context.read<PatientRegistrationCubit>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: const PatientRegistrationStep2View(),
                ),
              ),
            );
          },
          onLoginPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAllergiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.knownAllergies,
          style: GoogleFonts.lexend(
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
          style: GoogleFonts.lexend(
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

  Widget _buildImagePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Picture',
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorManager.headlineText,
          ),
        ),
        const SizedBox(height: AppSize.s8),
        InkWell(
          onTap: () async {
            final picker = ImagePicker();
            final image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null) {
              if (context.mounted) {
                context.read<PatientRegistrationCubit>().updateImagePath(image.path);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image selected')),
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppPadding.p16,
              horizontal: AppPadding.p16,
            ),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(AppSize.s12),
              border: Border.all(color: ColorManager.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, color: ColorManager.primary),
                const SizedBox(width: AppSize.s12),
                Text(
                  'Upload Photo',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    color: ColorManager.subtitleText,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.add_a_photo_outlined, color: ColorManager.subtitleText),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
