abstract class PatientScheduleState {}

class PatientScheduleInitial extends PatientScheduleState {}

class PatientScheduleLoading extends PatientScheduleState {}

class PatientScheduleSuccess extends PatientScheduleState {
  final List<dynamic> appointments;

  PatientScheduleSuccess(this.appointments);

  static String _statusOf(dynamic a) =>
      (a['status'] ?? '').toString().toLowerCase();

  static String _payStatusOf(dynamic a) =>
      (a['paymentStatus'] ?? a['PaymentStatus'] ?? '').toString().toLowerCase();

  /// Upcoming: pending + approved (not cancelled/rejected/completed/paid)
  List<dynamic> get upcomingAppointments {
    return appointments.where((a) {
      final status = _statusOf(a);
      final payStatus = _payStatusOf(a);
      if (status.contains('cancel')) return false;
      if (status.contains('reject')) return false;
      if (status.contains('denied')) return false;
      if (status.contains('complet')) return false;
      if (status.contains('paid')) return false;
      if (payStatus.contains('paid')) return false;
      if (payStatus.contains('complet')) return false;
      if (payStatus.contains('success')) return false;
      return true; // pending, approved, accept, empty → upcoming
    }).toList();
  }

  /// Past: cancelled, rejected, completed, denied, paid
  List<dynamic> get pastAppointments {
    return appointments.where((a) {
      final status = _statusOf(a);
      final payStatus = _payStatusOf(a);
      return status.contains('cancel') ||
          status.contains('reject') ||
          status.contains('denied') ||
          status.contains('complet') ||
          status.contains('paid') ||
          payStatus.contains('paid') ||
          payStatus.contains('complet') ||
          payStatus.contains('success');
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
