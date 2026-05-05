import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';

class ProfileStatsRow extends StatelessWidget {
  final double scale;
  final String age;
  final String bloodType;

  const ProfileStatsRow({
    super.key,
    required this.scale,
    required this.age,
    required this.bloodType,
  });

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(16)),
      child: Row(
        children: [
          _buildStat(
            s,
            age,
            AppStrings.yearsOld,
            Icons.cake_outlined,
            const Color(0xFFF97316),
          ),
          SizedBox(width: s(12)),
          _buildStat(
            s,
            bloodType,
            AppStrings.universalDonor,
            Icons.bloodtype_outlined,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    double Function(double) s,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(s(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(s(16)),
          border: Border.all(color: ColorManager.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: s(10),
              offset: Offset(0, s(4)),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: s(20)),
                const Spacer(),
                Icon(
                  Icons.arrow_upward_rounded,
                  color: ColorManager.onlineStatus,
                  size: s(16),
                ),
              ],
            ),
            SizedBox(height: s(12)),
            Text(
              value,
              style: GoogleFonts.lexend(
                fontSize: s(20),
                fontWeight: FontWeight.w700,
                color: ColorManager.headlineText,
              ),
            ),
            SizedBox(height: s(4)),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: s(12),
                fontWeight: FontWeight.w500,
                color: ColorManager.subtitleText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
