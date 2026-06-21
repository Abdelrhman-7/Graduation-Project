import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';

class DoctorProfileSecurity extends StatelessWidget {
  const DoctorProfileSecurity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ACCOUNT SECURITY",
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: ColorManager.subtitleText,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_reset_rounded, color: ColorManager.headlineText, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Password",
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.headlineText,
                      ),
                    ),
                    Text(
                      "Last changed 4 months ago",
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        color: ColorManager.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: ColorManager.subtitleText),
            ],
          ),
        ),
      ],
    );
  }
}
