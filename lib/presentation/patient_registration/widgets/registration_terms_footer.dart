import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/string_manager.dart';
import '../../../core/resources/values_manager.dart';

class RegistrationTermsFooter extends StatelessWidget {
  final VoidCallback? onCompleteRegistration;

  const RegistrationTermsFooter({
    super.key,
    required this.onCompleteRegistration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p24),
      decoration: BoxDecoration(
        color: ColorManager.background,
        border: const Border(
          top: BorderSide(color: ColorManager.borderColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: AppSize.s56,
            child: ElevatedButton(
              onPressed: onCompleteRegistration,
              child: const Text(AppStrings.completeRegistration),
            ),
          ),
          const SizedBox(height: AppSize.s16),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.lexend(
                fontSize: 14,
                color: ColorManager.subtitleText,
              ),
              children: [
                const TextSpan(text: AppStrings.termsAgreeText),
                TextSpan(
                  text: AppStrings.termsOfService,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: ColorManager.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    // Navigate to Terms
                  },
                ),
                const TextSpan(text: AppStrings.andText),
                TextSpan(
                  text: AppStrings.privacyPolicy,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: ColorManager.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    // Navigate to Privacy Policy
                  },
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
