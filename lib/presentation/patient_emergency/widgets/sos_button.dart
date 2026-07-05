import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/core/resources/color_manager.dart';

import '../cubit/patient_emergency_cubit.dart';
import '../cubit/patient_emergency_state.dart';

class SOSButton extends StatelessWidget {
  const SOSButton({super.key, required this.s});

  final double Function(double) s;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientEmergencyCubit, PatientEmergencyState>(
      builder: (context, state) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                context.read<PatientEmergencyCubit>().callEmergencyService();
              },
              child: Container(
                width: s(150),
                height: s(150),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SOS',
                    style: GoogleFonts.cairo(
                      fontSize: s(42),
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: s(16)),
            Text(
              'Press for Emergency',
              style: GoogleFonts.cairo(
                fontSize: s(16),
                fontWeight: FontWeight.w600,
                color: ColorManager.subtitleText,
              ),
            ),
            SizedBox(height: s(8)),
            Text(
              'An ambulance will be dispatched to your current location immediately.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: s(13),
                fontWeight: FontWeight.w400,
                color: ColorManager.subtitleText,
              ),
            ),
          ],
        );
      },
    );
  }
}
