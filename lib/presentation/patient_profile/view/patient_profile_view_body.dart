import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_home_dashboard/widgets/patient_bottom_nav.dart';
import '../../auth_choice/view/auth_choice_view.dart';
import '../cubit/patient_profile_cubit.dart';
import '../cubit/patient_profile_state.dart';
import '../widgets/profile_header.dart';
import '../widgets/stats_row.dart';
import '../widgets/premium_card.dart';
import '../widgets/menu_item.dart';

class PatientProfileViewBody extends StatelessWidget {
  const PatientProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.85, 1.15);
        double s(double v) => v * scale;

        return BlocConsumer<PatientProfileCubit, PatientProfileState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthChoiceView()),
                (route) => false,
              );
            }
          },
          builder: (context, state) {
            if (state is PatientProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientProfileError) {
              return Center(child: Text(state.message));
            } else if (state is PatientProfileSuccess) {
              return Container(
                color: ColorManager.whiteLilac,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: s(20)),
                            ProfileHeader(
                              scale: scale,
                              name: state.name,
                              patientId: state.patientId,
                            ),
                            ProfileStatsRow(
                              scale: scale,
                              age: state.age,
                              bloodType: state.bloodType,
                            ),
                            PremiumCareCard(scale: scale),
                            SizedBox(height: s(16)),
                            _buildSectionHeader(s, AppStrings.healthRecords),
                            ProfileMenuItem(
                              scale: scale,
                              icon: Icons.history_rounded,
                              title: AppStrings.medicalHistory,
                              subtitle: state.medicalHistory,
                            ),
                            ProfileMenuItem(
                              scale: scale,
                              icon: Icons.warning_amber_rounded,
                              title: AppStrings.knownAllergies,
                              subtitle: state.allergies,
                              iconColor: const Color(0xFFEF4444),
                            ),
                            SizedBox(height: s(16)),
                            _buildSectionHeader(s, AppStrings.securitySettings),
                            ProfileMenuItem(
                              scale: scale,
                              icon: Icons.lock_outline_rounded,
                              title: AppStrings.changePassword,
                              // ignore: prefer_interpolation_to_compose_strings
                              subtitle:
                                  // ignore: prefer_interpolation_to_compose_strings
                                  AppStrings.lastUpdated +
                                  ' 30 ' +
                                  AppStrings.daysAgo,
                            ),
                            ProfileMenuItem(
                              scale: scale,
                              icon: Icons.logout_rounded,
                              title: AppStrings.logout,
                              iconColor: const Color(0xFFEF4444),
                              onTap: () {
                                context.read<PatientProfileCubit>().logout();
                              },
                            ),
                            SizedBox(height: s(40)),
                          ],
                        ),
                      ),
                    ),
                    const PatientBottomNav(currentIndex: 3),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(double Function(double) s, String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(s(24), s(16), s(24), s(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: s(14),
              fontWeight: FontWeight.w700,
              color: ColorManager.subtitleText,
              letterSpacing: s(1),
            ),
          ),
          Text(
            AppStrings.viewAll,
            style: GoogleFonts.lexend(
              fontSize: s(12),
              fontWeight: FontWeight.w600,
              color: ColorManager.primary,
            ),
          ),
        ],
      ),
    );
  }
}
