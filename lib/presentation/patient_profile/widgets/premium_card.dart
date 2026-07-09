import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';

class PremiumCareCard extends StatelessWidget {
  final double scale;

  const PremiumCareCard({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: s(24), vertical: s(8)),
      padding: EdgeInsets.all(s(20)),
      decoration: BoxDecoration(
        color: ColorManager.premiumCardBg,
        borderRadius: BorderRadius.circular(s(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(s(10)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFFD700),
                  size: s(24),
                ),
              ),
              SizedBox(width: s(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.premiumCare,
                      style: GoogleFonts.cairo(
                        fontSize: s(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      AppStrings.schedulePhysical,
                      style: GoogleFonts.cairo(
                        fontSize: s(13),
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: s(20)),
          Row(
            children: [
              _buildBenefit(s, Icons.science_outlined, AppStrings.offLabs),
              SizedBox(width: s(12)),
              _buildBenefit(s, Icons.support_agent_rounded, '24/7 Support'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(double Function(double) s, IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(8)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(s(10)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: s(16)),
          SizedBox(width: s(8)),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: s(12),
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
