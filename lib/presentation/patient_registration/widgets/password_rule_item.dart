import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class PasswordRuleItem extends StatelessWidget {
  final String text;
  final bool isMet;

  const PasswordRuleItem({
    super.key,
    required this.text,
    this.isMet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.p8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: AppSize.s16,
            color: isMet ? ColorManager.primary : ColorManager.subtitleText,
          ),
          const SizedBox(width: AppSize.s8),
          Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 14,
              color: isMet ? ColorManager.bodyText : ColorManager.subtitleText,
            ),
          ),
        ],
      ),
    );
  }
}
