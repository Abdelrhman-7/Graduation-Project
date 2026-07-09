import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/patient_reviews_cubit.dart';
import '../cubit/patient_reviews_state.dart';
import '../../patient_booking/view/doctor_profile_view.dart';
import '../../patient_booking/cubit/patient_booking_cubit.dart';
import '../../../../data/repository/repository.dart';
import '../../../../core/resources/color_manager.dart';
class PatientReviewsView extends StatelessWidget {
  const PatientReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PatientReviewsCubit()..loadDoctors(),
      child: const _PatientReviewsViewBody(),
    );
  }
}

class _PatientReviewsViewBody extends StatelessWidget {
  const _PatientReviewsViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Doctors',
          style: GoogleFonts.cairo(
            color: const Color(0xFF0F172A),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<PatientReviewsCubit, PatientReviewsState>(
        builder: (context, state) {
          if (state is PatientReviewsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PatientReviewsError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.cairo(color: Colors.red),
              ),
            );
          } else if (state is PatientReviewsSuccess) {
            final doctors = state.doctors;
            if (doctors.isEmpty) {
              return Center(
                child: Text(
                  'No rated doctors found.',
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF64748B),
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) =>
                              PatientBookingCubit(context.read<Repository>()),
                          child: Builder(
                            builder: (context) => DoctorProfileView(
                              doctorId: doctor.id,
                              cubit: context.read<PatientBookingCubit>(),
                              scale: 1.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFEFF6FF),
                          backgroundImage:
                              (doctor.imageUrl != null &&
                                  doctor.imageUrl!.isNotEmpty)
                              ? NetworkImage(doctor.imageUrl!) as ImageProvider
                              : null,
                          child:
                              (doctor.imageUrl == null ||
                                  doctor.imageUrl!.isEmpty)
                              ? Icon(
                                  Icons.person,
                                  color: ColorManager.primary,
                                  size: 28,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.fullName,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor.departmentName ?? 'Specialty',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                              if (doctor.rating != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Color(0xFFEAB308),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      doctor.rating.toString(),
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (doctor.aboutMe != null && doctor.aboutMe!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '"${doctor.aboutMe}"',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFF475569),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

}

