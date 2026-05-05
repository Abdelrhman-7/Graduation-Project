import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';

class UpNextCard extends StatelessWidget {
  final double scale;
  final Map<String, dynamic> appointment;

  const UpNextCard({super.key, required this.scale, required this.appointment});

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: s(24), vertical: s(8)),
      padding: EdgeInsets.all(s(20)),
      decoration: BoxDecoration(
        color: ColorManager.primary,
        borderRadius: BorderRadius.circular(s(24)),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.3),
            blurRadius: s(20),
            offset: Offset(0, s(10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.upNext,
                style: GoogleFonts.lexend(
                  fontSize: s(14),
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: s(10), vertical: s(4)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(s(20)),
                ),
                child: Text(
                  appointment['status'],
                  style: GoogleFonts.lexend(
                    fontSize: s(12),
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s(16)),
          Row(
            children: [
              Container(
                width: s(48),
                height: s(48),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage('https://www.figma.com/api/mcp/asset/a1b2c3d4'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(width: s(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['patientName'],
                      style: GoogleFonts.lexend(
                        fontSize: s(18),
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      appointment['type'],
                      style: GoogleFonts.lexend(
                        fontSize: s(14),
                        fontWeight: FontWeight.w400,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(s(8)),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.videocam_rounded,
                  color: ColorManager.primary,
                  size: s(24),
                ),
              ),
            ],
          ),
          SizedBox(height: s(20)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: ColorManager.primary,
                padding: EdgeInsets.symmetric(vertical: s(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(16)),
                ),
                elevation: 0,
              ),
              child: Text(
                AppStrings.startVideoVisit,
                style: GoogleFonts.lexend(
                  fontSize: s(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
