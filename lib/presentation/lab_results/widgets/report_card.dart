import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/resources/assets_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../../../core/resources/values_manager.dart';
import '../../../../core/resources/theme_manager.dart';

class LabReportCard extends StatelessWidget {
  const LabReportCard({
    super.key,
    required this.scale,
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusBgColor,
    this.isWarning = false,
    this.isOpacity = false,
  });

  final double scale;
  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusBgColor;
  final bool isWarning;
  final bool isOpacity;

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white.withValues(alpha: isOpacity ? 0.6 : 1.0),
        borderRadius: BorderRadius.circular(s(AppSize.s24)),
        border: Border.all(
          color: isWarning ? ColorManager.tahitiGold : ColorManager.catskillWhite,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: s(10),
            offset: Offset(0, s(4)),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(s(AppPadding.p20)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ThemeManager.getLabHeading4Style().copyWith(
                          fontSize: s(16),
                          color: ColorManager.ebony.withValues(alpha: isOpacity ? 0.7 : 1.0),
                        ),
                      ),
                      SizedBox(height: s(AppSize.s4)),
                      Text(
                        date,
                        style: ThemeManager.getLabDateStyle().copyWith(
                          fontSize: s(14),
                          color: ColorManager.grayChateau.withValues(alpha: isOpacity ? 0.7 : 1.0),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s(AppPadding.p12),
                    vertical: s(AppPadding.p4),
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(s(AppSize.s6)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: ThemeManager.getLabBadgeStyle(statusColor).copyWith(fontSize: s(10)),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: s(AppPadding.p12)),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: ColorManager.athensGray),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  isWarning ? ImageAssets.viewDetails : ImageAssets.pdf,
                  width: s(20),
                  height: s(20),
                  colorFilter: const ColorFilter.mode(
                    ColorManager.electricViolet,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: s(AppSize.s8)),
                Text(
                  isWarning ? AppStrings.viewDetails : AppStrings.downloadPdf,
                  style: ThemeManager.getLabBadgeStyle(ColorManager.electricViolet)
                      .copyWith(fontSize: s(14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
