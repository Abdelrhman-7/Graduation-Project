import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/resources/assets_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../../../core/resources/values_manager.dart';
import '../../../../core/resources/theme_manager.dart';

class HemoglobinTrendCard extends StatelessWidget {
  const HemoglobinTrendCard({super.key, required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;
    return Container(
      padding: EdgeInsets.all(s(AppPadding.p24)),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(s(AppSize.s24)),
        border: Border.all(color: ColorManager.catskillWhite),
        boxShadow: [
          BoxShadow(
            color: ColorManager.black.withValues(alpha: 0.05),
            blurRadius: s(20),
            offset: Offset(0, s(10)),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.hemoglobinTrend,
                    style: ThemeManager.getLabBodyStyle().copyWith(fontSize: s(14)),
                  ),
                  SizedBox(height: s(AppSize.s4)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '14.2',
                        style: ThemeManager.getLabHeading1Style().copyWith(fontSize: s(32)),
                      ),
                      SizedBox(width: s(AppSize.s4)),
                      Text(
                        AppStrings.gDl,
                        style: ThemeManager.getLabBodyStyle().copyWith(fontSize: s(14)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: s(AppPadding.p12),
                  vertical: s(AppPadding.p4),
                ),
                decoration: BoxDecoration(
                  color: ColorManager.feta,
                  borderRadius: BorderRadius.circular(s(AppSize.s24)),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      ImageAssets.trendUp,
                      width: s(16),
                      height: s(16),
                    ),
                    SizedBox(width: s(AppSize.s4)),
                    Text(
                      '2%',
                      style: ThemeManager.getLabBadgeStyle(ColorManager.salem).copyWith(fontSize: s(14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: s(AppSize.s24)),
          SizedBox(
            height: s(120),
            width: double.infinity,
            child: SvgPicture.asset(
              ImageAssets.trendChart,
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: s(AppSize.s16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct']
                .map((month) => Text(
                      month,
                      style: ThemeManager.getLabBadgeStyle(ColorManager.grayChateau).copyWith(fontSize: s(12)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
