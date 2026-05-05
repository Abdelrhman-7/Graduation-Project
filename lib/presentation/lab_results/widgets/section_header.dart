import 'package:flutter/material.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../../../core/resources/values_manager.dart';
import '../../../../core/resources/theme_manager.dart';

class LabSectionHeader extends StatelessWidget {
  const LabSectionHeader({
    super.key,
    required this.scale,
    required this.title,
    this.onSeeAll,
  });
  final double scale;
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        s(AppPadding.p24),
        s(AppPadding.p12),
        s(AppPadding.p24),
        s(AppPadding.p16),
      ),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: ThemeManager.getLabHeading3Style().copyWith(fontSize: s(18)),
            ),
            if (onSeeAll != null)
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  AppStrings.seeAll,
                  style: ThemeManager.getLabBadgeStyle(ColorManager.electricViolet)
                      .copyWith(fontSize: s(14)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
