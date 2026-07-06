import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';

class DoctorAppointmentDetailsView extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const DoctorAppointmentDetailsView({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    final String patientName = appointment['patientName'] ?? 'N/A';
    final String timeSlot = appointment['time'] ?? 'N/A';
    final String clinicName = appointment['type'] ?? 'N/A';
    final String status = appointment['status'] ?? 'N/A';

    final bool isApproved = status.toLowerCase().contains('approve') ||
        status.toLowerCase().contains('confirm');
    final bool isPending = status.toLowerCase().contains('pending');

    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.shade100;
    if (isApproved) {
      statusColor = const Color(0xFF16A34A); // Green
      statusBgColor = const Color(0xFFDCFCE7);
    } else if (isPending) {
      statusColor = const Color(0xFFEA580C); // Orange
      statusBgColor = const Color(0xFFFFEDD5);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appointment Details',
          style: GoogleFonts.cairo(
            color: const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Profile Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: ColorManager.primary.withOpacity(0.1),
                    backgroundImage: (appointment['patientImageUrl'] != null && appointment['patientImageUrl'].toString().isNotEmpty)
                        ? NetworkImage(appointment['patientImageUrl'].toString())
                        : null,
                    child: (appointment['patientImageUrl'] == null || appointment['patientImageUrl'].toString().isEmpty)
                        ? Text(
                            patientName.isNotEmpty ? patientName[0].toUpperCase() : 'P',
                            style: GoogleFonts.cairo(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: ColorManager.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    patientName,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detailed Info Cards
            Text(
              'Appointment Info',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x05000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Date & Time',
                    value: timeSlot,
                  ),
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  _buildDetailRow(
                    icon: Icons.local_hospital_rounded,
                    label: 'Clinic / Type',
                    value: clinicName,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
