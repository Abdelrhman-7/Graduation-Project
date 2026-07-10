import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_reviews/view/patient_reviews_view.dart';
import '../../patient_profile/view/patient_profile_view.dart';
import '../../patient_booking/view/patient_booking_view.dart';
import '../widgets/patient_bottom_nav.dart';
import '../widgets/patient_notifications_sheet.dart';
import '../cubit/patient_home_dashboard_cubit.dart';
import '../cubit/patient_home_dashboard_state.dart';
import '../../patient_schedule/cubit/patient_schedule_cubit.dart';
import '../../patient_schedule/widgets/upcoming_appointments_section.dart';
import '../../patient_schedule/view/patient_schedule_view.dart';
import '../../patient_emergency/view/patient_emergency_view.dart';

class PatientHomeDashboardViewBody extends StatelessWidget {
  const PatientHomeDashboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFFEF2F2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.15);
        double s(double v) => v * scale;

        return BlocBuilder<
          PatientHomeDashboardCubit,
          PatientHomeDashboardState
        >(
          builder: (context, state) {
            if (state is PatientHomeDashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is PatientHomeDashboardError) {
              return Center(child: Text(state.message));
            }

            // Extracting values from state if success
            final userName = state is PatientHomeDashboardSuccess
                ? state.userName
                : 'Alex';
            final imageUrl = state is PatientHomeDashboardSuccess
                ? state.imageUrl
                : null;
            final unreadNotifications = state is PatientHomeDashboardSuccess
                ? state.unreadNotifications
                : 0;
            final heartRate = state is PatientHomeDashboardSuccess
                ? state.heartRate
                : '0';
            final bloodPressure = state is PatientHomeDashboardSuccess
                ? state.bloodPressure
                : '0/0';

            final medications = state is PatientHomeDashboardSuccess
                ? state.medications
                : [];

            final scheduleState = context.watch<PatientScheduleCubit>().state;

            return Container(
              color: bg,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      _TopBar(
                        scale: scale,
                        userName: userName,
                        imageUrl: imageUrl,
                        unreadNotifications: unreadNotifications,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            s(16),
                            s(23),
                            s(16),
                            s(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (scheduleState is PatientScheduleSuccess) ...[
                                /* Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'My Appointments',
                                      style: _headingStyle(scale),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const PatientScheduleView(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'See All',
                                        style: GoogleFonts.cairo(
                                          color: const Color(0xFF137FEC),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),*/
                                SizedBox(height: s(16)),
                                UpcomingAppointmentsSection(
                                  appointments:
                                      scheduleState
                                          .upcomingAppointments
                                          .isNotEmpty
                                      ? [
                                          scheduleState
                                              .upcomingAppointments
                                              .last,
                                        ]
                                      : [],
                                ),
                                SizedBox(height: s(31)),
                              ] else if (scheduleState
                                  is PatientScheduleLoading) ...[
                                const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                SizedBox(height: s(31)),
                              ],
                              Text(
                                AppStrings.quickActions,
                                style: _headingStyle(scale),
                              ),
                              SizedBox(height: s(16)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _QuickAction(
                                    scale: scale,
                                    icon: Icons.calendar_today_outlined,
                                    label: AppStrings.book,
                                    color: const Color(0xFF137FEC),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PatientBookingView(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickAction(
                                    scale: scale,
                                    icon: Icons.emergency,
                                    label: 'Emergency',
                                    color: Colors.red,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PatientEmergencyView(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickAction(
                                    scale: scale,
                                    icon: Icons.assignment_outlined,
                                    label: 'Details',
                                    color: const Color(0xFF22C55E),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PatientScheduleView(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickAction(
                                    scale: scale,
                                    icon: Icons.star_rate_rounded,
                                    label: 'My Doctors',
                                    color: const Color(
                                      0xFFEAB308,
                                    ), // Yellow for star/reviews
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const PatientReviewsView(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: s(31)),
                              Text(
                                AppStrings.currentMedications,
                                style: _headingStyle(scale),
                              ),
                              SizedBox(height: s(16)),
                              if (medications.isEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: s(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No current medications',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...medications.map((med) {
                                  final isRefill =
                                      med['badge'].toString().toLowerCase() ==
                                      'refill';
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: s(12)),
                                    child: _MedicationTile(
                                      scale: scale,
                                      icon: isRefill
                                          ? Icons.assignment_outlined
                                          : Icons.medication_outlined,
                                      iconBg: isRefill
                                          ? const Color(0xFFF1F5F9)
                                          : const Color(0xFFFEF2F2),
                                      title:
                                          med['title']?.toString() ??
                                          'Medication',
                                      subtitle:
                                          med['subtitle']?.toString() ?? '',
                                      badge:
                                          med['badge']?.toString() ?? 'Active',
                                      badgeColor: isRefill
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFF16A34A),
                                    ),
                                  );
                                }),
                              SizedBox(height: s(16)),
                              _StatsCard(
                                scale: scale,
                                heartRate: heartRate,
                                bloodPressure: bloodPressure,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const PatientBottomNav(currentIndex: 0),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  TextStyle _headingStyle(double s) => GoogleFonts.cairo(
    fontSize: 18 * s,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF0F172A),
    height: 22.5 / 18,
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.scale,
    required this.userName,
    this.imageUrl,
    this.unreadNotifications = 0,
  });
  final double scale;
  final String userName;
  final String? imageUrl;
  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 110 * scale),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        24 * scale,
        48 * scale,
        24 * scale,
        16 * scale,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientProfileView()),
              ).then((_) {
                // لما يرجع من الـ Profile، نعيد تحميل البيانات بدون عرض شاشة التحميل
                if (context.mounted) {
                  context.read<PatientHomeDashboardCubit>().getDashboardData(
                    silent: true,
                  );
                }
              });
            },
            child: Stack(
              children: [
                ClipOval(
                  child: Container(
                    width: 40 * scale,
                    height: 40 * scale,
                    color: const Color(0xFFE2E8F0),
                    child: (imageUrl != null && imageUrl!.isNotEmpty)
                        ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              size: 20 * scale,
                              color: const Color(0xFF64748B),
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 20 * scale,
                            color: const Color(0xFF64748B),
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12 * scale,
                    height: 12 * scale,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2 * scale),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.goodMorning,
                  style: GoogleFonts.cairo(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userName,
                  style: GoogleFonts.cairo(
                    fontSize: 19 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D1B20),
                    letterSpacing: -0.5 * scale,
                    height: 1.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () async {
              await showPatientNotificationsSheet(context);
              if (context.mounted) {
                context.read<PatientHomeDashboardCubit>().getDashboardData(
                  silent: true,
                );
              }
            },
            child: Container(
              width: 40 * scale,
              height: 40 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    unreadNotifications > 0
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    size: 22 * scale,
                    color: const Color(0xFF0F172A),
                  ),
                  if (unreadNotifications > 0)
                    Positioned(
                      right: 8 * scale,
                      top: 8 * scale,
                      child: Container(
                        width: 8 * scale,
                        height: 8 * scale,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.scale,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });
  final double scale;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80.5 * scale,
        child: Column(
          children: [
            Container(
              width: 56 * scale,
              height: 56 * scale,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 1,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, size: 24 * scale, color: color),
            ),
            SizedBox(height: 8 * scale),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.scale,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
  });
  final double scale;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 82 * scale),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 12 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48 * scale,
            height: 48 * scale,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(icon, color: const Color(0xFF137FEC), size: 22 * scale),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale,
                        vertical: 2 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(999 * scale),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.cairo(
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                          letterSpacing: 0.5 * scale,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: const Color(0xFF94A3B8),
            size: 22 * scale,
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.scale,
    required this.heartRate,
    required this.bloodPressure,
  });
  final double scale;
  final String heartRate;
  final String bloodPressure;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Stats tapped
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          17 * scale,
          10 * scale,
          17 * scale,
          17 * scale,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF1F5F9), Colors.white],
          ),
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            _StatItem(
              scale: scale,
              icon: Icons.favorite_border,
              iconBg: const Color(0xFFFEE2E2),
              label: AppStrings.heartRate,
              value: heartRate,
              suffix: AppStrings.bpm,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              child: Container(
                width: 1,
                height: 32 * scale,
                color: const Color(0xFFE2E8F0),
              ),
            ),
            _StatItem(
              scale: scale,
              icon: Icons.bloodtype_outlined,
              iconBg: const Color(0xFFE7EDF3),
              iconColor: const Color(0xFF3B82F6),
              label: 'Blood Pressure',
              value: bloodPressure,
              suffix: 'mmHg',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.scale,
    required this.icon,
    required this.iconBg,
    this.iconColor = const Color(0xFFEF4444),
    required this.label,
    required this.value,
    this.suffix = '',
  });
  final double scale;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(icon, size: 21 * scale, color: iconColor),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.cairo(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (suffix.isNotEmpty) ...[
                        SizedBox(width: 2 * scale),
                        Text(
                          suffix,
                          style: GoogleFonts.cairo(
                            fontSize: 12 * scale,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
