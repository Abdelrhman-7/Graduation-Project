import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/data/repository/scheduleRepository/clinic_repository.dart';
import 'package:graduationproject/data/repository/shared_pref_controller.dart';
import '../cubit/creat_schedule_cubit.dart';
import '../widgets/manage_schedule_screen.dart';

class CreateScheduleView extends StatelessWidget {
  const CreateScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CreateScheduleCubit(
        clinicRepository: ClinicRepository(ctx.read<ApiManager>()),
        sharedPrefController: SharedPrefController(),
      )..loadAllSchedules(),
      child: const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: SafeArea(
          child: ManageScheduleScreen(),
        ),
      ),
    );
  }
}
