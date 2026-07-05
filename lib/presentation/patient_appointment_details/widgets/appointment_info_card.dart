import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';

class AppointmentInfoCard extends StatelessWidget {
  final Map<String, dynamic> details;

  const AppointmentInfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final dateStr = details['bookingDate'] ?? details['date'] ?? details['appointmentDate'];
    final timeStr = details['time'] ?? details['appointmentTime'] ?? '';
    final status = details['status'] ?? 'Scheduled';
    final price = details['consultationPrice']?.toString() ?? details['price']?.toString() ?? 'N/A';
    final clinicName = details['clinicName'] ?? 'Clinic';
    
    final clinicAddress = details['clinicAddress'];
    final clinicPhone = details['clinicPhoneNumber'];
    final paymentMethod = details['paymentMethod'];
    final paymentStatus = details['paymentStatus'];
    final scheduleNotes = details['scheduleNotes'];

    String displayDate = dateStr?.toString() ?? 'Unknown Date';
    if (dateStr != null) {
      try {
        final parsed = DateTime.tryParse(dateStr.toString());
        if (parsed != null) {
          final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          displayDate = '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
        }
      } catch (_) {}
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
      child: Column(
        children: [
          _buildDetailRow(Icons.calendar_today_outlined, 'Date', displayDate),
          if (timeStr.isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRow(Icons.access_time, 'Time', timeStr),
          ],
          const Divider(height: 24),
          _buildDetailRow(Icons.local_hospital_outlined, 'Clinic', clinicName),
          if (clinicAddress != null && clinicAddress.toString().isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRow(Icons.location_on_outlined, 'Address', clinicAddress.toString()),
          ],
          if (clinicPhone != null && clinicPhone.toString().isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRow(Icons.phone_outlined, 'Phone', clinicPhone.toString()),
          ],
          const Divider(height: 24),
          _buildDetailRow(Icons.info_outline, 'Status', status, isStatus: true),
          const Divider(height: 24),
          _buildDetailRow(Icons.attach_money, 'Price', price == 'N/A' ? 'N/A' : '\$$price'),
          if (paymentMethod != null && paymentMethod.toString().isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRow(Icons.payment_outlined, 'Payment', paymentMethod.toString()),
          ],
          if (paymentStatus != null && paymentStatus.toString().isNotEmpty) ...[
            const Divider(height: 24),
            _buildDetailRow(Icons.check_circle_outline, 'Payment Status', paymentStatus.toString()),
          ],
          if (scheduleNotes != null && scheduleNotes.toString().isNotEmpty && scheduleNotes.toString().toLowerCase() != 'no notes added') ...[
            const Divider(height: 24),
            _buildDetailRow(Icons.notes_outlined, 'Notes', scheduleNotes.toString()),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isStatus = false}) {
    Color valueColor = ColorManager.headlineText;
    if (isStatus) {
      if (value.toLowerCase().contains('cancel')) valueColor = Colors.red;
      else if (value.toLowerCase().contains('complete')) valueColor = Colors.green;
      else valueColor = Colors.orange;
    }
    
    return Row(
      children: [
        Icon(icon, color: ColorManager.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: ColorManager.subtitleText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: valueColor,
              fontWeight: isStatus ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
