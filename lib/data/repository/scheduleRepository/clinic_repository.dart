import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/creatSchudel.dart';

class ClinicRepository {
  final ApiManager apiManager;

  ClinicRepository(this.apiManager);

  Future<bool> addClinic(ClinicModel clinic) async {
    return apiManager.addClinic(clinic);
  }

  Future<List<ClinicModel>> getDoctorClinics() async {
    return apiManager.getDoctorClinics();
  }

  Future<List<dynamic>> getClinicBookings(int clinicId) async {
    return apiManager.getClinicBookings(clinicId);
  }

  Future<bool> createSchedule(CreateScheduleModel schedule) async {
    return apiManager.createSchedule(schedule);
  }

  Future<bool> editSchedule(editClinicModel clinic) async {
    return apiManager.editSchedule(clinic);
  }

  Future<bool> deleteClinic(int id) async {
    return apiManager.deleteClinic(id);
  }

  Future<bool> updateClinic(ClinicModel clinic) async {
    return apiManager.updateClinic(clinic);
  }

  Future<bool> deleteSchedule(int scheduleId) async {
    return apiManager.deleteSchedule(scheduleId);
  }

  Future<List<dynamic>> getClinicSchedules(int clinicId) async {
    return apiManager.getClinicSchedules(clinicId);
  }

  Future<List<dynamic>> getAllSchedules() async {
    return apiManager.getAllSchedules();
  }
}
