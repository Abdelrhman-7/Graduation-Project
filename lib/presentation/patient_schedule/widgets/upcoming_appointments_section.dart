import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/utils/avatar_helper.dart';
import '../../../../data/models/schudule/doctorModel.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../patient_home_dashboard/widgets/appointment_card.dart';
import '../../patient_booking/view/patient_booking_view.dart';
import '../../patient_booking/view/payment_card_view.dart';
import '../../patient_booking/cubit/patient_booking_cubit.dart';
import '../cubit/patient_schedule_cubit.dart';
import '../../patient_appointment_details/view/patient_appointment_details_view.dart';

class UpcomingAppointmentsSection extends StatelessWidget {
  final List<dynamic> appointments;

  const UpcomingAppointmentsSection({super.key, required this.appointments});

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
              style: GoogleFonts.cairo(
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
            String rawDocName = (appt['realDoctorName'] ?? appt['doctorName'] ?? '').toString();
            if (rawDocName.isEmpty) {
              rawDocName = (appt['DoctorName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['doctorFullName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['DoctorFullName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['doctor']?['fullName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['doctor']?['name'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['doctor']?['userName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['doctor']?['UserName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['schedule']?['doctor']?['fullName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['schedule']?['doctor']?['name'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['schedule']?['doctor']?['userName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['userName'] ?? '').toString();
            }
            if (rawDocName.isEmpty) {
              rawDocName = (appt['UserName'] ?? '').toString();
            }

            final doctorName =
                (rawDocName.isEmpty || rawDocName == 'null')
                ? 'Unknown Doctor'
                : rawDocName;

            final specialty =
                appt['specialty'] ??
                appt['doctor']?['specialty'] ??
                appt['clinicName'] ??
                appt['clinic']?['name'] ??
                '';
            final status = (appt['status'] ?? '').toString().toLowerCase();
            final specialtyDisplay = status.contains('pending')
                ? 'Waiting for doctor approval'
                : status.contains('approved') ||
                      status.contains('accept') ||
                      status.contains('confirm') ||
                      status.contains('paid')
                ? 'Confirmed appointment'
                : specialty.toString();
            final date =
                appt['bookingDate'] ??
                appt['appointmentDate'] ??
                appt['date'] ??
                appt['scheduledDate'] ??
                '';
            final timeStr =
                (appt['timeSlot'] ??
                        appt['time'] ??
                        appt['startTime'] ??
                        '10:00 AM')
                    .toString();

            String timeSlot = timeStr;
            if (timeSlot.isNotEmpty && timeSlot != '10:00 AM') {
              try {
                final RegExp timeRegex = RegExp(
                  r'(\d{1,2}):(\d{2})(?::\d{2})?',
                );
                final match = timeRegex.firstMatch(timeSlot);
                if (match != null) {
                  final int hour = int.parse(match.group(1)!);
                  final int min = int.parse(match.group(2)!);
                  final String period = hour >= 12 ? 'PM' : 'AM';
                  final int displayHour = hour > 12
                      ? hour - 12
                      : (hour == 0 ? 12 : hour);
                  timeSlot =
                      '${displayHour.toString().padLeft(2, '0')}:${min.toString().padLeft(2, '0')} $period';
                }
              } catch (_) {}
            }

            final bookingId = appt['id'] is int
                ? appt['id'] as int
                : int.tryParse(appt['id']?.toString() ?? '') ?? 0;

            String resolveImageUrl(dynamic src) {
              if (src == null) return '';
              final s = src.toString().trim();
              if (s.isEmpty) return '';
              if (s.startsWith('http')) return s;
              return 'http://mediconnect.somee.com${s.startsWith('/') ? '' : '/'}$s';
            }

            final doctorImageUrl = resolveImageUrl(
              appt['doctorImageUrl'] ??
                  appt['DoctorImageUrl'] ??
                  appt['doctor']?['imageUrl'] ??
                  appt['doctor']?['ImageUrl'] ??
                  appt['doctor']?['profileImageUrl'] ??
                  appt['doctor']?['ProfileImageUrl'] ??
                  appt['doctor']?['displayImageUrl'] ??
                  appt['doctor']?['DisplayImageUrl'] ??
                  appt['doctor']?['image'] ??
                  appt['doctor']?['photo'] ??
                  appt['doctor']?['photoUrl'] ??
                  // Also check inside schedule.doctor
                  appt['schedule']?['doctor']?['imageUrl'] ??
                  appt['schedule']?['doctor']?['profileImageUrl'] ??
                  appt['schedule']?['doctor']?['displayImageUrl'],
            );
            final rawDocId =
                appt['doctorId'] ??
                appt['DoctorId'] ??
                appt['doctor']?['id'] ??
                appt['doctor']?['Id'] ??
                appt['schedule']?['doctorId'] ??
                appt['schedule']?['doctor']?['id'];
            final doctorId = rawDocId is int
                ? rawDocId
                : int.tryParse(rawDocId?.toString() ?? '') ?? 0;

            final doctor = DoctorModel(
              id: doctorId,
              fullName: doctorName.toString(),
              imageUrl: doctorImageUrl,
            );
            // Format date nicely if possible
            String displayDate = date.toString();
            if (date.toString().isNotEmpty) {
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
            } else {
              // No date from API — derive from dayOfWeek in timeSlot (e.g. "Sunday 09:00 - 09:30")
              final timeSlotStr = timeSlot.toString().trim();
              final dayNames = {
                'monday': DateTime.monday,
                'tuesday': DateTime.tuesday,
                'wednesday': DateTime.wednesday,
                'thursday': DateTime.thursday,
                'friday': DateTime.friday,
                'saturday': DateTime.saturday,
                'sunday': DateTime.sunday,
              };
              String? foundDay;
              for (final day in dayNames.keys) {
                if (timeSlotStr.toLowerCase().startsWith(day)) {
                  foundDay = day;
                  break;
                }
              }
              if (foundDay != null) {
                final targetWeekday = dayNames[foundDay]!;
                final now = DateTime.now();
                int diff = targetWeekday - now.weekday;
                if (diff < 0) diff += 7;
                final nextOccurrence = now.add(Duration(days: diff));
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
                    '${months[nextOccurrence.month - 1]} ${nextOccurrence.day}, ${nextOccurrence.year}';
              }
            }

            final cubit = context.read<PatientScheduleCubit>();
            final state = context.watch<PatientScheduleCubit>().state;
            final isCancelling =
                state is PatientScheduleProcessing &&
                state.processingBookingId == bookingId;

            // ── Pay Now detection ────────────────────────────────────────────
            // The API doesn't return paymentMethod, so we show Pay Now for
            // all confirmed/approved appointments and let the server validate.
            final rawStatus = (appt['status'] ?? '').toString().toLowerCase();
            final isConfirmed =
                rawStatus.contains('confirm') ||
                rawStatus.contains('accept') ||
                rawStatus.contains('approv');
            final rawPayStatus =
                (appt['paymentStatus'] ?? appt['PaymentStatus'] ?? '')
                    .toString()
                    .toLowerCase();
            final isPaid =
                rawPayStatus.contains('paid') ||
                rawPayStatus.contains('complet') ||
                rawPayStatus.contains('success') ||
                rawStatus == 'paid';
            final paymentMethodStr = (appt['paymentMethod'] ?? appt['PaymentMethod'] ?? '')
                .toString()
                .toLowerCase();
            final isOnlinePayment = paymentMethodStr.contains('online') || paymentMethodStr.contains('card') || paymentMethodStr.contains('visa');
            final isPayable = isConfirmed && !isPaid && isOnlinePayment;
            // ────────────────────────────────────────────────────────────────

            // Extract amount & names for payment screen
            // Try all possible field paths the API might use
            final consultationFee =
                appt['consultationPrice'] ??
                appt['ConsultationPrice'] ??
                appt['price'] ??
                appt['Price'] ??
                appt['fee'] ??
                appt['Fee'] ??
                appt['amount'] ??
                appt['Amount'] ??
                appt['consultationFee'] ??
                appt['ConsultationFee'] ??
                // Try nested inside 'clinic'
                appt['clinic']?['consultationPrice'] ??
                appt['clinic']?['ConsultationPrice'] ??
                appt['clinic']?['price'] ??
                appt['Clinic']?['consultationPrice'] ??
                appt['Clinic']?['price'] ??
                // Try nested inside 'schedule'
                appt['schedule']?['consultationPrice'] ??
                appt['schedule']?['price'] ??
                appt['Schedule']?['consultationPrice'] ??
                // Try nested inside 'doctor'
                appt['doctor']?['consultationPrice'] ??
                appt['doctor']?['price'] ??
                0.0;
            final amount = (consultationFee is num)
                ? consultationFee.toDouble()
                : double.tryParse(consultationFee.toString()) ?? 0.0;
            final clinicNameForPay =
                appt['clinicName']?.toString() ??
                appt['clinic']?['name']?.toString() ??
                '';

            return AppointmentCard(
              doctorName: doctorName.toString(),
              specialty: specialtyDisplay,
              dateTime: displayDate,
              timeSlot: timeSlot.toString(),
              imagePath: AvatarHelper.getDoctorAvatar(
                doctorId: doctor.id,
                imageUrl: doctor.imageUrl,
              ),
              bookingId: bookingId,
              isCancelling: isCancelling,
              isPayable: isPayable,
              // Pay Now: open payment screen
              onPayNow: isPayable
                  ? () {
                      final bookingCubit = PatientBookingCubit(
                        context.read<PatientScheduleCubit>().repository,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentCardView(
                            appointmentId: bookingId,
                            amount: amount,
                            doctorName: doctorName.toString(),
                            clinicName: clinicNameForPay,
                            doctorId: doctorId,
                            cubit: bookingCubit,
                          ),
                        ),
                      ).then((_) {
                        if (context.mounted) {
                          context
                              .read<PatientScheduleCubit>()
                              .fetchAppointments();
                        }
                      });
                    }
                  : null,
              // Cancel: call cubit → API → refresh list
              onCancel: bookingId > 0
                  ? () => cubit.cancelBooking(bookingId)
                  : null,
              onEdit: bookingId > 0
                  ? () {
                      final controller = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('Edit Appointment'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              labelText: 'New Reason for Visit',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                cubit.editAppointment(bookingId, {
                                  'reasonForVisit': controller.text,
                                });
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                    }
                  : null,
              // Reschedule: go to booking screen to pick new time
              onReschedule: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PatientBookingView()),
                );
              },
              // Details: navigate directly with bookingId
              onDetails: () {
                if (bookingId > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientAppointmentDetailsView(
                        bookingId: bookingId,
                        initialData: Map<String, dynamic>.from(appt),
                      ),
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
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ColorManager.headlineText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book a clinic appointment to get started.',
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
        style: GoogleFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: ColorManager.primary,
        ),
      ),
    );
  }
}
