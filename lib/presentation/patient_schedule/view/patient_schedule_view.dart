import 'package:flutter/material.dart';
import 'patient_schedule_view_body.dart';

class PatientScheduleView extends StatelessWidget {
  const PatientScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF6F7F8),
      body: SafeArea(
        child: PatientScheduleViewBody(),
      ),
    );
  }
}
