import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/core/resources/color_manager.dart';
import 'package:graduationproject/core/resources/values_manager.dart';
import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/presentation/doctor/register%20screen/cubit/registergoctor_cubit.dart';
import 'package:graduationproject/presentation/doctor/register%20screen/widget/doctor_register_form.dart';

class DoctorRegisterView extends StatelessWidget {
  const DoctorRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterDoctorCubit(context.read<ApiManager>()),
      child: Scaffold(
        backgroundColor: ColorManager.white,
        appBar: AppBar(
          backgroundColor: ColorManager.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: ColorManager.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Provider Registration",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ColorManager.headlineText,
              fontWeight: FontWeight.bold,
              fontSize: AppSize.s20,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Join as a Provider",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: ColorManager.headlineText,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSize.s28,
                    ),
                  ),
                  const SizedBox(height: AppSize.s8),
                  Text(
                    "Please provide your professional details for\nverification.",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ColorManager.subtitleText,
                      fontSize: AppSize.s16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSize.s32),
                  const DoctorRegisterForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
