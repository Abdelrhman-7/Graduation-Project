import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/resources/assets_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../../../core/resources/values_manager.dart';
import '../../../../core/resources/theme_manager.dart';

class DetailedResultItem extends StatelessWidget {
  const DetailedResultItem({
    super.key,
    required this.scale,
    required this.title,
    required this.value,
    required this.unit,
    required this.refRange,
    required this.icon,
    required this.iconBg,
    this.valueColor,
    this.showButton = false,
    this.isLast = false,
  });

  final double scale;
  final String title;
  final String value;
  final String unit;
  final String refRange;
  final String icon;
  final Color iconBg;
  final Color? valueColor;
  final bool showButton;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;
    return Container(
      padding: EdgeInsets.all(s(AppPadding.p20)),
      decoration: BoxDecoration(
        color: showButton ? ColorManager.electricViolet.withValues(alpha: 0.02) : null,
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: ColorManager.athensGray),
              ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: ThemeManager.getLabHeading4Style().copyWith(fontSize: s(14)),
                    ),
                    SizedBox(height: s(AppSize.s8)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          value,
                          style: ThemeManager.getLabHeading1Style().copyWith(
                            fontSize: s(24),
                            color: valueColor ?? ColorManager.ebony,
                          ),
                        ),
                        SizedBox(width: s(AppSize.s4)),
                        Text(
                          unit,
                          style: ThemeManager.getLabDateStyle().copyWith(fontSize: s(14)),
                        ),
                      ],
                    ),
                    SizedBox(height: s(AppSize.s4)),
                    Text(
                      refRange,
                      style: ThemeManager.getLabBadgeStyle(ColorManager.grayChateau).copyWith(fontSize: s(10)),
                    ),
                  ],
                ),
              ),
              Container(
                width: s(48),
                height: s(48),
                padding: EdgeInsets.all(s(AppPadding.p12)),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset(
                  icon,
                  width: s(24),
                  height: s(24),
                ),
              ),
            ],
          ),
          if (showButton) ...[
            SizedBox(height: s(AppSize.s16)),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.electricViolet,
                minimumSize: Size(double.infinity, s(48)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(AppSize.s16)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    ImageAssets.consult,
                    width: s(20),
                    height: s(20),
                    colorFilter: const ColorFilter.mode(
                      ColorManager.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: s(AppSize.s8)),
                  Text(
                    AppStrings.consultDoctor,
                    style: ThemeManager.getLabHeading4Style().copyWith(
                      fontSize: s(16),
                      color: ColorManager.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
