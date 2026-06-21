abstract class PatientScheduleState {}

class PatientScheduleInitial extends PatientScheduleState {}

class PatientScheduleLoading extends PatientScheduleState {}

class PatientScheduleSuccess extends PatientScheduleState {
  final List<dynamic> appointments;

  PatientScheduleSuccess(this.appointments);

  /// Upcoming: مواعيد المستقبل (bookingDate >= today)
  List<dynamic> get upcomingAppointments {
    final now = DateTime.now();
    return appointments.where((a) {
      try {
        final dateStr = a['bookingDate'] ??
            a['appointmentDate'] ??
            a['date'] ??
            a['scheduledDate'] ?? '';
        if (dateStr.isEmpty) return true; // show if date unknown
        final date = DateTime.tryParse(dateStr.toString());
        return date != null && !date.isBefore(DateTime(now.year, now.month, now.day));
      } catch (_) {
        return true;
      }
    }).toList();
  }

  /// Past: مواعيد قديمة (bookingDate < today)
  List<dynamic> get pastAppointments {
    final now = DateTime.now();
    return appointments.where((a) {
      try {
        final dateStr = a['bookingDate'] ??
            a['appointmentDate'] ??
            a['date'] ??
            a['scheduledDate'] ?? '';
        if (dateStr.isEmpty) return false;
        final date = DateTime.tryParse(dateStr.toString());
        return date != null && date.isBefore(DateTime(now.year, now.month, now.day));
      } catch (_) {
        return false;
      }
    }).toList();
  }
}

class PatientScheduleError extends PatientScheduleState {
  final String message;
  PatientScheduleError(this.message);
}
