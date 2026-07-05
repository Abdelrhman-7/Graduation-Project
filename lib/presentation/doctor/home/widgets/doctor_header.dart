import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../core/resources/string_manager.dart';

class DoctorHomeHeader extends StatelessWidget {
  final double scale;
  final String name;
  final String specialty;
  final String? imageUrl;
  final int pendingNotifications;
  final VoidCallback? onNotificationsTap;

  const DoctorHomeHeader({
    super.key,
    required this.scale,
    required this.name,
    required this.specialty,
    this.imageUrl,
    this.pendingNotifications = 0,
    this.onNotificationsTap,
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
              color: imageUrl == null
                  ? ColorManager.primary.withOpacity(0.1)
                  : null,
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
                  style: GoogleFonts.cairo(
                    fontSize: s(14),
                    fontWeight: FontWeight.w400,
                    color: ColorManager.subtitleText,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.cairo(
                    fontSize: s(20),
                    fontWeight: FontWeight.w700,
                    color: ColorManager.headlineText,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onNotificationsTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.all(s(10)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColorManager.borderColor),
                  ),
                  child: Icon(
                    pendingNotifications > 0
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: pendingNotifications > 0
                        ? ColorManager.primary
                        : ColorManager.headlineText,
                    size: s(24),
                  ),
                ),
                if (pendingNotifications > 0)
                  Positioned(
                    right: s(4),
                    top: s(2),
                    child: Container(
                      padding: EdgeInsets.all(s(4)),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: s(18),
                        minHeight: s(18),
                      ),
                      child: Text(
                        pendingNotifications > 9
                            ? '9+'
                            : '$pendingNotifications',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: s(10),
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
