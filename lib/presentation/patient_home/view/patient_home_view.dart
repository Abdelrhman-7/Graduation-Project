/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/api/api_manager.dart';
import '../cubit/patient_home_cubit.dart';
import '../widgets/patient_home_view_body.dart';
import '../widgets/patient_bottom_nav_bar.dart';

class PatientHomeView extends StatelessWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientHomeCubit(context.read<ApiManager>())..getHomeData(),
      child: const Scaffold(
        body: PatientHomeViewBody(),
        bottomNavigationBar: PatientBottomNavBar(),
      ),
    );
  }
}
*/