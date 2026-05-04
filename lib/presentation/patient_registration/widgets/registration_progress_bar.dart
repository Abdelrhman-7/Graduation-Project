import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class RegistrationProgressBar extends StatelessWidget {
  final double progress;
  final String stepText;
  final String percentText;

  const RegistrationProgressBar({
    super.key,
    required this.progress,
    required this.stepText,
    required this.percentText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppPadding.p24,
        vertical: AppPadding.p16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepText,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.headlineText,
                ),
              ),
              Text(
                percentText,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSize.s8),
          Container(
            height: AppSize.s8,
            decoration: BoxDecoration(
              color: ColorManager.borderColor,
              borderRadius: BorderRadius.circular(9999),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
