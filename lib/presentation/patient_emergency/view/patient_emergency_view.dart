import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/presentation/patient_emergency/cubit/patient_emergency_cubit.dart';
import 'patient_emergency_view_body.dart';

class PatientEmergencyView extends StatelessWidget {
  const PatientEmergencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientEmergencyCubit(context.read<Repository>()),
      child: const Scaffold(body: SafeArea(child: PatientEmergencyViewBody())),
    );
  }
}
