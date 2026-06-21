import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import '../cubit/patient_booking_cubit.dart';
import 'doctor_list_view.dart';

class PatientBookingView extends StatelessWidget {
  const PatientBookingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PatientBookingCubit(context.read<Repository>())..fetchDoctors(),
      child: const Scaffold(
        backgroundColor: Color(0xFFFEF2F2),
        body: SafeArea(child: DoctorListView()),
      ),
    );
  }
}
