import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../../../../../core/resources/string_manager.dart';

class PatientRequestsList extends StatelessWidget {
  final double scale;
  final List<Map<String, dynamic>> requests;

  const PatientRequestsList({
    super.key,
    required this.scale,
    required this.requests,
  });

  @override
  Widget build(BuildContext context) {
    double s(double v) => v * scale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.patientRequests,
                style: GoogleFonts.lexend(
                  fontSize: s(18),
                  fontWeight: FontWeight.w700,
                  color: ColorManager.headlineText,
                ),
              ),
              Text(
                'View All (${requests.length})',
                style: GoogleFonts.lexend(
                  fontSize: s(14),
                  fontWeight: FontWeight.w600,
                  color: ColorManager.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: s(175),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: s(18)),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Container(
                width: s(280),
                margin: EdgeInsets.symmetric(horizontal: s(6), vertical: s(8)),
                padding: EdgeInsets.all(s(16)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(s(20)),
                  border: Border.all(color: ColorManager.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: s(18),
                          backgroundColor: ColorManager.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            request['patientName'][0],
                            style: TextStyle(
                              color: ColorManager.primary,
                              fontSize: s(14),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: s(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request['patientName'],
                                style: GoogleFonts.lexend(
                                  fontSize: s(15),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                request['time'],
                                style: GoogleFonts.lexend(
                                  fontSize: s(12),
                                  color: ColorManager.subtitleText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: s(12)),
                    Text(
                      '${request['type']}: ${request['details']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: s(14),
                        color: ColorManager.headlineText,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(s(10)),
                              ),
                              side: const BorderSide(
                                color: ColorManager.borderColor,
                              ),
                            ),
                            child: Text(
                              AppStrings.deny,
                              style: TextStyle(
                                fontSize: s(13),
                                color: ColorManager.subtitleText,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: s(8)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorManager.primary,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(s(10)),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              AppStrings.approve,
                              style: TextStyle(
                                fontSize: s(13),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
