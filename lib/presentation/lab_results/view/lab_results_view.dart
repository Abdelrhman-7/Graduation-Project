import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'package:graduationproject/presentation/lab_results/view/lab_results_view_body.dart';
import 'package:graduationproject/presentation/lab_results/cubit/lab_results_cubit.dart';

class LabResultsView extends StatelessWidget {
  const LabResultsView({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LabResultsCubit(context.read<Repository>()),
      child: const Scaffold(body: SafeArea(child: LabResultsViewBody())),
    );
  }
}
