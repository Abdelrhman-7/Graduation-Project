import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';

class AppointmentInfoCard extends StatelessWidget {
  final Map<String, dynamic> details;

  const AppointmentInfoCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    final dateStr = details['bookingDate'] ?? details['date'] ?? details['appointmentDate'];
    final timeStr = details['time'] ?? details['timeSlot'] ?? details['appointmentTime'] ?? '';
    final status = details['status'] ?? 'Scheduled';
    final price = details['consultationPrice']?.toString() ?? details['price']?.toString() ?? 'N/A';
    final clinicName = details['clinicName'] ?? 'Clinic';
    
    final clinicAddress = details['clinicAddress'];
    final clinicPhone = details['clinicPhoneNumber'];
    final paymentMethod = details['paymentMethod'];
    final rawPayStatus = details['paymentStatus']?.toString() ?? '';
    // Show Paid if status is Paid OR paymentStatus says so
    final isPaid = rawPayStatus.toLowerCase().contains('paid') ||
        status.toString().toLowerCase() == 'paid';
    final paymentStatus = isPaid ? 'Paid' : (rawPayStatus.isNotEmpty ? rawPayStatus : null);
    final scheduleNotes = details['scheduleNotes'];

    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

    // Try parsing the date from API
    String displayDate = 'Unknown Date';
    bool dateResolved = false;
    if (dateStr != null && dateStr.toString().isNotEmpty) {
      try {
        final parsed = DateTime.tryParse(dateStr.toString());
        if (parsed != null) {
          // Accept the date only if it's within the next ~6 months
          final sixMonthsFromNow = DateTime.now().add(const Duration(days: 185));
          if (parsed.isBefore(sixMonthsFromNow)) {
            displayDate = '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
            dateResolved = true;
          }
        }
      } catch (_) {}
    }

    // If date is missing or too far in future, derive from dayOfWeek
    if (!dateResolved) {
      final dayOfWeek = details['dayOfWeek']?.toString() ??
          details['schedule']?['dayOfWeek']?.toString() ?? '';
      // Also try to extract dayOfWeek from timeSlot e.g. "Sunday 09:00 - 09:30"
      final timeSlotStr = timeStr.toString().trim();
      final dayNames = {
        'monday': DateTime.monday, 'tuesday': DateTime.tuesday,
        'wednesday': DateTime.wednesday, 'thursday': DateTime.thursday,
        'friday': DateTime.friday, 'saturday': DateTime.saturday,
        'sunday': DateTime.sunday,
      };
      String foundDay = dayOfWeek.toLowerCase().trim();
      if (foundDay.isEmpty) {
        for (final d in dayNames.keys) {
          if (timeSlotStr.toLowerCase().startsWith(d)) {
            foundDay = d;
            break;
          }
        }
      }
      final targetWeekday = dayNames[foundDay];
      if (targetWeekday != null) {
        final now = DateTime.now();
        int diff = targetWeekday - now.weekday;
        if (diff < 0) diff += 7;
        final nextDate = now.add(Duration(days: diff));
        displayDate = '${months[nextDate.month - 1]} ${nextDate.day}, ${nextDate.year}';
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
