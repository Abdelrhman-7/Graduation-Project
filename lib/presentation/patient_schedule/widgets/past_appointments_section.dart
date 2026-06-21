import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_home_dashboard/widgets/past_visit_item.dart';

class PastAppointmentsSection extends StatelessWidget {
  final List<dynamic> appointments;

  const PastAppointmentsSection({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentVisits,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ColorManager.headlineText,
          ),
        ),
        const SizedBox(height: 24),
        if (appointments.isEmpty)
          _buildEmptyState()
        else
          ...appointments.map((appt) {
            final doctorName = appt['doctorName'] ??
                appt['doctor']?['fullName'] ??
                appt['doctor']?['name'] ??
                'Unknown Doctor';
            final specialty = appt['specialty'] ??
                appt['doctor']?['specialty'] ??
                appt['clinicName'] ??
                appt['clinic']?['name'] ??
                'General Checkup';
            final date = appt['bookingDate'] ??
                appt['appointmentDate'] ??
                appt['date'] ??
                appt['scheduledDate'] ??
                '';

            // Format date nicely
            String displayDate = date.toString();
            try {
              final parsedDate = DateTime.tryParse(date.toString());
              if (parsedDate != null) {
                final months = [
                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                ];
                displayDate =
                    '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
              }
            } catch (_) {}

            return PastVisitItem(
              doctorName: doctorName.toString(),
              specialty: specialty.toString(),
              date: displayDate,
            );
          }),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ColorManager.primaryOpacity10,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history_rounded,
                color: ColorManager.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No past visits',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorManager.headlineText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your visit history will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(
                fontSize: 13,
                color: ColorManager.bodyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
