import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/string_manager.dart';
import '../../../core/resources/color_manager.dart';
import '../../../core/resources/values_manager.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String dateTime;
  final String imagePath;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppPadding.p16),
      padding: const EdgeInsets.all(AppPadding.p16),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s24),
        boxShadow: [
          BoxShadow(
            color: ColorManager.blackOpacity05,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSize.s32,
                backgroundColor: ColorManager.primaryOpacity10,
                child: const Icon(
                  Icons.person,
                  color: ColorManager.primary,
                  size: AppSize.s32,
                ),
              ),
              const SizedBox(width: AppSize.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: ColorManager.headlineText,
                      ),
                    ),
                    Text(
                      specialty,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        color: ColorManager.subtitleText,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: ColorManager.primary,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: AppSize.s16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12,
              vertical: AppPadding.p12,
            ),
            decoration: BoxDecoration(
              color: ColorManager.cardInnerBg,
              borderRadius: BorderRadius.circular(AppSize.s12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s8),
                Text(
                  dateTime,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: ColorManager.headlineText,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: ColorManager.primary,
                ),
                const SizedBox(width: AppSize.s8),
                Text(
                  '10:00 AM',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ColorManager.headlineText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSize.s16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.reschedule,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSize.s12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.cancelRedBg,
                    foregroundColor: ColorManager.cancelRedText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.cancel,
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
