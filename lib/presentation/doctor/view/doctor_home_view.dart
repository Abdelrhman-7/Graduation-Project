import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/doctor_home_cubit.dart';
import 'doctor_home_view_body.dart';

class DoctorHomeView extends StatelessWidget {
  const DoctorHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorHomeCubit()..getDoctorHomeData(),
      child: const Scaffold(body: SafeArea(child: DoctorHomeViewBody())),
    );
  }
}
