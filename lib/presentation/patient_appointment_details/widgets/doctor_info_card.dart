import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';

class DoctorInfoCard extends StatelessWidget {
  final Map<String, dynamic> details;

  const DoctorInfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final doctor = details['doctor'] ?? details['Doctor'] ?? {};

    // Collect doctor name from all possible paths
    final doctorName = (doctor is Map ? (doctor['fullName'] ?? doctor['FullName'] ?? doctor['name'] ?? doctor['Name']) : null)
        ?? details['doctorName'] ?? details['DoctorName'] ?? details['doctorFullName'] ?? 'Unknown Doctor';

    // Collect specialty from all possible paths
    final specialty = (doctor is Map ? (doctor['specialty'] ?? doctor['Specialty']) : null)
        ?? details['specialty'] ?? details['clinicName'] ?? 'Specialty';

    // Collect image URL from all possible paths
    String resolveImage(dynamic src) {
      if (src == null) return '';
      final s = src.toString().trim();
      if (s.isEmpty) return '';
      if (s.startsWith('http')) return s;
      return 'http://clinicbook.runasp.net${s.startsWith('/') ? '' : '/'}$s';
    }

    String imageUrl = '';
    if (doctor is Map) {
      imageUrl = resolveImage(
        doctor['imageUrl'] ?? doctor['ImageUrl'] ??
        doctor['profileImageUrl'] ?? doctor['ProfileImageUrl'] ??
        doctor['displayImageUrl'] ?? doctor['DisplayImageUrl'] ??
        doctor['image'] ?? doctor['Image'] ?? doctor['photo'] ?? doctor['photoUrl'],
      );
    }
    if (imageUrl.isEmpty) {
      imageUrl = resolveImage(
        details['imageUrl'] ?? details['ImageUrl'] ??
        details['doctorImageUrl'] ?? details['DoctorImageUrl'] ??
        details['profileImageUrl'] ?? details['ProfileImageUrl'] ??
        details['displayImageUrl'] ?? details['DisplayImageUrl'],
      );
    }
    // Also check inside schedule > doctor
    if (imageUrl.isEmpty) {
      final sched = details['schedule'] ?? details['Schedule'];
      if (sched is Map) {
        final schedDoc = sched['doctor'] ?? sched['Doctor'];
        if (schedDoc is Map) {
          imageUrl = resolveImage(
            schedDoc['imageUrl'] ?? schedDoc['ImageUrl'] ??
            schedDoc['profileImageUrl'] ?? schedDoc['ProfileImageUrl'] ??
            schedDoc['displayImageUrl'] ?? schedDoc['DisplayImageUrl'],
          );
        }
      }
    }

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
