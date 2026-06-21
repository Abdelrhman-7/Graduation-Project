import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/repository/scheduleRepository/clinic_repository.dart';
import 'add_clinic_state.dart';

class AddClinicCubit extends Cubit<AddClinicState> {
  final ClinicRepository repository;

  AddClinicCubit(this.repository) : super(AddClinicInitial());

  Future<void> addClinic({
    required String name,
    required String address,
    required String phoneNumber,
    required String consultationPriceStr,
    required String appointmentDuration,
    required String nots,
  }) async {
    if (name.isEmpty ||
        address.isEmpty ||
        phoneNumber.isEmpty ||
        consultationPriceStr.isEmpty ||
        appointmentDuration.isEmpty ||
        nots.isEmpty) {
      emit(AddClinicError('Please fill in all fields.'));

      return;
    }

    final int? consultationPrice = int.tryParse(consultationPriceStr);
    if (consultationPrice == null) {
      emit(AddClinicError('Consultation price must be a valid number.'));
      return;
    }

    emit(AddClinicLoading());

    try {
      final clinic = ClinicModel(
        name: name,
        address: address,
        phoneNumber: phoneNumber,
        consultationPrice: consultationPrice,
        appointmentDuration: appointmentDuration,
        nots: nots,
      );

      final success = await repository.addClinic(clinic);

      if (success) {
        emit(AddClinicSuccess());
      } else {
        emit(AddClinicError('Failed to add clinic. Please try again.'));
      }
    } catch (e) {
      emit(AddClinicError('An error occurred: $e'));
    }
  }
}
