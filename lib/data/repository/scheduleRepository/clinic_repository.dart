import 'package:graduationproject/data/api/api_manager.dart';
import 'package:graduationproject/data/local/local_booking_store.dart';
import 'package:graduationproject/data/models/booking/booking_model.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/creatSchudel.dart';

class ClinicRepository {
  final ApiManager apiManager;

  ClinicRepository(this.apiManager);

  Future<bool> addClinic(ClinicModel clinic) async {
    await apiManager.chooseRole('Doctor');
    return apiManager.addClinic(clinic);
  }

  Future<List<ClinicModel>> getDoctorClinics() async {
    await apiManager.chooseRole('Doctor');
    return apiManager.getDoctorClinics();
  }

  Future<List<dynamic>> getClinicBookings(int clinicId) async {
    await apiManager.chooseRole('Doctor');
    final apiBookings = await apiManager.getClinicBookings(clinicId);
    if (apiBookings.isNotEmpty) return apiBookings;

    final local = await LocalBookingStore.instance.getForClinic(
      clinicId,
      pendingOnly: true,
    );
    return local.map((b) => b.toJson()).toList();
  }

  Future<bool> acceptDoctorBooking(
    int bookingId, {
    BookingModel? booking,
  }) async {
    await apiManager.chooseRole('Doctor');
    final apiOk = await apiManager.confirmDoctorAppointment(bookingId);
    if (booking != null) {
      await LocalBookingStore.instance.addBooking(
        booking.copyWith(status: 'Approved', notificationUnread: true),
      );
    } else {
      await LocalBookingStore.instance.updateStatus(bookingId, 'Approved');
    }
    return true; // Local store updated, treat as success even if API is down
  }

  Future<bool> rejectDoctorBooking(
    int bookingId, {
    BookingModel? booking,
  }) async {
    await apiManager.chooseRole('Doctor');
    final apiOk = await apiManager.cancelDoctorAppointment(bookingId);
    if (booking != null) {
      await LocalBookingStore.instance.addBooking(
        booking.copyWith(status: 'Rejected', notificationUnread: true),
      );
    } else {
      await LocalBookingStore.instance.updateStatus(bookingId, 'Rejected');
    }
    return true; // Local store updated, treat as success even if API is down
  }

  Future<bool> createSchedule(CreateScheduleModel schedule) async {
    await apiManager.chooseRole('Doctor');
    return apiManager.createSchedule(schedule);
  }

  Future<bool> editSchedule(editClinicModel clinic) async {
    await apiManager.chooseRole('Doctor');
    return apiManager.editSchedule(clinic);
  }

  Future<bool> deleteClinic(int id) async {
    await apiManager.chooseRole('Doctor');
    return apiManager.deleteClinic(id);
  }

  Future<bool> updateClinic(ClinicModel clinic) async {
    await apiManager.chooseRole('Doctor');
    return apiManager.updateClinic(clinic);
  }

  Future<bool> deleteSchedule(int scheduleId) async {
    await apiManager.chooseRole('Doctor');
    return apiManager.deleteSchedule(scheduleId);
  }

  Future<List<dynamic>> getClinicSchedules(int clinicId) async {
    return apiManager.getClinicSchedules(clinicId);
  }

  Future<List<dynamic>> getAllSchedules() async {
    return apiManager.getAllSchedules();
  }

  Future<bool> cancelDoctorAppointment(int bookingId) async {
    await LocalBookingStore.instance.updateStatus(bookingId, 'Cancelled');
    try {
      await apiManager.cancelDoctorAppointment(bookingId);
    } catch (e) {
      print('Doctor cancel API failed: $e');
    }
    return true;
  }
}
