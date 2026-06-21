import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';

class DoctorProfileCredentials extends StatelessWidget {
  const DoctorProfileCredentials({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Credentials",
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorManager.headlineText,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.edit_note_rounded, color: ColorManager.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildCredentialItem(
          Icons.badge_outlined,
          "Medical License",
          "LIC-7729-0012-NY",
          const Color(0xFFE3F2FD),
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildCredentialItem(
          Icons.verified_user_outlined,
          "Verified Badge",
          "Board Certified Specialist",
          const Color(0xFFE8F5E9),
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildCredentialItem(IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.headlineText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: ColorManager.subtitleText,
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
