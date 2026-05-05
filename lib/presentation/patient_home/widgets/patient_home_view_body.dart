/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';
import '../cubit/patient_home_cubit.dart';
import '../cubit/patient_home_state.dart';
import 'health_stats_row.dart';
import 'medications_section.dart';
import 'next_appointment_card.dart';
import 'patient_home_header.dart';
import 'quick_actions_section.dart';

class PatientHomeViewBody extends StatelessWidget {
  const PatientHomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: SafeArea(
        child: BlocBuilder<PatientHomeCubit, PatientHomeState>(
          builder: (context, state) {
            if (state is PatientHomeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: ColorManager.primary),
              );
            } else if (state is PatientHomeSuccess) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PatientHomeHeader(userName: state.userName),
                    const SizedBox(height: AppSize.s12),
                    NextAppointmentCard(appointment: state.nextAppointment),
                    const SizedBox(height: AppSize.s32),
                    const QuickActionsSection(),
                    const SizedBox(height: AppSize.s32),
                    HealthStatsRow(
                      heartRate: state.heartRate,
                      bloodType: state.bloodType,
                    ),
                    const SizedBox(height: AppSize.s32),
                    MedicationsSection(medications: state.medications),
                    const SizedBox(height: AppSize.s32),
                  ],
                ),
              );
            } else if (state is PatientHomeError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
*/