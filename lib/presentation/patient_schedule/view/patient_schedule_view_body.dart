import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_home_dashboard/view/patient_home_dashboard_view.dart';
import '../../patient_home_dashboard/widgets/appointment_card.dart';
import '../../patient_home_dashboard/widgets/past_visit_item.dart';

import '../../patient_home_dashboard/widgets/patient_bottom_nav.dart';

class PatientScheduleViewBody extends StatefulWidget {
  const PatientScheduleViewBody({super.key});

  @override
  State<PatientScheduleViewBody> createState() => _PatientScheduleViewBodyState();
}

class _PatientScheduleViewBodyState extends State<PatientScheduleViewBody> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for Past

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabNavigation(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedTab == 0) ...[
                  _buildUpcomingSection(),
                ] else ...[
                  _buildPastSection(),
                ],
              ],
            ),
          ),
        ),
        const PatientBottomNav(currentIndex: 1),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            AppStrings.appointments,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorManager.headlineText,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton(AppStrings.upcoming, _selectedTab == 0, () {
                setState(() => _selectedTab = 0);
              }),
            ),
            Expanded(
              child: _buildTabButton(AppStrings.past, _selectedTab == 1, () {
                setState(() => _selectedTab = 1);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? ColorManager.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active ? ColorManager.primary : ColorManager.bodyText,
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.nextSessions,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorManager.headlineText,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: ColorManager.pendingBg,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                '2 ${AppStrings.pending}',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const AppointmentCard(
          doctorName: 'Dr. Emily Chen',
          specialty: 'Cardiologist',
          dateTime: 'October 12, 2023',
          imagePath: '',
        ),
        const AppointmentCard(
          doctorName: 'Dr. Sarah Jenkins',
          specialty: 'Cardiologist',
          dateTime: 'October 15, 2023',
          imagePath: '',
        ),
      ],
    );
  }

  Widget _buildPastSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentVisits,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorManager.headlineText,
          ),
        ),
        const SizedBox(height: 24),
        const PastVisitItem(
          doctorName: 'Dr. Michael Ross',
          specialty: 'General Checkup',
          date: 'Sep 24, 2023',
        ),
        const PastVisitItem(
          doctorName: 'Lab One',
          specialty: 'Blood Analysis',
          date: 'Sep 12, 2023',
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 6, 24, 10 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.home_outlined,
              text: AppStrings.home,
              active: false,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientHomeDashboardView()),
                );
              },
            ),
          ),
          Expanded(child: _NavItem(icon: Icons.calendar_month_outlined, text: AppStrings.schedule, active: true)),
          Expanded(child: _NavItem(icon: Icons.favorite_border, text: AppStrings.myHealth)),
          Expanded(child: _NavItem(icon: Icons.person_outline, text: AppStrings.profile)),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.text, this.active = false, this.onTap});
  final IconData icon;
  final String text;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = active ? const Color(0xFF137FEC) : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: c),
          const SizedBox(height: 4),
          Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
