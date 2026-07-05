import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/patient_emergency_cubit.dart';
import '../cubit/patient_emergency_state.dart';
import '../widgets/emergency_header.dart';
import '../widgets/sos_button.dart';
import '../widgets/emergency_contacts.dart';

class PatientEmergencyViewBody extends StatelessWidget {
  const PatientEmergencyViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / 390).clamp(0.88, 1.15);
        double s(double v) => v * scale;

        return BlocConsumer<PatientEmergencyCubit, PatientEmergencyState>(
          listener: (context, state) {
            if (state is PatientEmergencySuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency services have been contacted.'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is PatientEmergencyError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  children: [
                    EmergencyHeader(s: s),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: s(24)),
                        child: Column(
                          children: [
                            SizedBox(height: s(32)),
                            SOSButton(s: s),
                            SizedBox(height: s(40)),
                            EmergencyContacts(s: s),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (state is PatientEmergencyLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
