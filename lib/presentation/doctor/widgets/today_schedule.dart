import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../../../../core/resources/string_manager.dart';

class TodayScheduleList extends StatelessWidget {
  final double scale;
  final List<Map<String, dynamic>> schedule;

  const TodayScheduleList({super.key, required this.scale, required this.schedule});

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.todaySchedule,
            style: GoogleFonts.lexend(
              fontSize: s(18),
              fontWeight: FontWeight.w700,
              color: ColorManager.headlineText,
            ),
          ),
          SizedBox(height: s(16)),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedule.length,
            itemBuilder: (context, index) {
              final item = schedule[index];
              final isBreak = item['isBreak'] == true;

              return IntrinsicHeight(
                child: Row(
                  children: [
                    SizedBox(
                      width: s(65),
                      child: Text(
                        item['time'],
                        style: GoogleFonts.lexend(
                          fontSize: s(13),
                          fontWeight: FontWeight.w500,
                          color: ColorManager.subtitleText,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          width: s(12),
                          height: s(12),
                          decoration: BoxDecoration(
                            color: isBreak ? ColorManager.amberHighlight : ColorManager.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: s(2)),
                          ),
                        ),
                        if (index != schedule.length - 1)
                          Expanded(
                            child: Container(
                              width: s(2),
                              color: ColorManager.borderColor,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: s(16)),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: s(16)),
                        padding: EdgeInsets.all(s(16)),
                        decoration: BoxDecoration(
                          color: isBreak ? ColorManager.amberHighlight.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(s(16)),
                          border: Border.all(
                            color: isBreak ? ColorManager.amberHighlight.withValues(alpha: 0.3) : ColorManager.borderColor,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: GoogleFonts.lexend(
                                fontSize: s(15),
                                fontWeight: FontWeight.w600,
                                color: ColorManager.headlineText,
                              ),
                            ),
                            if (item['patient'] != null) ...[
                              SizedBox(height: s(4)),
                              Text(
                                item['patient'],
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
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
