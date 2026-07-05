import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateScheduleHeader extends StatelessWidget {
  const CreateScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Set Availability",
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Select a clinic and set your working hours.",
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
