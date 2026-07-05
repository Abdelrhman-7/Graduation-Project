import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';
import 'book_appointment_view.dart';

class ClinicSchedulesView extends StatefulWidget {
  final DoctorModel doctor;
  final ClinicModel clinic;
  final PatientBookingCubit cubit;
  final double scale;

  const ClinicSchedulesView({
    super.key,
    required this.doctor,
    required this.clinic,
    required this.cubit,
    required this.scale,
  });

  @override
  State<ClinicSchedulesView> createState() => _ClinicSchedulesViewState();
}

class _ClinicSchedulesViewState extends State<ClinicSchedulesView> {
  String _selectedDay = 'All Days';
  bool _isSortedByDay = false;

  final List<String> _daysOfWeek = [
    'All Days',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  double s(double v) => v * widget.scale;

  @override
  void initState() {
    super.initState();
    final clinicId = widget.clinic.id;
    if (clinicId != null && clinicId > 0) {
      widget.cubit.fetchClinicSchedules(clinicId, widget.doctor.id);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedDay = 'All Days';
      _isSortedByDay = false;
    });
  }

  // To order days for sorting
  int _dayOrder(String day) {
    final index = _daysOfWeek.indexOf(day);
    return index == -1 ? 99 : index;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.cubit,
      child: Scaffold(
        backgroundColor: const Color(0xFFFEF2F2),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: const Color(0xFF0F172A), size: s(24)),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Schedule List',
            style: GoogleFonts.cairo(
              fontSize: s(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: s(12)),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.local_hospital_rounded, size: s(16), color: const Color(0xFF475569)),
                  label: Text(
                    'Back to Clinics',
                    style: GoogleFonts.cairo(
                      fontSize: s(12),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE2E8F0),
                    padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(s(8)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildFilters(),
              Expanded(
                child: BlocBuilder<PatientBookingCubit, PatientBookingState>(
                  builder: (context, state) {
                    if (state is PatientBookingLoading) {
                      return _buildLoadingState();
                    } else if (state is PatientBookingError) {
                      return _buildErrorState(state.message);
                    } else if (state is PatientBookingSchedulesSuccess) {
                      var schedules = state.schedules.where((sched) {
                        if (_selectedDay == 'All Days') return true;
                        final day = (sched['dayOfWeek'] ?? sched['day'] ?? '').toString().toLowerCase();
                        return day == _selectedDay.toLowerCase();
                      }).toList();

                      if (_isSortedByDay) {
                        schedules.sort((a, b) {
                          final dayA = (a['dayOfWeek'] ?? a['day'] ?? '').toString();
                          final dayB = (b['dayOfWeek'] ?? b['day'] ?? '').toString();
                          return _dayOrder(dayA).compareTo(_dayOrder(dayB));
                        });
                      }

                      if (schedules.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
                        physics: const BouncingScrollPhysics(),
                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          return _buildScheduleCard(schedules[index]);
                        },
                      );
                    }
                    if (widget.clinic.id == null || widget.clinic.id == 0) {
                      return _buildErrorState('Invalid clinic. Please go back and try again.');
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
      child: Column(
        children: [
          Row(
            children: [
              // Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: s(12)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(s(12)),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDay,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: GoogleFonts.cairo(
                        fontSize: s(13),
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedDay = newValue;
                          });
                        }
                      },
                      items: _daysOfWeek
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: s(10)),
              OutlinedButton(
                onPressed: _resetFilters,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(12)),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: s(14), vertical: s(12)),
                ),
                child: Text('Reset', style: GoogleFonts.cairo(fontSize: s(13), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: s(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort by:',
                style: GoogleFonts.cairo(
                  fontSize: s(13),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              ChoiceChip(
                label: Text(
                  'Day of Week',
                  style: GoogleFonts.cairo(
                    fontSize: s(12),
                    fontWeight: FontWeight.w600,
                    color: _isSortedByDay ? Colors.white : const Color(0xFF475569),
                  ),
                ),
                selected: _isSortedByDay,
                onSelected: (bool selected) {
                  setState(() {
                    _isSortedByDay = selected;
                  });
                },
                selectedColor: const Color(0xFF137FEC),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(8)),
                ),
                padding: EdgeInsets.symmetric(horizontal: s(8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(dynamic sched) {
    final day = (sched['dayOfWeek'] ?? sched['day'] ?? 'Unknown Day').toString();
    final start = (sched['startTime'] ?? 'N/A').toString();
    
    // Helper to parse minutes from any duration string format
    int parseMinutes(String val) {
      final cleaned = val.toLowerCase().trim();
      if (cleaned.contains(':')) {
        final parts = cleaned.split(':');
        if (parts.length >= 2) {
          final hours = int.tryParse(parts[0]) ?? 0;
          final minutes = int.tryParse(parts[1]) ?? 0;
          return (hours * 60) + minutes;
        }
      }
      final regExp = RegExp(r'\d+');
      final match = regExp.firstMatch(cleaned);
      if (match != null) {
        return int.tryParse(match.group(0)!) ?? 0;
      }
      return 0;
    }

    // Parse duration: prefer schedule duration if valid (>0), fallback to clinic duration
    int durationMinutes = 30;
    final rawSchedDur = sched['appointmentDuration'] ?? sched['AppointmentDuration'];
    final schedDur = rawSchedDur != null ? parseMinutes(rawSchedDur.toString()) : 0;
    if (schedDur > 0) {
      durationMinutes = schedDur;
    } else {
      final clinicDur = parseMinutes(widget.clinic.appointmentDuration);
      if (clinicDur > 0) {
        durationMinutes = clinicDur;
      }
    }
    final duration = '$durationMinutes minutes';
    
    // Calculate End Time (Start Time + Duration)
    String calculateEndTime(String startTime, int durationMins) {
      try {
        final cleanTime = startTime.trim().split(' ')[0];
        final parts = cleanTime.split(':');
        if (parts.isEmpty) return startTime;
        
        int hour = int.tryParse(parts[0]) ?? 9;
        int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        
        final totalMinutes = hour * 60 + minute + durationMins;
        final endHour = (totalMinutes ~/ 60) % 24;
        final endMinute = totalMinutes % 60;
        
        final endHourStr = endHour.toString().padLeft(2, '0');
        final endMinuteStr = endMinute.toString().padLeft(2, '0');
        
        if (parts.length > 2) {
          return '$endHourStr:$endMinuteStr:00';
        }
        return '$endHourStr:$endMinuteStr';
      } catch (_) {
        return startTime;
      }
    }

    final end = calculateEndTime(start, durationMinutes);
    
    // Parse Notes
    String notes = '';
    final schedNotes = (sched['notes'] ?? sched['nots'] ?? '').toString().trim();
    if (schedNotes.isNotEmpty && schedNotes != 'No notes added') {
      notes = schedNotes;
    } else {
      final clinicNotes = (widget.clinic.nots).trim();
      if (clinicNotes.isNotEmpty && clinicNotes != 'No notes added') {
        notes = clinicNotes;
      }
    }

    final scheduleId = sched['scheduleId'] is int
        ? sched['scheduleId'] as int
        : sched['id'] is int
            ? sched['id'] as int
            : int.tryParse(sched['scheduleId']?.toString() ?? '') ??
                int.tryParse(sched['id']?.toString() ?? '') ??
                0;

    return Container(
      margin: EdgeInsets.only(bottom: s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(20)),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(s(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: s(22), color: const Color(0xFF137FEC)),
                SizedBox(width: s(10)),
                Text(
                  day,
                  style: GoogleFonts.cairo(
                    fontSize: s(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            SizedBox(height: s(12)),
            _buildDetailRow(Icons.access_time_rounded, 'Start: $start'),
            _buildDetailRow(Icons.access_time_filled_rounded, 'End: $end'),
            _buildDetailRow(Icons.hourglass_bottom_rounded, 'Duration: $duration'),
            if (notes.isNotEmpty) ...[
              SizedBox(height: s(8)),
              Container(
                padding: EdgeInsets.all(s(10)),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(s(8)),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: s(16), color: const Color(0xFF64748B)),
                    SizedBox(width: s(8)),
                    Expanded(
                      child: Text(
                        notes,
                        style: GoogleFonts.cairo(
                          fontSize: s(12),
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: s(16)),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            SizedBox(height: s(12)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentView(
                        doctor: widget.doctor,
                        clinic: widget.clinic,
                        schedule: sched,
                        scheduleId: scheduleId,
                        cubit: widget.cubit,
                        scale: widget.scale,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.check_circle_outline_rounded, size: s(16), color: Colors.white),
                label: Text(
                  'Book Appointment',
                  style: GoogleFonts.cairo(
                    fontSize: s(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: s(12)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(s(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(3)),
      child: Row(
        children: [
          Icon(icon, size: s(16), color: const Color(0xFF64748B)),
          SizedBox(width: s(8)),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: s(13),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF137FEC),
            strokeWidth: 3,
          ),
          SizedBox(height: s(16)),
          Text(
            'Loading schedules...',
            style: GoogleFonts.cairo(
              fontSize: s(14),
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: const Color(0xFFEF4444), size: s(48)),
            SizedBox(height: s(16)),
            Text(
              'Failed to load schedules',
              style: GoogleFonts.cairo(
                fontSize: s(18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: s(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: s(14), color: const Color(0xFF64748B)),
            ),
            SizedBox(height: s(24)),
            ElevatedButton(
              onPressed: () {
                final clinicId = widget.clinic.id;
                if (clinicId != null && clinicId > 0) {
                  widget.cubit.fetchClinicSchedules(clinicId, widget.doctor.id);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137FEC),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(s(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_rounded, color: const Color(0xFF137FEC), size: s(48)),
            SizedBox(height: s(16)),
            Text(
              'No schedules found',
              style: GoogleFonts.cairo(
                fontSize: s(18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: s(8)),
            Text(
              'There are no working hours specified for this day/clinic.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: s(14), color: const Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}
