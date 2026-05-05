import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/resources/color_manager.dart';
import '../cubit/doctor_home_cubit.dart';
import '../cubit/doctor_home_state.dart';
import '../widgets/doctor_header.dart';
import '../widgets/up_next_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/patient_requests.dart';
import '../widgets/today_schedule.dart';

class DoctorHomeViewBody extends StatelessWidget {
  const DoctorHomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.85, 1.15);
        double s(double v) => v * scale;

        return BlocBuilder<DoctorHomeCubit, DoctorHomeState>(
          builder: (context, state) {
            if (state is DoctorHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorHomeError) {
              return Center(child: Text(state.message));
            } else if (state is DoctorHomeSuccess) {
              return Container(
                color: ColorManager.whiteLilac,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            DoctorHomeHeader(
                              scale: scale,
                              name: state.doctorName,
                              specialty: state.specialty,
                            ),
                            UpNextCard(
                              scale: scale,
                              appointment: state.upNextAppointment,
                            ),
                            QuickActionsGrid(scale: scale),
                            PatientRequestsList(
                              scale: scale,
                              requests: state.patientRequests,
                            ),
                            TodayScheduleList(
                              scale: scale,
                              schedule: state.todaySchedule,
                            ),
                            SizedBox(height: s(20)),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomNav(s),
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

  Widget _buildBottomNav(double Function(double) s) {
    return Container(
      padding: EdgeInsets.fromLTRB(s(24), s(10), s(24), s(20)),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColorManager.borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(s, Icons.dashboard_rounded, 'Home', true),
          _buildNavItem(s, Icons.people_alt_rounded, 'Patients', false),
          _buildNavItem(s, Icons.calendar_today_rounded, 'Calendar', false),
          _buildNavItem(s, Icons.settings_rounded, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(double Function(double) s, IconData icon, String label, bool active) {
    final color = active ? ColorManager.primary : ColorManager.subtitleText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: s(24)),
        SizedBox(height: s(4)),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: s(12),
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
