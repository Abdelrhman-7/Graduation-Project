import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/string_manager.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class PastVisitItem extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;
  final String? statusLabel;
  final String? imagePath;
  final VoidCallback? onDetails;
  final VoidCallback? onRate;

  const PastVisitItem({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.date,
    this.statusLabel,
    this.imagePath,
    this.onDetails,
    this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppPadding.p12),
      padding: const EdgeInsets.all(AppPadding.p12),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s16),
        border: Border.all(color: ColorManager.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppPadding.p8),
            decoration: BoxDecoration(
              color: ColorManager.primaryOpacity10,
              borderRadius: BorderRadius.circular(12),
              image: (imagePath != null && imagePath!.isNotEmpty)
                  ? DecorationImage(
                      image: NetworkImage(imagePath!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            width: 48,
            height: 48,
            child: (imagePath == null || imagePath!.isEmpty)
                ? const Icon(
                    Icons.history_rounded,
                    color: ColorManager.primary,
                    size: 24,
                  )
                : null,
          ),
          const SizedBox(width: AppSize.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialty, // In Figma, the main text is the checkup type
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.headlineText,
                  ),
                ),
                Text(
                  '$doctorName • $date',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: ColorManager.bodyText,
                  ),
                ),
              ],
            ),
          ),
          if (onRate != null) ...[
            IconButton(
              icon: const Icon(
                Icons.star_rate_rounded,
                color: Color(0xFFEAB308),
                size: 24,
              ),
              onPressed: onRate,
              tooltip: 'Rate Doctor',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: AppSize.s8),
          ],
          if (onDetails != null) ...[
            IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: ColorManager.primary,
                size: 20,
              ),
              onPressed: onDetails,
              tooltip: 'Details',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: AppSize.s8),
          ],
          Container(
            decoration: BoxDecoration(
              color: _getBadgeBgColor(),
              borderRadius: BorderRadius.circular(9999),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Text(
              statusLabel ?? AppStrings.viewSummary,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _getBadgeTextColor(),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBadgeBgColor() {
    if (statusLabel == null) return ColorManager.pendingBg;
    final status = statusLabel!.toLowerCase();
    if (status.contains('cancel') ||
        status.contains('reject') ||
        status.contains('denied')) {
      return ColorManager.cancelRedBg;
    }
    return ColorManager.pendingBg;
  }

  Color _getBadgeTextColor() {
    if (statusLabel == null) return ColorManager.primary;
    final status = statusLabel!.toLowerCase();
    if (status.contains('cancel') ||
        status.contains('reject') ||
        status.contains('denied')) {
      return ColorManager.cancelRedText;
    }
    return ColorManager.primary;
  }
}
