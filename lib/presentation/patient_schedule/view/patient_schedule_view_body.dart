import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/repository/repository.dart';
import '../../patient_home_dashboard/widgets/patient_bottom_nav.dart';
import '../cubit/patient_schedule_cubit.dart';
import '../cubit/patient_schedule_state.dart';
import '../widgets/patient_schedule_header.dart';
import '../widgets/patient_schedule_tabs.dart';
import '../widgets/upcoming_appointments_section.dart';
import '../widgets/past_appointments_section.dart';

class PatientScheduleViewBody extends StatelessWidget {
  const PatientScheduleViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PatientScheduleCubit(context.read<Repository>())..fetchAppointments(),
      child: const _PatientScheduleContent(),
    );
  }
}

class _PatientScheduleContent extends StatefulWidget {
  const _PatientScheduleContent();

  @override
  State<_PatientScheduleContent> createState() =>
      _PatientScheduleContentState();
}

class _PatientScheduleContentState extends State<_PatientScheduleContent> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PatientScheduleCubit>().fetchAppointments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PatientScheduleHeader(),
        PatientScheduleTabs(
          selectedTab: _selectedTab,
          onTabSelected: (index) => setState(() => _selectedTab = index),
        ),
        Expanded(
          child: BlocBuilder<PatientScheduleCubit, PatientScheduleState>(
            builder: (context, state) {
              if (state is PatientScheduleLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF137FEC),
                    //color: Colors.amber,
                    strokeWidth: 3,
                  ),
                );
              }

              if (state is PatientScheduleError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFEE2E2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.error_outline_rounded,
                            color: Color(0xFFEF4444),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load appointments',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => context
                              .read<PatientScheduleCubit>()
                              .fetchAppointments(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF137FEC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final upcoming = state is PatientScheduleSuccess
                  ? state.upcomingAppointments
                  : <dynamic>[];
              final past = state is PatientScheduleSuccess
                  ? state.pastAppointments
                  : <dynamic>[];

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTab == 0)
                      UpcomingAppointmentsSection(appointments: upcoming)
                    else
                      PastAppointmentsSection(appointments: past),
                  ],
                ),
              );
            },
          ),
        ),
        const PatientBottomNav(currentIndex: 1),
      ],
    );
  }
}
