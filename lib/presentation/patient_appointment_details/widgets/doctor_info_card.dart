import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/schudule/doctorModel.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/utils/avatar_helper.dart';

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

    // Collect doctorId from all possible paths
    final doctorIdStr = doctor is Map ? (doctor['id'] ?? doctor['Id']) : null;
    final fallbackDoctorIdStr = details['doctorId'] ?? details['DoctorId'] ?? details['doctor_id'];
    
    int doctorId = 0;
    if (doctorIdStr != null) {
      doctorId = doctorIdStr is int ? doctorIdStr : int.tryParse(doctorIdStr.toString()) ?? 0;
    } else if (fallbackDoctorIdStr != null) {
      doctorId = fallbackDoctorIdStr is int ? fallbackDoctorIdStr : int.tryParse(fallbackDoctorIdStr.toString()) ?? 0;
    }

    String imageUrl = '';
    if (doctor is Map) {
      imageUrl = doctor['imageUrl'] ?? doctor['ImageUrl'] ??
                 doctor['profileImageUrl'] ?? doctor['ProfileImageUrl'] ??
                 doctor['displayImageUrl'] ?? doctor['DisplayImageUrl'] ??
                 doctor['image'] ?? doctor['Image'] ?? doctor['photo'] ?? doctor['photoUrl'] ?? '';
    }
    if (imageUrl.isEmpty) {
      imageUrl = details['imageUrl'] ?? details['ImageUrl'] ??
                 details['doctorImageUrl'] ?? details['DoctorImageUrl'] ??
                 details['profileImageUrl'] ?? details['ProfileImageUrl'] ??
                 details['displayImageUrl'] ?? details['DisplayImageUrl'] ?? '';
    }
    if (imageUrl.isEmpty) {
      final sched = details['schedule'] ?? details['Schedule'];
      if (sched is Map) {
        final schedDoc = sched['doctor'] ?? sched['Doctor'];
        if (schedDoc is Map) {
          imageUrl = schedDoc['imageUrl'] ?? schedDoc['ImageUrl'] ??
                     schedDoc['profileImageUrl'] ?? schedDoc['ProfileImageUrl'] ??
                     schedDoc['displayImageUrl'] ?? schedDoc['DisplayImageUrl'] ?? '';
        }
      }
    }
    
    final docModel = DoctorModel(
      id: doctorId,
      fullName: doctorName.toString(),
      imageUrl: imageUrl,
    );
    
    final finalImageUrl = AvatarHelper.getDoctorAvatar(
      doctorId: docModel.id,
      imageUrl: docModel.imageUrl,
    );

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
            backgroundImage: finalImageUrl.isNotEmpty ? NetworkImage(finalImageUrl) : null,
            child: finalImageUrl.isEmpty ? const Icon(Icons.person, color: ColorManager.primary) : null,
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
