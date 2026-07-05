import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';
import 'package:graduationproject/data/api/api_manager.dart';

class BookAppointmentView extends StatefulWidget {
  final DoctorModel doctor;
  final ClinicModel clinic;
  final dynamic schedule;
  final int scheduleId;
  final PatientBookingCubit cubit;
  final double scale;

  const BookAppointmentView({
    super.key,
    required this.doctor,
    required this.clinic,
    required this.schedule,
    required this.scheduleId,
    required this.cubit,
    required this.scale,
  });

  @override
  State<BookAppointmentView> createState() => _BookAppointmentViewState();
}

class _BookAppointmentViewState extends State<BookAppointmentView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  String _paymentMethod = 'Pay Online';
  bool _isSuccess = false;

  double s(double v) => v * widget.scale;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // Deterministic fallbacks
  final List<String> _avatarPool = const [
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=250',
  ];

  String _getDoctorAvatar() {
    if (widget.doctor.imageUrl != null && widget.doctor.imageUrl!.isNotEmpty) {
      return widget.doctor.imageUrl!;
    }
    final index = widget.doctor.id % _avatarPool.length;
    return _avatarPool[index];
  }

  void _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

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
    final rawSchedDur = widget.schedule['appointmentDuration'] ?? widget.schedule['AppointmentDuration'];
    final schedDur = rawSchedDur != null ? parseMinutes(rawSchedDur.toString()) : 0;
    if (schedDur > 0) {
      durationMinutes = schedDur;
    } else {
      final clinicDur = parseMinutes(widget.clinic.appointmentDuration);
      if (clinicDur > 0) {
        durationMinutes = clinicDur;
      }
    }

    await widget.cubit.bookPatientAppointment(
      scheduleId: widget.scheduleId,
      reasonForVisit: _reasonController.text.trim(),
      paymentMethod: _paymentMethod,
      doctorId: widget.doctor.id,
      clinicId: widget.clinic.id,
      clinicName: widget.clinic.name,
      doctorName: widget.doctor.fullName,
      dayOfWeek: (widget.schedule['dayOfWeek'] ?? widget.schedule['day'])?.toString(),
      startTime: widget.schedule['startTime']?.toString(),
      endTime: widget.schedule['endTime']?.toString(),
      appointmentDuration: durationMinutes.toString(),
      price: double.tryParse(widget.clinic.consultationPrice.toString()),
    );
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
            'Book Appointment',
            style: GoogleFonts.cairo(
              fontSize: s(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<PatientBookingCubit, PatientBookingState>(
            listener: (context, state) {
              if (state is PatientBookingBookingSuccess) {
                setState(() => _isSuccess = true);
                // Rating popup removed here
                // الدفع مش فوري — ينتظر المريض قبول الدكتور أولاً
              } else if (state is PatientBookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.cairo()),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is PatientBookingBooking;

              if (_isSuccess) {
                return _buildSuccessView();
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Doctor Info Summary Row
                      _buildDoctorSummary(),
                      SizedBox(height: s(16)),

                      // Clinic & Schedule Info Card
                      _buildClinicScheduleSummary(),
                      SizedBox(height: s(16)),

                      // Inputs Card
                      _buildFormCard(isLoading),
                      SizedBox(height: s(24)),

                      // Action Buttons
                      _buildActions(isLoading),
                      SizedBox(height: s(20)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorSummary() {
    final avatar = _getDoctorAvatar();
    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(20)),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: s(32),
            backgroundImage: NetworkImage(avatar),
            backgroundColor: const Color(0xFFEFF6FF),
          ),
          SizedBox(width: s(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.fullName,
                  style: GoogleFonts.cairo(
                    fontSize: s(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: s(4)),
                Text(
                  widget.doctor.departmentName ?? 'Medical Specialist',
                  style: GoogleFonts.cairo(
                    fontSize: s(13),
                    color: const Color(0xFF137FEC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.doctor.age != null) ...[
                  SizedBox(height: s(4)),
                  Text(
                    'Age: ${widget.doctor.age}',
                    style: GoogleFonts.cairo(
                      fontSize: s(12),
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                if (widget.doctor.aboutMe != null && widget.doctor.aboutMe!.isNotEmpty) ...[
                  SizedBox(height: s(6)),
                  Text(
                    widget.doctor.aboutMe!,
                    style: GoogleFonts.cairo(
                      fontSize: s(12),
                      color: const Color(0xFF475569),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicScheduleSummary() {
    final day = (widget.schedule['dayOfWeek'] ?? widget.schedule['day'] ?? 'Unknown Day').toString();
    final start = (widget.schedule['startTime'] ?? 'N/A').toString();
    
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

    // Check if endTime is provided by backend
    final backendEndTime = widget.schedule['endTime'] ?? widget.schedule['EndTime'];
    
    // Parse duration: prefer schedule duration if valid (>0), fallback to clinic duration
    int durationMinutes = 0;
    final rawSchedDur = widget.schedule['appointmentDuration'] ?? widget.schedule['AppointmentDuration'];
    final schedDur = rawSchedDur != null ? parseMinutes(rawSchedDur.toString()) : 0;
    if (schedDur > 0) {
      durationMinutes = schedDur;
    } else {
      final clinicDur = parseMinutes(widget.clinic.appointmentDuration);
      if (clinicDur > 0) {
        durationMinutes = clinicDur;
      }
    }

    // Helper to calculate minutes from time string (e.g., "09:00:00" -> 540)
    int? timeToMinutes(String time) {
      try {
        final cleanTime = time.trim().split(' ')[0];
        final parts = cleanTime.split(':');
        if (parts.isEmpty) return null;
        int hour = int.tryParse(parts[0]) ?? 0;
        int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
        return hour * 60 + minute;
      } catch (_) {
        return null;
      }
    }
    
    // Calculate End Time (Start Time + Duration)
    String calculateEndTime(String startTime, int durationMins) {
      try {
        final startMins = timeToMinutes(startTime) ?? (9 * 60);
        final totalMinutes = startMins + durationMins;
        final endHour = (totalMinutes ~/ 60) % 24;
        final endMinute = totalMinutes % 60;
        final endHourStr = endHour.toString().padLeft(2, '0');
        final endMinuteStr = endMinute.toString().padLeft(2, '0');
        if (startTime.trim().split(' ')[0].split(':').length > 2) {
          return '$endHourStr:$endMinuteStr:00';
        }
        return '$endHourStr:$endMinuteStr';
      } catch (_) {
        return startTime;
      }
    }

    String end;
    if (backendEndTime != null && backendEndTime.toString().isNotEmpty) {
      end = backendEndTime.toString();
      // If we have both start and end from backend but duration is still 0, calculate it
      if (durationMinutes == 0) {
        final startMins = timeToMinutes(start);
        final endMins = timeToMinutes(end);
        if (startMins != null && endMins != null) {
          durationMinutes = endMins - startMins;
          if (durationMinutes < 0) durationMinutes += 24 * 60; // Handle over-midnight
        }
      }
    } else {
      if (durationMinutes == 0) durationMinutes = 30; // ultimate fallback
      end = calculateEndTime(start, durationMinutes);
    }
    
    final duration = durationMinutes > 0 ? '$durationMinutes minutes' : 'N/A';

    final displayStart = _formatTime(start);
    final displayEnd = _formatTime(end);
    
    // Parse Notes
    String notes = '';
    final schedNotes = (widget.schedule['notes'] ?? widget.schedule['nots'] ?? '').toString().trim();
    if (schedNotes.isNotEmpty && schedNotes != 'No notes added') {
      notes = schedNotes;
    } else {
      final clinicNotes = (widget.clinic.nots).trim();
      if (clinicNotes.isNotEmpty && clinicNotes != 'No notes added') {
        notes = clinicNotes;
      }
    }

    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(20)),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_hospital_rounded, size: s(20), color: const Color(0xFF10B981)),
              SizedBox(width: s(8)),
              Expanded(
                child: Text(
                  widget.clinic.name,
                  style: GoogleFonts.cairo(
                    fontSize: s(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s(8)),
          _buildItemRow(Icons.location_on_rounded, 'Address: ${widget.clinic.address}'),
          _buildItemRow(Icons.phone_rounded, 'Phone: ${widget.clinic.phoneNumber}'),
          _buildItemRow(Icons.payments_rounded, 'Consultation Price: \$${widget.clinic.consultationPrice}.00 EGP', textColor: const Color(0xFFEA580C)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildItemRow(Icons.calendar_today_rounded, 'Day: $day'),
          _buildItemRow(Icons.access_time_rounded, 'Time Range: $displayStart - $displayEnd'),
          _buildItemRow(Icons.hourglass_bottom_rounded, 'Duration: $duration'),
          if (notes.isNotEmpty) ...[
            _buildItemRow(Icons.info_outline_rounded, 'Notes: $notes'),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(IconData icon, String value, {Color? textColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(3)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: s(16), color: const Color(0xFF64748B)),
          SizedBox(width: s(8)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: s(13),
                fontWeight: FontWeight.w500,
                color: textColor ?? const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isLoading) {
    return Container(
      padding: EdgeInsets.all(s(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(s(20)),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reason for Visit',
            style: GoogleFonts.cairo(
              fontSize: s(14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: s(8)),
          TextFormField(
            controller: _reasonController,
            maxLines: 4,
            maxLength: 500,
            enabled: !isLoading,
            style: GoogleFonts.cairo(fontSize: s(13), color: const Color(0xFF334155)),
            decoration: InputDecoration(
              hintText: 'e.g. headache, follow-up for diabetes',
              hintStyle: GoogleFonts.cairo(color: const Color(0xFF94A3B8)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(s(12)),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(s(12)),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(s(12)),
                borderSide: const BorderSide(color: Color(0xFF137FEC), width: 1.5),
              ),
              contentPadding: EdgeInsets.all(s(12)),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Reason for visit is required';
              }
              if (value.trim().length < 10) {
                return 'Reason must be at least 10 characters';
              }
              return null;
            },
          ),
          SizedBox(height: s(16)),
          Text(
            'Payment Method',
            style: GoogleFonts.cairo(
              fontSize: s(14),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: s(8)),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Pay Online', style: GoogleFonts.cairo(fontSize: s(13), fontWeight: FontWeight.w600)),
                  value: 'Pay Online',
                  groupValue: _paymentMethod,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _paymentMethod = value;
                            });
                          }
                        },
                  activeColor: const Color(0xFF137FEC),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Pay at Clinic', style: GoogleFonts.cairo(fontSize: s(13), fontWeight: FontWeight.w600)),
                  value: 'Pay at Clinic',
                  groupValue: _paymentMethod,
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _paymentMethod = value;
                            });
                          }
                        },
                  activeColor: const Color(0xFF137FEC),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
              padding: EdgeInsets.symmetric(vertical: s(14)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(s(12)),
              ),
            ),
            child: Text(
              'Back to Schedules',
              style: GoogleFonts.cairo(
                fontSize: s(14),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(width: s(12)),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : _submitBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFCBD5E1),
              padding: EdgeInsets.symmetric(vertical: s(14)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(s(12)),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: s(20),
                    height: s(20),
                    child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    'Confirm Booking',
                    style: GoogleFonts.cairo(
                      fontSize: s(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    final day = (widget.schedule['dayOfWeek'] ?? widget.schedule['day'] ?? '').toString();
    final start = _formatTime((widget.schedule['startTime'] ?? '').toString());
    final end = _formatTime((widget.schedule['endTime'] ?? '').toString());
    final isOnlinePayment = _paymentMethod == 'Pay Online';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(s(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: s(72),
            height: s(72),
            decoration: const BoxDecoration(
              color: Color(0xFFECFDF5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              size: s(48),
            ),
          ),
          SizedBox(height: s(20)),
          Text(
            'Booking Request Sent!',
            style: GoogleFonts.cairo(
              fontSize: s(22),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: s(8)),
          Text(
            'Your appointment request has been sent to the doctor for approval.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: s(14),
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: s(24)),

          // Summary card
          Container(
            padding: EdgeInsets.all(s(16)),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(s(16)),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildSummaryItem('Doctor', 'Dr. ${widget.doctor.fullName}', isBold: true),
                _buildSummaryItem('Specialty', widget.doctor.departmentName ?? 'Medical Specialist'),
                _buildSummaryItem('Clinic', widget.clinic.name, isBold: true),
                _buildSummaryItem('Address', widget.clinic.address),
                _buildSummaryItem('Day', day),
                _buildSummaryItem('Time', '$start - $end'),
                _buildSummaryItem('Payment', _paymentMethod),
                _buildSummaryItem('Price', '\$${widget.clinic.consultationPrice}.00 EGP', textColor: const Color(0xFFEA580C)),
              ],
            ),
          ),
          SizedBox(height: s(20)),

          // ─── رسالة انتظار الدكتور إذا اختار Pay Online ───────────────
          if (isOnlinePayment) ...[
            Container(
              padding: EdgeInsets.all(s(14)),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(s(14)),
                border: Border.all(color: const Color(0xFF93C5FD)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF2563EB), size: 22),
                  SizedBox(width: s(10)),
                  Expanded(
                    child: Text(
                      'Once the doctor approves your booking, you will receive a notification to complete your payment.',
                      style: GoogleFonts.cairo(
                        fontSize: s(13),
                        color: const Color(0xFF1D4ED8),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: s(10)),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isOnlinePayment
                    ? const Color(0xFFF1F5F9)
                    : const Color(0xFF137FEC),
                foregroundColor: isOnlinePayment
                    ? const Color(0xFF475569)
                    : Colors.white,
                padding: EdgeInsets.symmetric(vertical: s(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(12)),
                ),
              ),
              child: Text(
                isOnlinePayment ? 'Pay Later — Go to Home' : 'Go back to Home',
                style: GoogleFonts.cairo(
                  fontSize: s(14),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.cairo(
              fontSize: s(13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.cairo(
                fontSize: s(13),
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: textColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, int doctorId) {
    int rating = 0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s(20))),
              title: Text(
                'Rate Doctor',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How was your experience with Dr. ${widget.doctor.fullName}?',
                    style: GoogleFonts.cairo(
                      fontSize: s(14),
                      color: const Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: s(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: const Color(0xFFEAB308),
                          size: s(32),
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: s(16)),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a comment (optional)...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(s(12)),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Skip',
                    style: GoogleFonts.cairo(color: const Color(0xFF64748B)),
                  ),
                ),
                ElevatedButton(
                  onPressed: (rating == 0 || isSubmitting)
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          final api = await ApiManager.create();
                          final errorMessage = await api.addDoctorReview(
                            doctorId: doctorId,
                            rating: rating,
                            comment: commentController.text,
                          );
                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  errorMessage == null ? 'Review submitted!' : errorMessage,
                                  style: GoogleFonts.cairo(),
                                ),
                                backgroundColor: errorMessage == null ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF137FEC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(s(8))),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: s(16),
                          height: s(16),
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Submit', style: GoogleFonts.cairo(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatTime(String timeStr) {
    try {
      final cleanTime = timeStr.trim().split(' ')[0];
      final parts = cleanTime.split(':');
      if (parts.isEmpty) return timeStr;
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
      final amPm = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final displayHourStr = displayHour.toString().padLeft(2, '0');
      final displayMinStr = minute.toString().padLeft(2, '0');
      return '$displayHourStr:$displayMinStr $amPm';
    } catch (_) {
      return timeStr;
    }
  }
}
