import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../resources/color_manager.dart';
import '../resources/values_manager.dart';

class CustomTextField extends StatelessWidget {
  final String? label;
  final String hintText;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  final int maxLines;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.label,
    required this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppPadding.p8,
              bottom: AppPadding.p8,
            ),
            child: Text(
              label!,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ColorManager.headlineText,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(AppSize.s12),
            border: Border.all(color: ColorManager.borderColor),
            boxShadow: [
              BoxShadow(
                color: ColorManager.blackOpacity05,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.notoSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: ColorManager.subtitleText,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppPadding.p16,
                vertical: AppPadding.p16,
              ),
              prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: ColorManager.primary) : null,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }
}
