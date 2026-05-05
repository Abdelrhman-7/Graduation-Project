import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';

class ProfileMenuItem extends StatelessWidget {
  final double scale;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    super.key,
    required this.scale,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(16)),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(s(10)),
              decoration: BoxDecoration(
                color: (iconColor ?? ColorManager.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(s(12)),
              ),
              child: Icon(
                icon,
                color: iconColor ?? ColorManager.primary,
                size: s(22),
              ),
            ),
            SizedBox(width: s(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lexend(
                      fontSize: s(16),
                      fontWeight: FontWeight.w600,
                      color: ColorManager.headlineText,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: s(2)),
                    Text(
                      subtitle!,
                      style: GoogleFonts.lexend(
                        fontSize: s(13),
                        fontWeight: FontWeight.w400,
                        color: ColorManager.subtitleText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ColorManager.borderColor,
              size: s(24),
            ),
          ],
        ),
      ),
    );
  }
}
