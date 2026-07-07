abstract class PatientScheduleState {}

class PatientScheduleInitial extends PatientScheduleState {}

class PatientScheduleLoading extends PatientScheduleState {}

class PatientScheduleSuccess extends PatientScheduleState {
  final List<dynamic> appointments;

  PatientScheduleSuccess(this.appointments);

  static String _statusOf(dynamic a) =>
      (a['status'] ?? '').toString().toLowerCase();

  /// Upcoming: pending + approved (not cancelled/rejected/completed)
  List<dynamic> get upcomingAppointments {
    return appointments.where((a) {
      final status = _statusOf(a);
      if (status.contains('cancel')) return false;
      if (status.contains('reject')) return false;
      if (status.contains('denied')) return false;
      if (status.contains('complet')) return false;
      return true; // pending, approved, accept, paid, empty → upcoming
    }).toList();
  }

  /// Past: cancelled, rejected, completed, denied
  List<dynamic> get pastAppointments {
    return appointments.where((a) {
      final status = _statusOf(a);
      return status.contains('cancel') ||
          status.contains('reject') ||
          status.contains('denied') ||
          status.contains('complet');
    }).toList();
  }
}

/// Emitted while a processing request is in-flight (shows loading on the specific card)
class PatientScheduleProcessing extends PatientScheduleSuccess {
  final int processingBookingId;
  PatientScheduleProcessing(super.appointments, this.processingBookingId);
}

/// Emitted if processing fails
class PatientScheduleProcessError extends PatientScheduleSuccess {
  final String message;
  PatientScheduleProcessError(this.message, List<dynamic> appointments)
      : super(appointments);
}

class PatientScheduleError extends PatientScheduleState {
  final String message;
  PatientScheduleError(this.message);
}
