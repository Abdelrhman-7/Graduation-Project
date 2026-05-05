import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/string_manager.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class PastVisitItem extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;

  const PastVisitItem({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.date,
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
            ),
            child: const Icon(
              Icons.history_rounded,
              color: ColorManager.primary,
            ),
          ),
          const SizedBox(width: AppSize.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  specialty, // In Figma, the main text is the checkup type
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.headlineText,
                  ),
                ),
                Text(
                  '$doctorName • $date',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: ColorManager.bodyText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: ColorManager.pendingBg,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppStrings.viewSummary,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: ColorManager.primary,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
