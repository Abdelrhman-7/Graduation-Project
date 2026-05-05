import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/presentation/patient_home_dashboard/view/patient_home_dashboard_view_body.dart';
import 'package:graduationproject/presentation/patient_home_dashboard/cubit/patient_home_dashboard_cubit.dart';

class PatientHomeDashboardView extends StatelessWidget {
  const PatientHomeDashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientHomeDashboardCubit()..getDashboardData(),
      child: const Scaffold(
        body: SafeArea(child: PatientHomeDashboardViewBody()),
      ),
    );
  }
}
