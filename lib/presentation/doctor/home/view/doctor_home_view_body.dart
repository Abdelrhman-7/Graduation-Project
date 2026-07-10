import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/presentation/doctor/profile/view/doctor_profile_view_body.dart';
import 'package:graduationproject/presentation/doctor/creatSchedule/view/creat_schedule_view.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import 'package:graduationproject/presentation/doctor/profile/cubit/doctor_profile_cubit.dart';
import '../../../../../core/resources/color_manager.dart';
import '../cubit/doctor_home_cubit.dart';
import '../cubit/doctor_home_state.dart';
import '../widgets/doctor_header.dart';
import '../widgets/up_next_card.dart';
import '../widgets/quick_actions.dart';
import '../widgets/patient_requests.dart';
import '../widgets/today_schedule.dart';
import '../widgets/doctor_notifications_sheet.dart';
import '../widgets/doctor_patients_view.dart';

class DoctorHomeViewBody extends StatefulWidget {
  const DoctorHomeViewBody({super.key});

  @override
  State<DoctorHomeViewBody> createState() => _DoctorHomeViewBodyState();
}

class _DoctorHomeViewBodyState extends State<DoctorHomeViewBody> {
  int _currentIndex = 0;

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
                      child: _currentIndex == 3
                          ? BlocProvider(
                              create: (context) => DoctorProfileCubit(
                                repository: context.read<Repository>(),
                                sharedPrefController: context.read<SharedPrefController>(),
                              ),
                              child: DoctorProfileViewBody(
                                doctorName: state.doctorName,
                                imageUrl: state.imageUrl,
                                age: state.age,
                                patientsCount: state.allBookings.where((b) => b.isApproved || (b.status?.toLowerCase().contains('completed') ?? false)).length,
                                specialization: state.specialty,
                              ),
                            )
                          : _currentIndex == 0
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  DoctorHomeHeader(
                                    scale: scale,
                                    name: state.doctorName,
                                    imageUrl: state.imageUrl,
                                    specialty: state.specialty,
                                    pendingNotifications:
                                        state.unreadNotifications,
                                    onNotificationsTap: () {
                                      context.read<DoctorHomeCubit>().markDoctorNotificationsRead();
                                      showDoctorNotificationsSheet(context);
                                    },
                                  ),
                                  UpNextCard(
                                    scale: scale,
                                    appointment: state.upNextAppointment,
                                  ),
                                  QuickActionsGrid(scale: scale),
                                  PatientRequestsList(
                                    scale: scale,
                                    requests: state.patientRequests,
                                    processingBookingId: state.processingBookingId,
                                    processingAction: state.processingAction,
                                    onApprove: (id) async {
                                      final ok = await context
                                          .read<DoctorHomeCubit>()
                                          .acceptBooking(id);
                                      if (context.mounted && !ok) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Failed to accept booking. Backend may not support this yet.',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                      onDeny: (id) async {
                                        final ok = await context
                                            .read<DoctorHomeCubit>()
                                            .rejectBooking(id);
                                        if (context.mounted && !ok) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to reject booking. Backend may not support this yet.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      onComplete: (id) async {
                                        final ok = await context
                                            .read<DoctorHomeCubit>()
                                            .completeBooking(id);
                                        if (context.mounted && !ok) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Failed to complete booking. Backend may not support this yet.',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  TodayScheduleList(
                                    scale: scale,
                                    schedule: state.todaySchedule,
                                  ),
                                  SizedBox(height: s(20)),
                                ],
                              ),
                            )
                          : _currentIndex == 1
                          ? const CreateScheduleView()
                          : _currentIndex == 2
                          ? const DoctorPatientsView()
                          : const SizedBox(),
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
      padding: EdgeInsets.fromLTRB(s(16), s(10), s(16), s(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(s, Icons.home_rounded, 'Home', _currentIndex == 0, 0),
          _buildNavItem(
            s,
            Icons.calendar_month_rounded,
            'Schedule',
            _currentIndex == 1,
            1,
          ),
          _buildNavItem(
            s,
            Icons.people_alt_rounded,
            'Patients',
            _currentIndex == 2,
            2,
          ),
          _buildNavItem(
            s,
            Icons.person_rounded,
            'Profile',
            _currentIndex == 3,
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    double Function(double) s,
    IconData icon,
    String label,
    bool active,
    int index,
  ) {
    final color = active ? ColorManager.primary : ColorManager.subtitleText;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: s(26)),
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
      ),
    );
  }
}
