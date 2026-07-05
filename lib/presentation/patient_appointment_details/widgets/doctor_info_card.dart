import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';

class DoctorInfoCard extends StatelessWidget {
  final Map<String, dynamic> details;

  const DoctorInfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final doctor = details['doctor'] ?? {};
    final doctorName = doctor['fullName'] ?? doctor['name'] ?? details['doctorName'] ?? 'Unknown Doctor';
    final specialty = doctor['specialty'] ?? details['specialty'] ?? 'Specialty';
    final imageUrl = doctor['imageUrl'] ?? details['imageUrl'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: ColorManager.primaryOpacity10,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty ? const Icon(Icons.person, color: ColorManager.primary) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: ColorManager.headlineText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
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
