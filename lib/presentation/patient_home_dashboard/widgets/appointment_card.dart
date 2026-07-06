import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/string_manager.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String dateTime;
  final String imagePath;
  final String timeSlot;
  final int? bookingId;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;
  final VoidCallback? onDetails;
  final VoidCallback? onPayNow;
  final VoidCallback? onEdit;
  final VoidCallback? onDeleteImage;
  final bool isCancelling;
  /// When true, shows a green "Pay Now" button (appointment confirmed, not yet paid, pay online)
  final bool isPayable;

  final String? status;
  final bool isViewOnly;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.imagePath,
    this.timeSlot = '10:00 AM',
    this.bookingId,
    this.status,
    this.isViewOnly = false,
    this.onCancel,
    this.onReschedule,
    this.onDetails,
    this.onPayNow,
    this.onEdit,
    this.onDeleteImage,
    this.isCancelling = false,
    this.isPayable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppPadding.p16),
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s24),
        boxShadow: [
          BoxShadow(
            color: ColorManager.blackOpacity05,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSize.s32,
                backgroundColor: ColorManager.primaryOpacity10,
                backgroundImage: (imagePath.isNotEmpty) ? NetworkImage(imagePath) : null,
                child: imagePath.isEmpty
                    ? const Icon(
                        Icons.person,
                        color: ColorManager.primary,
                        size: AppSize.s32,
                      )
                    : null,
              ),
              const SizedBox(width: AppSize.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.headlineText,
                      ),
                    ),
                    Text(
                      specialty,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: ColorManager.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null && status!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status!,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(status!),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSize.s16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p12,
            ),
            decoration: BoxDecoration(
              color: ColorManager.cardInnerBg,
              borderRadius: BorderRadius.circular(AppSize.s12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s8),
                Text(
                  dateTime,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.headlineText,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s8),
                Text(
                  timeSlot,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.headlineText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s16),
          // ── Pay Now banner (only for confirmed + unpaid + online payment) ──
          if (isPayable) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPayNow,
                icon: const Icon(Icons.credit_card_rounded, size: 18),
                label: Text(
                  'Pay Now',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: AppSize.s8),
          ],
          if (onEdit != null || onDeleteImage != null) ...[
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isCancelling ? null : onEdit,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: ColorManager.primary),
                      ),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ColorManager.primary,
                        ),
                      ),
                    ),
                  ),
                if (onEdit != null && onDeleteImage != null)
                  const SizedBox(width: AppSize.s12),
                if (onDeleteImage != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isCancelling ? null : onDeleteImage,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.orange),
                      ),
                      child: Text(
                        'Delete Image',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSize.s12),
          ],
          Row(
            children: [
              if (onDetails != null) ...[
                Expanded(
                  child: isViewOnly
                      ? ElevatedButton(
                          onPressed: isCancelling ? null : onDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorManager.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          child: Text(
                            'View',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: isCancelling ? null : onDetails,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: ColorManager.primary),
                          ),
                          child: Text(
                            'Details',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ColorManager.primary,
                            ),
                          ),
                        ),
                ),
                if (!isViewOnly) const SizedBox(width: AppSize.s8),
              ],
              if (!isViewOnly) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCancelling ? null : onReschedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      AppStrings.reschedule,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.s8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCancelling ? null : () => _confirmCancel(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.cancelRedBg,
                      foregroundColor: ColorManager.cancelRedText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: isCancelling
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.red),
                            ),
                          )
                        : Text(
                            AppStrings.cancel,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Appointment',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to cancel your appointment with $doctorName?',
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Keep',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: ColorManager.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onCancel?.call();
            },
            child: Text(
              'Yes, Cancel',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}
