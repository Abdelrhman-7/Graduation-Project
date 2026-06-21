import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/string_manager.dart';
import '../../chat/view/chat_view.dart';
import '../../lab_results/view/lab_results_view.dart';
import '../../patient_profile/view/patient_profile_view.dart';
import '../../patient_booking/view/patient_booking_view.dart';
import '../widgets/patient_bottom_nav.dart';
import '../cubit/patient_home_dashboard_cubit.dart';
import '../cubit/patient_home_dashboard_state.dart';

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

            return Container(
              color: bg,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    children: [
                      _TopBar(scale: scale, userName: userName, imageUrl: imageUrl),
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
                              _TitleRow(
                                scale: scale,
                                title: AppStrings.nextAppointment,
                                action: AppStrings.seeAll,
                              ),
                              SizedBox(height: s(12)),
                              _NextAppointmentCard(scale: scale),
                              SizedBox(height: s(31)),
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
                                          builder: (_) => const PatientBookingView(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickAction(
                                    scale: scale,
                                    icon: Icons.medical_services_outlined,
                                    label: AppStrings.refill,
                                    color: const Color(0xFFF97316),
                                  ),
                                  _QuickAction(
                                    scale: scale,
                                    icon: Icons.chat_bubble_outline,
                                    label: AppStrings.chat,
                                    color: const Color(0xFF22C55E),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ChatView(),
                                        ),
                                      );
                                    },
                                  ),
                                  _QuickAction(
                                    scale: scale,
                                    icon: Icons.science_outlined,
                                    label: AppStrings.labs,
                                    color: const Color(0xFFA855F7),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const LabResultsView(),
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
                              _MedicationTile(
                                scale: scale,
                                icon: Icons.medication_outlined,
                                iconBg: const Color(0xFFFEF2F2),
                                title: 'Amoxicillin',
                                subtitle: '500mg • 1 pill/day',
                                badge: AppStrings.active,
                                badgeColor: const Color(0xFF16A34A),
                              ),
                              SizedBox(height: s(12)),
                              _MedicationTile(
                                scale: scale,
                                icon: Icons.assignment_outlined,
                                iconBg: const Color(0xFFF1F5F9),
                                title: 'Lisinopril',
                                subtitle: '10mg • 1 pill/day',
                                badge: AppStrings.refillBadge,
                                badgeColor: const Color(0xFF2563EB),
                              ),
                              SizedBox(height: s(16)),
                              _StatsCard(scale: scale),
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

  TextStyle _headingStyle(double s) => GoogleFonts.lexend(
    fontSize: 18 * s,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF0F172A),
    height: 22.5 / 18,
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale, required this.userName, this.imageUrl});
  final double scale;
  final String userName;
  final String? imageUrl;

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
                // لما يرجع من الـ Profile، نعيد تحميل البيانات
                if (context.mounted) {
                  context.read<PatientHomeDashboardCubit>().getDashboardData();
                }
              });
            },
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 20 * scale,
                  backgroundColor: const Color(0xFFE2E8F0),
                  backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? NetworkImage(imageUrl!) as ImageProvider
                      : null,
                  child: (imageUrl == null || imageUrl!.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 20 * scale,
                          color: const Color(0xFF64748B),
                        )
                      : null,
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
                  style: GoogleFonts.lexend(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  userName,
                  style: GoogleFonts.lexend(
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
          Container(
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
                  Icons.notifications_none_rounded,
                  size: 22 * scale,
                  color: const Color(0xFF0F172A),
                ),
                Positioned(
                  right: 10 * scale,
                  top: 10 * scale,
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
        ],
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow({
    required this.scale,
    required this.title,
    required this.action,
  });
  final double scale;
  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            action,
            style: GoogleFonts.lexend(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF137FEC),
            ),
          ),
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF137FEC),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80 * scale,
            height: 80 * scale,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: const Color(0x33FFFFFF),
                width: 2 * scale,
              ),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://i.pravatar.cc/300?u=doctor',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 9 * scale,
                        vertical: 3 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(4 * scale),
                        border: Border.all(color: const Color(0x1AFFFFFF)),
                      ),
                      child: Text(
                        AppStrings.tomorrow,
                        style: GoogleFonts.lexend(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      '10:00 AM',
                      style: GoogleFonts.lexend(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xE6FFFFFF),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Dr. Emily Chen',
                  style: GoogleFonts.lexend(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Cardiologist',
                  style: GoogleFonts.lexend(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE7EDF3),
                  ),
                ),
                SizedBox(height: 16 * scale),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36 * scale,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppStrings.checkIn,
                          style: GoogleFonts.lexend(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF137FEC),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Container(
                      width: 36 * scale,
                      height: 36 * scale,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(color: const Color(0x1AFFFFFF)),
                      ),
                      child: Icon(
                        Icons.videocam_outlined,
                        color: Colors.white,
                        size: 18 * scale,
                      ),
                    ),
                  ],
                ),
              ],
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
              style: GoogleFonts.lexend(
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
                      style: GoogleFonts.lexend(
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
                        style: GoogleFonts.lexend(
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
                  style: GoogleFonts.lexend(
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
  const _StatsCard({required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LabResultsView()),
        );
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
              value: '72',
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
              label: AppStrings.bloodType,
              value: 'O+',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.lexend(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  if (suffix.isNotEmpty) ...[
                    SizedBox(width: 2 * scale),
                    Text(
                      suffix,
                      style: GoogleFonts.lexend(
                        fontSize: 12 * scale,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
