import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/resources/assets_manager.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';
import '../../../../core/resources/theme_manager.dart';

class LabResultsTopBar extends StatelessWidget {
  const LabResultsTopBar({super.key, required this.scale});
  final double scale;

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;
    return Container(
      padding: EdgeInsets.fromLTRB(s(8), s(8), s(16), s(8)),
      decoration: const BoxDecoration(
        color: ColorManager.whiteLilac,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: SvgPicture.asset(
              ImageAssets.goBack,
              width: s(24),
              height: s(24),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            AppStrings.labResults,
            style: ThemeManager.getLabHeading3Style().copyWith(fontSize: s(18)),
          ),
          IconButton(
            icon: SvgPicture.asset(
              ImageAssets.more,
              width: s(24),
              height: s(24),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
