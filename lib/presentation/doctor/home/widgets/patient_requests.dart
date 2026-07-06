import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../core/resources/string_manager.dart';

class PatientRequestsList extends StatelessWidget {
  final double scale;
  final List<Map<String, dynamic>> requests;
  final int? processingBookingId;
  final String? processingAction;
  final Future<void> Function(int bookingId)? onApprove;
  final Future<void> Function(int bookingId)? onDeny;
  final Future<void> Function(int bookingId)? onComplete;

  const PatientRequestsList({
    super.key,
    required this.scale,
    required this.requests,
    this.processingBookingId,
    this.processingAction,
    this.onApprove,
    this.onDeny,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    if (requests.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(12)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(s(20)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(s(16)),
            border: Border.all(color: ColorManager.borderColor),
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: s(40),
                color: ColorManager.subtitleText.withOpacity(0.5),
              ),
              SizedBox(height: s(8)),
              Text(
                'No pending booking requests',
                style: GoogleFonts.cairo(
                  fontSize: s(14),
                  color: ColorManager.subtitleText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient Bookings (${requests.length})',
                style: GoogleFonts.cairo(
                  fontSize: s(18),
                  fontWeight: FontWeight.w700,
                  color: ColorManager.headlineText,
                ),
              ),
              Text(
                'View All (${requests.length})',
                style: GoogleFonts.cairo(
                  fontSize: s(14),
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: s(195),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: s(18)),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final bookingId = request['id'] as int? ?? 0;
              final patientName =
                  request['patientName']?.toString() ?? 'Patient';
              final initial = patientName.isNotEmpty ? patientName[0] : '?';
              final isPending = request['isPending'] == true;
              final status = request['status']?.toString() ?? 'Pending';

              return Container(
                width: s(280),
                margin: EdgeInsets.symmetric(horizontal: s(6), vertical: s(8)),
                padding: EdgeInsets.all(s(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(s(20)),
                  border: Border.all(color: ColorManager.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: s(18),
                          backgroundColor: ColorManager.primary.withValues(
                            alpha: 0.1,
                          ),
                          backgroundImage: (request['patientImageUrl'] != null && request['patientImageUrl'].toString().isNotEmpty)
                              ? NetworkImage(request['patientImageUrl'].toString())
                              : null,
                          child: (request['patientImageUrl'] == null || request['patientImageUrl'].toString().isEmpty)
                              ? Text(
                                  initial,
                                  style: TextStyle(
                                    color: ColorManager.primary,
                                    fontSize: s(14),
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: s(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                patientName,
                                style: GoogleFonts.cairo(
                                  fontSize: s(15),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                request['time']?.toString() ?? '',
                                style: GoogleFonts.cairo(
                                  fontSize: s(12),
                                  color: ColorManager.subtitleText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s(10)),
                    if (request['clinicName'] != null)
                      Text(
                        request['clinicName'].toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          fontSize: s(13),
                          fontWeight: FontWeight.w600,
                          color: ColorManager.primary,
                        ),
                      ),
                    Text(
                      request['details']?.toString() ?? request['type']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontSize: s(13),
                        color: ColorManager.headlineText,
                      ),
                    ),
                    if (!isPending) ...[
                      SizedBox(height: s(6)),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: s(8),
                              vertical: s(4),
                            ),
                            decoration: BoxDecoration(
                              color: status.toLowerCase().contains('approved')
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(s(8)),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.cairo(
                                fontSize: s(11),
                                fontWeight: FontWeight.w600,
                                color: status.toLowerCase().contains('approved')
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                          if (status.toLowerCase().contains('approved') && onComplete != null) ...[
                            const Spacer(),
                            ElevatedButton(
                              onPressed: processingBookingId != null ? null : () => onComplete!(bookingId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ColorManager.primary,
                                padding: EdgeInsets.symmetric(horizontal: s(12), vertical: 0),
                                minimumSize: Size(0, s(28)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(s(8)),
                                ),
                              ),
                              child: processingBookingId == bookingId
                                  ? SizedBox(
                                      width: s(12),
                                      height: s(12),
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      'Complete',
                                      style: TextStyle(fontSize: s(11), color: Colors.white),
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (isPending) const Spacer(),
                    if (isPending)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: processingBookingId != null || onDeny == null
                                ? null
                                : () => onDeny!(bookingId),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(s(10)),
                              ),
                              side: const BorderSide(
                                color: ColorManager.borderColor,
                              ),
                            ),
                            child: processingBookingId == bookingId && processingAction == 'deny'
                                ? SizedBox(
                                    width: s(20),
                                    height: s(20),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          ColorManager.primary),
                                    ),
                                  )
                                : Text(
                                    AppStrings.deny,
                                    style: TextStyle(
                                      fontSize: s(13),
                                      color: ColorManager.subtitleText,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: s(8)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: processingBookingId != null || onApprove == null
                                ? null
                                : () => onApprove!(bookingId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.primary,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(s(10)),
                              ),
                              elevation: 0,
                            ),
                            child: processingBookingId == bookingId && processingAction == 'approve'
                                ? SizedBox(
                                    width: s(24),
                                    height: s(24),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          ColorManager.primary),
                                    ),
                                  )
                                : Text(
                                    AppStrings.approve,
                                    style: TextStyle(
                                      fontSize: s(13),
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
