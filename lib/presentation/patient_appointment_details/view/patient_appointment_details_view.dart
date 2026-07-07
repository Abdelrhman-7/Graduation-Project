import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repository/repository.dart';
import '../cubit/patient_appointment_details_cubit.dart';
import 'patient_appointment_details_view_body.dart';

class PatientAppointmentDetailsView extends StatelessWidget {
  final int bookingId;
  final Map<String, dynamic>? initialData;

  const PatientAppointmentDetailsView({
    super.key,
    required this.bookingId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PatientAppointmentDetailsCubit(repository: context.read<Repository>())
            ..getDetails(bookingId, initialData: initialData),
      child: const PatientAppointmentDetailsViewBody(),
    );
  }
}
