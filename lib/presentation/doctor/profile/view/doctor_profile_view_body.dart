import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/resources/color_manager.dart';
import '../widgets/doctor_profile_header.dart';
import '../widgets/doctor_profile_credentials.dart';
import '../widgets/doctor_profile_logout_button.dart';
import '../widgets/doctor_profile_security.dart';
import '../../clinic/my_clinics/view/doctor_clinics_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/repository/repository.dart';
import '../../../../../data/repository/shared_pref_controller.dart';
import '../cubit/doctor_profile_cubit.dart';
import 'doctor_edit_profile_view.dart';
import '../../home/cubit/doctor_home_cubit.dart';

class DoctorProfileViewBody extends StatelessWidget {
  final String doctorName;
  final String? imageUrl;
  final int? age;
  final int patientsCount;

  const DoctorProfileViewBody({
    super.key,
    required this.doctorName,
    this.imageUrl,
    this.age,
    this.patientsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simulated AppBar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              Text(
                "Live Consultation",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.headlineText,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DoctorProfileHeader(
                  name: doctorName,
                  imageUrl: imageUrl,
                  age: age,
                  patientsCount: patientsCount,
                  onEditTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => DoctorProfileCubit(
                            repository: context.read<Repository>(),
                            sharedPrefController: context.read<SharedPrefController>(),
                          ),
                          child: DoctorEditProfileView(currentName: doctorName),
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        context.read<DoctorHomeCubit>().getDoctorHomeData();
                      }
                    });
                  },
                ),
                const SizedBox(height: 32),
                const DoctorProfileCredentials(),
                const SizedBox(height: 24),
                const DoctorProfileSecurity(),
                const SizedBox(height: 40),
                const DoctorProfileLogoutButton(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

