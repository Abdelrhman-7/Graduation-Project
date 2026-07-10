import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduationproject/data/repository/repository.dart';
import 'patient_schedule_state.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
export 'patient_schedule_state.dart';

class PatientScheduleCubit extends Cubit<PatientScheduleState> {
  final Repository repository;

  PatientScheduleCubit(this.repository) : super(PatientScheduleInitial());

  Future<void> fetchAppointments() async {
    emit(PatientScheduleLoading());
    try {
      final appointments = await repository.getPatientAppointments();
      
      // Inject doctor images into appointments
      try {
        final doctors = await repository.getPatientDoctors();
        
        // Also fetch clinics to match by clinic name (since appt doesn't return doctorId)
        List<ClinicModel> clinics = [];
        try {
          clinics = await repository.getPatientAllClinics();
        } catch (_) {}
        
        for (var appt in appointments) {
          if (appt is Map) {
            final docIdStr = appt['doctorId'] ?? appt['doctor']?['id'];
            final docId = docIdStr != null ? (docIdStr is int ? docIdStr : int.tryParse(docIdStr.toString()) ?? 0) : 0;
            
            DoctorModel? matchedDoc;
            
            // Step 1: Match by doctorId
            if (docId != 0) {
              try {
                matchedDoc = doctors.firstWhere((d) => d.id == docId);
              } catch (_) {}
            }

            // Step 2: Match by clinic name -> get doctor name from clinic
            if (matchedDoc == null) {
              final apptClinicName = (appt['clinicName'] ?? '').toString().toLowerCase().trim();
              if (apptClinicName.isNotEmpty && clinics.isNotEmpty) {
                try {
                  final matchedClinic = clinics.firstWhere(
                    (c) => c.name.toLowerCase().trim() == apptClinicName,
                  );
                  // Inject doctorName and image directly from the clinic
                  final clinicDocName = matchedClinic.doctorName ?? '';
                  if (clinicDocName.isNotEmpty && clinicDocName != 'Doctor') {
                    appt['realDoctorName'] = clinicDocName;
                  }
                  if (matchedClinic.doctorImageUrl != null && matchedClinic.doctorImageUrl!.isNotEmpty) {
                    appt['doctorImageUrl'] = matchedClinic.doctorImageUrl;
                  }
                  print('  Matched by clinic: docName="$clinicDocName"');
                  continue; // Skip the DoctorModel matching below
                } catch (_) {}
              }
            }

            // Step 3: Match by department name or description
            if (matchedDoc == null) {
              final apptClinic = (appt['clinicName'] ?? appt['specialty'] ?? '').toString().toLowerCase().trim();
              if (apptClinic.isNotEmpty) {
                try {
                  matchedDoc = doctors.firstWhere((d) {
                    final dDept = (d.departmentName ?? '').toLowerCase().trim();
                    final dDesc = (d.departmentDescription ?? '').toLowerCase().trim();
                    return (dDept.isNotEmpty && dDept == apptClinic) || (dDesc.isNotEmpty && dDesc == apptClinic);
                  });
                } catch (_) {}
              }
            }

            if (matchedDoc != null) {
              if (matchedDoc.imageUrl != null && matchedDoc.imageUrl!.isNotEmpty) {
                appt['doctorImageUrl'] = matchedDoc.imageUrl;
              }
              if (matchedDoc.fullName.isNotEmpty && matchedDoc.fullName != 'Doctor') {
                appt['realDoctorName'] = matchedDoc.fullName;
              }
            }
          }
        }
      } catch (e) {
        // Silently ignore or properly log if preferred
      }
      
      if (isClosed) return;
      emit(PatientScheduleSuccess(appointments));
    } catch (e) {
      if (isClosed) return;
      emit(PatientScheduleError(e.toString()));
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    final currentState = state;
    if (currentState is! PatientScheduleSuccess) return;

    emit(PatientScheduleProcessing(currentState.appointments, bookingId));
    try {
      await repository.cancelPatientBooking(bookingId);
      final updated = await repository.getPatientAppointments();
      try {
        final doctors = await repository.getPatientDoctors();
        for (var appt in updated) {
          if (appt is Map) {
            final docIdStr = appt['doctorId'] ?? appt['doctor']?['id'];
            final docId = docIdStr != null ? (docIdStr is int ? docIdStr : int.tryParse(docIdStr.toString()) ?? 0) : 0;
            if (docId != 0) {
              try {
                final doc = doctors.firstWhere((d) => d.id == docId);
                if (doc.imageUrl != null && doc.imageUrl!.isNotEmpty) {
                  appt['doctorImageUrl'] = doc.imageUrl;
                }
                if (doc.fullName.isNotEmpty && doc.fullName != 'Doctor') {
                  appt['realDoctorName'] = doc.fullName;
                }
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
      
      if (isClosed) return;
      emit(PatientScheduleSuccess(updated));
    } catch (e) {
      if (isClosed) return;
      emit(PatientScheduleSuccess(currentState.appointments));
      emit(PatientScheduleProcessError(e.toString(), currentState.appointments));
    }
  }

  Future<void> editAppointment(int bookingId, Map<String, dynamic> data) async {
    final currentState = state;
    if (currentState is! PatientScheduleSuccess) return;

    emit(PatientScheduleProcessing(currentState.appointments, bookingId));
    try {
      await repository.editPatientAppointment(bookingId, data);
      final updated = await repository.getPatientAppointments();
      try {
        final doctors = await repository.getPatientDoctors();
        for (var appt in updated) {
          if (appt is Map) {
            final docIdStr = appt['doctorId'] ?? appt['doctor']?['id'];
            final docId = docIdStr != null ? (docIdStr is int ? docIdStr : int.tryParse(docIdStr.toString()) ?? 0) : 0;
            if (docId != 0) {
              try {
                final doc = doctors.firstWhere((d) => d.id == docId);
                if (doc.imageUrl != null && doc.imageUrl!.isNotEmpty) {
                  appt['doctorImageUrl'] = doc.imageUrl;
                }
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
      emit(PatientScheduleSuccess(updated));
    } catch (e) {
      emit(PatientScheduleSuccess(currentState.appointments));
      emit(PatientScheduleProcessError(e.toString(), currentState.appointments));
    }
  }

  Future<void> deleteAppointmentImage(int bookingId, int imageId) async {
    final currentState = state;
    if (currentState is! PatientScheduleSuccess) return;

    emit(PatientScheduleProcessing(currentState.appointments, bookingId));
    try {
      await repository.apiManager.deleteAppointmentPatientImage(imageId);
      final updated = await repository.getPatientAppointments();
      try {
        final doctors = await repository.getPatientDoctors();
        for (var appt in updated) {
          if (appt is Map) {
            final docIdStr = appt['doctorId'] ?? appt['doctor']?['id'];
            final docId = docIdStr != null ? (docIdStr is int ? docIdStr : int.tryParse(docIdStr.toString()) ?? 0) : 0;
            if (docId != 0) {
              try {
                final doc = doctors.firstWhere((d) => d.id == docId);
                if (doc.imageUrl != null && doc.imageUrl!.isNotEmpty) {
                  appt['doctorImageUrl'] = doc.imageUrl;
                }
              } catch (_) {}
            }
          }
        }
      } catch (_) {}
      emit(PatientScheduleSuccess(updated));
    } catch (e) {
      emit(PatientScheduleSuccess(currentState.appointments));
      emit(PatientScheduleProcessError(e.toString(), currentState.appointments));
    }
  }
}
