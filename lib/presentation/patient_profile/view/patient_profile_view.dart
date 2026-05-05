import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/repository.dart';
import '../../../data/repository/shared_pref_controller.dart';
import '../cubit/patient_profile_cubit.dart';
import 'patient_profile_view_body.dart';

class PatientProfileView extends StatelessWidget {
  const PatientProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientProfileCubit(
        repository: context.read<Repository>(),
        sharedPrefController: context.read<SharedPrefController>(),
      )..getProfileData(),
      child: const Scaffold(
        body: SafeArea(
          child: PatientProfileViewBody(),
        ),
      ),
    );
  }
}
