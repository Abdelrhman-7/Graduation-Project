import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../cubit/role_selection_cubit.dart';
import '../cubit/role_selection_state.dart';
import '../widgets/role_card.dart';
import '../../patient_registration/view/patient_registration_view.dart';
import '../../login/view/login_view.dart';

class RoleSelectionViewBody extends StatelessWidget {
  final bool isLogin;
  const RoleSelectionViewBody({super.key, required this.isLogin});

  void _onContinuePressed(BuildContext context, UserRole selectedRole) {
    if (isLogin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginView(role: selectedRole),
        ),
      );
    } else {
      if (selectedRole == UserRole.patient) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PatientRegistrationView()),
        );
      } else if (selectedRole == UserRole.doctor) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doctor registration coming soon!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSize.s32),
                  Text(
                    AppStrings.joinAs,
                    style: theme.textTheme.displayLarge,
                  ),
                  const SizedBox(height: AppSize.s16),
                  Text(
                    AppStrings.chooseRole,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSize.s48),
                  BlocBuilder<RoleSelectionCubit, RoleSelectionState>(
                    builder: (context, state) {
                      final currentRole = context.read<RoleSelectionCubit>().currentRole;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RoleCard(
                              title: AppStrings.patient,
                              description: AppStrings.patientDesc,
                              iconData: Icons.person_outline,
                              isSelected: currentRole == UserRole.patient,
                              onTap: () => context
                                  .read<RoleSelectionCubit>()
                                  .selectRole(UserRole.patient),
                            ),
                          ),
                          const SizedBox(width: AppSize.s16),
                          Expanded(
                            child: RoleCard(
                              title: AppStrings.doctor,
                              description: AppStrings.doctorDesc,
                              iconData: Icons.medical_services_outlined,
                              isSelected: currentRole == UserRole.doctor,
                              onTap: () => context
                                  .read<RoleSelectionCubit>()
                                  .selectRole(UserRole.doctor),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSize.s48),
                ],
              ),
            ),
          ),
          BlocBuilder<RoleSelectionCubit, RoleSelectionState>(
            builder: (context, state) {
              final currentRole = context.read<RoleSelectionCubit>().currentRole;
              return _buildBottomButton(context, currentRole);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, UserRole selectedRole) {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.p24),
      child: SizedBox(
        width: double.infinity,
        height: AppSize.s56,
        child: ElevatedButton(
          onPressed: selectedRole != UserRole.none
              ? () => _onContinuePressed(context, selectedRole)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorManager.primary,
            shadowColor: ColorManager.primaryOpacity15,
            elevation: 8,
          ),
          child: const Text(AppStrings.continueBtn),
        ),
      ),
    );
  }
}
