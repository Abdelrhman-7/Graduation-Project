import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../resources/color_manager.dart';
import '../resources/values_manager.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppPadding.p8,
            bottom: AppPadding.p8,
          ),
          child: Text(
            label,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p16,
            ),
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: ColorManager.subtitleText,
              ),
              hint: Text(
                hintText,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: ColorManager.subtitleText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
