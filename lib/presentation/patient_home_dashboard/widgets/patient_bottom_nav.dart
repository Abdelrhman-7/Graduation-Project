import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_schedule/view/patient_schedule_view.dart';
import '../../lab_results/view/lab_results_view.dart';
import '../../patient_profile/view/patient_profile_view.dart';

class PatientBottomNav extends StatelessWidget {
  const PatientBottomNav({super.key, this.currentIndex = 0});
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
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
              active: currentIndex == 0,
              onTap: () {
                if (currentIndex != 0) {
                   Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.calendar_month_outlined,
              text: AppStrings.schedule,
              active: currentIndex == 1,
              onTap: () {
                if (currentIndex != 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientScheduleView(),
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.favorite_border,
              text: AppStrings.myHealth,
              active: currentIndex == 2,
              onTap: () {
                if (currentIndex != 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LabResultsView(),
                    ),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.person_outline,
              text: AppStrings.profile,
              active: currentIndex == 3,
              onTap: () {
                if (currentIndex != 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientProfileView(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.text,
    this.active = false,
    this.onTap,
  });
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
