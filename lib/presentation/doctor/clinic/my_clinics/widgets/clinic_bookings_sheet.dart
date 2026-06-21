import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';

class ClinicBookingsSheet extends StatelessWidget {
  final int clinicId;
  final String clinicName;
  final List<dynamic> bookings;

  const ClinicBookingsSheet({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.bookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bookings - $clinicName",
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: bookings.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 32, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingItem(booking: booking);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No bookings yet for this clinic",
            style: GoogleFonts.lexend(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final dynamic booking;
  const _BookingItem({required this.booking});

  @override
  Widget build(BuildContext context) {
    // Assuming structure: {patientName: "...", time: "...", date: "..."}
    final name = booking['patientName'] ?? 'Unknown Patient';
    final date = booking['date'] ?? 'No Date';
    final time = booking['time'] ?? 'No Time';

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: ColorManager.primary.withOpacity(0.1),
          child: const Icon(Icons.person, color: ColorManager.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$date at $time",
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline_rounded,
            color: ColorManager.primary,
            size: 20,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}
