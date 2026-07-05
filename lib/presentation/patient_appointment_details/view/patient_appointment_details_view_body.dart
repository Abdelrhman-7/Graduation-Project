import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/resources/color_manager.dart';
import '../cubit/patient_appointment_details_cubit.dart';
import '../cubit/patient_appointment_details_state.dart';
import '../widgets/appointment_info_card.dart';
import '../widgets/doctor_info_card.dart';

class PatientAppointmentDetailsViewBody extends StatelessWidget {
  const PatientAppointmentDetailsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Appointment Details',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w700,
            color: ColorManager.headlineText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorManager.primary),
      ),
      body: BlocBuilder<PatientAppointmentDetailsCubit, PatientAppointmentDetailsState>(
        builder: (context, state) {
          if (state is PatientAppointmentDetailsLoading || state is PatientAppointmentDetailsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: ColorManager.primary),
            );
          } else if (state is PatientAppointmentDetailsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            );
          } else if (state is PatientAppointmentDetailsLoaded) {
            final details = state.details;
            final reason = details['reasonForVisit'] ?? details['symptoms'] ?? details['reason'] ?? 'Not specified';
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DoctorInfoCard(details: details),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Booking Information',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.headlineText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppointmentInfoCard(details: details),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Reason for Visit',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ColorManager.headlineText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0D000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      reason,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: ColorManager.bodyText,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
