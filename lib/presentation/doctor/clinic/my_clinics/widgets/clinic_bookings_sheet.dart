import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/booking/booking_model.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../core/utils/time_formatter.dart';

class ClinicBookingsSheet extends StatelessWidget {
  final int clinicId;
  final String clinicName;
  final List<dynamic> bookings;
  final bool isProcessing;
  final Future<void> Function(int bookingId)? onAccept;
  final Future<void> Function(int bookingId)? onReject;

  const ClinicBookingsSheet({
    super.key,
    required this.clinicId,
    required this.clinicName,
    required this.bookings,
    this.isProcessing = false,
    this.onAccept,
    this.onReject,
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
              Expanded(
                child: Text(
                  "Bookings - $clinicName",
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
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
                      final raw = bookings[index];
                      final booking = raw is Map<String, dynamic>
                          ? BookingModel.fromJson(raw)
                          : BookingModel(
                              id: index,
                              patientName: 'Unknown Patient',
                            );
                      return _BookingItem(
                        booking: booking,
                        isProcessing: isProcessing,
                        onAccept: onAccept,
                        onReject: onReject,
                      );
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
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final BookingModel booking;
  final bool isProcessing;
  final Future<void> Function(int bookingId)? onAccept;
  final Future<void> Function(int bookingId)? onReject;

  const _BookingItem({
    required this.booking,
    this.isProcessing = false,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = booking.dayOfWeek != null
        ? '${booking.dayOfWeek} ${TimeFormatter.formatTime(booking.startTime)}'
        : '${booking.date ?? 'No Date'}${booking.time != null ? ' at ${TimeFormatter.formatTime(booking.time)}' : ''}';

    final isPending = booking.isPending;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: ColorManager.primary.withOpacity(0.1),
              child: Text(
                booking.patientName.isNotEmpty ? booking.patientName[0] : '?',
                style: const TextStyle(
                  color: ColorManager.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.patientName,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeLabel,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  if (booking.reasonForVisit != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      booking.reasonForVisit!,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (booking.status != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status!,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPending
                        ? const Color(0xFFD97706)
                        : const Color(0xFF059669),
                  ),
                ),
              ),
          ],
        ),
        if (isPending && onAccept != null && onReject != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : () => onReject!(booking.id),
                  child: Text('Reject', style: GoogleFonts.cairo()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : () => onAccept!(booking.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                  ),
                  child: Text(
                    'Accept',
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
