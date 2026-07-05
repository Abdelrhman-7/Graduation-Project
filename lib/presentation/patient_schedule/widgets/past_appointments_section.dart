import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_home_dashboard/widgets/past_visit_item.dart';
import '../../patient_appointment_details/view/patient_appointment_details_view.dart';
import '../../widgets/rate_doctor_sheet.dart';

class PastAppointmentsSection extends StatelessWidget {
  final List<dynamic> appointments;

  const PastAppointmentsSection({super.key, required this.appointments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recentVisits,
          style: GoogleFonts.cairo(
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
            final doctorName =
                appt['doctorName'] ??
                appt['doctor']?['fullName'] ??
                appt['doctor']?['name'] ??
                'Unknown Doctor';
            final specialty =
                appt['specialty'] ??
                appt['doctor']?['specialty'] ??
                appt['clinicName'] ??
                appt['clinic']?['name'] ??
                'General Checkup';
            final date =
                appt['bookingDate'] ??
                appt['appointmentDate'] ??
                appt['date'] ??
                appt['scheduledDate'] ??
                '';
            final status = (appt['status'] ?? '').toString().toLowerCase();

            // Format date nicely
            String displayDate = date.toString();
            try {
              final parsedDate = DateTime.tryParse(date.toString());
              if (parsedDate != null) {
                final months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec',
                ];
                displayDate =
                    '${months[parsedDate.month - 1]} ${parsedDate.day}, ${parsedDate.year}';
              }
            } catch (_) {}

            // Status label for the badge
            String statusLabel = 'Completed';
            if (status.contains('cancel')) {
              statusLabel = 'Cancelled';
            } else if (status.contains('reject')) {
              statusLabel = 'Rejected';
            } else if (status.contains('denied')) {
              statusLabel = 'Denied';
            }

            final doctorId = appt['doctorId'] ?? appt['doctor']?['id'];
            final int parsedDoctorId = doctorId != null ? (doctorId is int ? doctorId : int.tryParse(doctorId.toString()) ?? 0) : 0;

            return PastVisitItem(
              doctorName: doctorName.toString(),
              specialty: specialty.toString(),
              date: displayDate,
              statusLabel: statusLabel,
              onRate: (parsedDoctorId > 0 && !status.contains('cancel') && !status.contains('reject') && !status.contains('denied'))
                  ? () {
                      RateDoctorSheet.show(context, parsedDoctorId);
                    }
                  : null,
              onDetails: () {
                final bookingId =
                    int.tryParse(appt['id']?.toString() ?? '0') ?? 0;
                if (bookingId > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PatientAppointmentDetailsView(bookingId: bookingId),
                    ),
                  );
                }
              },
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
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorManager.headlineText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your visit history will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
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
