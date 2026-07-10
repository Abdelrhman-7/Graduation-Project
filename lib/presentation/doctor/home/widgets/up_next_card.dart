import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../core/resources/string_manager.dart';
import '../view/doctor_appointment_details_view.dart';

class UpNextCard extends StatelessWidget {
  final double scale;
  final Map<String, dynamic> appointment;

  const UpNextCard({super.key, required this.scale, required this.appointment});

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: s(24), vertical: s(8)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: s(20),
            offset: Offset(0, s(10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: s(20), vertical: s(12)),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF), // Light blue header strip
              borderRadius: BorderRadius.vertical(top: Radius.circular(s(24))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.upNext,
                  style: GoogleFonts.cairo(
                    fontSize: s(14),
                    fontWeight: FontWeight.w600,
                    color: ColorManager.primary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(10),
                    vertical: s(4),
                  ),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(s(20)),
                  ),
                  child: Text(
                    appointment['status'],
                    style: GoogleFonts.cairo(
                      fontSize: s(12),
                      fontWeight: FontWeight.w600,
                      color: ColorManager.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(s(20)),
            child: Column(
              children: [
                Row(
                  children: [
                    Builder(builder: (_) {
                      final rawUrl = appointment['patientImageUrl']?.toString().trim() ?? '';
                      final String? imageUrl = rawUrl.isEmpty
                          ? null
                          : rawUrl.startsWith('http')
                              ? rawUrl
                              : 'http://mediconnect.somee.com${rawUrl.startsWith('/') ? '' : '/'}$rawUrl';
                      final String initial = (appointment['patientName']?.toString() ?? 'P')
                          .trim()
                          .toUpperCase()
                          .characters
                          .firstOrNull ?? 'P';
                      if (imageUrl != null) {
                        return CircleAvatar(
                          radius: s(24),
                          backgroundColor: ColorManager.primary.withOpacity(0.1),
                          backgroundImage: NetworkImage(imageUrl),
                          onBackgroundImageError: (_, __) {},
                          child: null,
                        );
                      }
                      return CircleAvatar(
                        radius: s(24),
                        backgroundColor: ColorManager.primary,
                        child: Text(
                          initial,
                          style: GoogleFonts.cairo(
                            fontSize: s(18),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
                    SizedBox(width: s(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment['patientName'],
                            style: GoogleFonts.cairo(
                              fontSize: s(18),
                              fontWeight: FontWeight.w700,
                              color: ColorManager.headlineText,
                            ),
                          ),
                          Text(
                            appointment['type'],
                            style: GoogleFonts.cairo(
                              fontSize: s(14),
                              fontWeight: FontWeight.w400,
                              color: ColorManager.subtitleText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Removed the video camera icon container as requested
                  ],
                ),
                SizedBox(height: s(20)),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorAppointmentDetailsView(
                            appointment: appointment,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: s(14)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(s(16)),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'View',
                      style: GoogleFonts.cairo(
                        fontSize: s(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
