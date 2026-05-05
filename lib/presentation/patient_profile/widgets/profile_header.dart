import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';

class ProfileHeader extends StatelessWidget {
  final double scale;
  final String name;
  final String patientId;

  const ProfileHeader({
    super.key,
    required this.scale,
    required this.name,
    required this.patientId,
  });

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(16)),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: s(80),
                height: s(80),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ColorManager.primary, width: s(2)),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://www.figma.com/api/mcp/asset/102b10e8-65fa-4246-94fe-4533eb611db6',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(s(4)),
                  decoration: const BoxDecoration(
                    color: ColorManager.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: s(14),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: s(20)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lexend(
                    fontSize: s(24),
                    fontWeight: FontWeight.w700,
                    color: ColorManager.headlineText,
                  ),
                ),
                SizedBox(height: s(4)),
                Text(
                  '${AppStrings.patientId} $patientId',
                  style: GoogleFonts.lexend(
                    fontSize: s(14),
                    fontWeight: FontWeight.w500,
                    color: ColorManager.subtitleText,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(s(10)),
            decoration: BoxDecoration(
              color: ColorManager.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(s(12)),
            ),
            child: Icon(
              Icons.edit_outlined,
              color: ColorManager.primary,
              size: s(22),
            ),
          ),
        ],
      ),
    );
  }
}
