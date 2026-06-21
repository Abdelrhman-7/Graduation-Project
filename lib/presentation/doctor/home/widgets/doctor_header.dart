import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../core/resources/string_manager.dart';

class DoctorHomeHeader extends StatelessWidget {
  final double scale;
  final String name;
  final String specialty;
  final String? imageUrl;

  const DoctorHomeHeader({
    super.key,
    required this.scale,
    required this.name,
    required this.specialty,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Padding(
      padding: EdgeInsets.fromLTRB(s(24), s(20), s(24), s(16)),
      child: Row(
        children: [
          Container(
            width: s(54),
            height: s(54),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ColorManager.primary, width: s(2)),
              color: imageUrl == null ? ColorManager.primary.withOpacity(0.1) : null,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? Icon(
                    Icons.person,
                    color: ColorManager.primary,
                    size: s(28),
                  )
                : null,
          ),
          SizedBox(width: s(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.goodMorning,
                  style: GoogleFonts.lexend(
                    fontSize: s(14),
                    fontWeight: FontWeight.w400,
                    color: ColorManager.subtitleText,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.lexend(
                    fontSize: s(20),
                    fontWeight: FontWeight.w700,
                    color: ColorManager.headlineText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(s(10)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ColorManager.borderColor),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: ColorManager.headlineText,
              size: s(24),
            ),
          ),
        ],
      ),
    );
  }
}
