import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_home_dashboard/widgets/appointment_card.dart';

class UpcomingAppointmentsSection extends StatelessWidget {
  final List<dynamic> appointments;

  const UpcomingAppointmentsSection({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.nextSessions,
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: ColorManager.headlineText,
              ),
            ),
            _PendingBadge(count: appointments.length),
          ],
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
                '';
            final date = appt['bookingDate'] ??
                appt['appointmentDate'] ??
                appt['date'] ??
                appt['scheduledDate'] ??
                '';
            final timeSlot = appt['timeSlot'] ??
                appt['time'] ??
                appt['startTime'] ??
                '10:00 AM';

            // Format date nicely if possible
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

            return AppointmentCard(
              doctorName: doctorName.toString(),
              specialty: specialty.toString(),
              dateTime: displayDate,
              timeSlot: timeSlot.toString(),
              imagePath: appt['doctor']?['imageUrl']?.toString() ?? '',
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
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: ColorManager.primary,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No upcoming appointments',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorManager.headlineText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book a clinic appointment to get started.',
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

class _PendingBadge extends StatelessWidget {
  final int count;
  const _PendingBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ColorManager.pendingBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        '$count ${AppStrings.pending}',
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: ColorManager.primary,
        ),
      ),
    );
  }
}
