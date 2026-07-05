import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/booking/booking_model.dart';
import '../../../../../core/resources/color_manager.dart';
import '../cubit/doctor_home_cubit.dart';
import '../cubit/doctor_home_state.dart';

class DoctorPatientsView extends StatefulWidget {
  const DoctorPatientsView({super.key});

  @override
  State<DoctorPatientsView> createState() => _DoctorPatientsViewState();
}

class _DoctorPatientsViewState extends State<DoctorPatientsView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorHomeCubit, DoctorHomeState>(
      builder: (context, state) {
        if (state is! DoctorHomeSuccess) {
          return const Center(child: CircularProgressIndicator());
        }

        final bookings = state.allBookings;

        // Filter active bookings (pending or approved/accepted)
        final activeBookings = bookings.where((b) {
          final s = (b.status ?? '').toLowerCase();
          return !s.contains('cancel') &&
              !s.contains('reject') &&
              !s.contains('denied') &&
              !s.contains('complet');
        }).toList();

        // Filter local past bookings
        final pastLocal = bookings.where((b) {
          final s = (b.status ?? '').toLowerCase();
          return s.contains('cancel') ||
              s.contains('reject') ||
              s.contains('denied') ||
              s.contains('complet');
        }).toList();

        // Merge with historyBookings from History API
        final combinedPast = [...pastLocal, ...state.historyBookings];

        // De-duplicate by booking ID
        final uniquePast = <BookingModel>[];
        final seenIds = <int>{};
        for (final b in combinedPast) {
          if (seenIds.contains(b.id)) continue;
          seenIds.add(b.id);
          uniquePast.add(b);
        }

        final displayedList = _selectedTab == 0 ? activeBookings : uniquePast;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Patient Bookings',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: ColorManager.headlineText,
                ),
              ),
            ),
            
            // Tab Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Active Bookings',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 0 ? ColorManager.primary : ColorManager.bodyText,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTab = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: _selectedTab == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            'Past History',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _selectedTab == 1 ? ColorManager.primary : ColorManager.bodyText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '${displayedList.length} booking(s) listed',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: ColorManager.subtitleText,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: displayedList.isEmpty
                  ? _buildEmpty(_selectedTab == 0 ? 'No active bookings' : 'No booking history found')
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: displayedList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _DoctorPatientBookingCard(
                          booking: displayedList[index],
                          isProcessing: state.processingBookingId == displayedList[index].id,
                          onApprove: state.processingBookingId != null
                              ? null
                              : (id) => context
                                  .read<DoctorHomeCubit>()
                                  .acceptBooking(id),
                          onReject: state.processingBookingId != null
                              ? null
                              : (id) => context
                                  .read<DoctorHomeCubit>()
                                  .rejectBooking(id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.cairo(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _DoctorPatientBookingCard extends StatelessWidget {
  final BookingModel booking;
  final bool isProcessing;
  final Future<bool> Function(int)? onApprove;
  final Future<bool> Function(int)? onReject;

  const _DoctorPatientBookingCard({
    required this.booking,
    required this.isProcessing,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = booking.isPending;
    final statusColor = booking.isApproved
        ? const Color(0xFF059669)
        : booking.isRejected
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);
    final statusBg = booking.isApproved
        ? const Color(0xFFD1FAE5)
        : booking.isRejected
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFFEF3C7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: ColorManager.primary.withValues(alpha: 0.1),
                child: Text(
                  booking.patientName.isNotEmpty ? booking.patientName[0] : '?',
                  style: const TextStyle(
                    color: ColorManager.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.patientName,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      booking.clinicName ?? 'Clinic',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: ColorManager.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  booking.status ?? 'Pending',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (booking.dayOfWeek != null)
            Text(
              '${booking.dayOfWeek} ${booking.startTime ?? ''}${booking.endTime != null ? ' - ${booking.endTime}' : ''}',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
          if (booking.reasonForVisit != null) ...[
            const SizedBox(height: 6),
            Text(
              booking.reasonForVisit!,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF475569),
              ),
            ),
          ],
          if (isPending && onApprove != null && onReject != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            await onReject!(booking.id);
                          },
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isProcessing
                        ? null
                        : () async {
                            await onApprove!(booking.id);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
