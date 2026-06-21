import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/cliniceSchedual.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';

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

    final result = await widget.cubit.bookPatientAppointment(
      scheduleId: widget.scheduleId,
      reasonForVisit: _reasonController.text.trim(),
      paymentMethod: _paymentMethod,
    );

    if (result) {
      setState(() {
        _isSuccess = true;
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to book appointment. Please try again.',
              style: GoogleFonts.lexend(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
            style: GoogleFonts.lexend(
              fontSize: s(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<PatientBookingCubit, PatientBookingState>(
            listener: (context, state) {
              if (state is PatientBookingError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message, style: GoogleFonts.lexend()),
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
                  style: GoogleFonts.lexend(
                    fontSize: s(16),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: s(4)),
                Text(
                  widget.doctor.departmentName ?? 'Medical Specialist',
                  style: GoogleFonts.lexend(
                    fontSize: s(13),
                    color: const Color(0xFF137FEC),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.doctor.age != null) ...[
                  SizedBox(height: s(4)),
                  Text(
                    'Age: ${widget.doctor.age}',
                    style: GoogleFonts.lexend(
                      fontSize: s(12),
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
                if (widget.doctor.aboutMe != null && widget.doctor.aboutMe!.isNotEmpty) ...[
                  SizedBox(height: s(6)),
                  Text(
                    widget.doctor.aboutMe!,
                    style: GoogleFonts.lexend(
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
    final end = (widget.schedule['endTime'] ?? 'N/A').toString();
    
    // Parse duration
    String duration = '30 minutes';
    if (widget.schedule['appointmentDuration'] != null) {
      final rawDur = widget.schedule['appointmentDuration'].toString();
      duration = rawDur.contains(':') ? '${rawDur.split(":")[1]} minutes' : '$rawDur minutes';
    } else if (widget.clinic.appointmentDuration.isNotEmpty) {
      duration = widget.clinic.appointmentDuration;
    }
    
    final notes = (widget.schedule['notes'] ?? widget.schedule['nots'] ?? widget.clinic.nots ?? '').toString();

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
                  style: GoogleFonts.lexend(
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
          _buildItemRow(Icons.access_time_rounded, 'Time Range: $start - $end'),
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
              style: GoogleFonts.lexend(
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
            style: GoogleFonts.lexend(
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
            style: GoogleFonts.lexend(fontSize: s(13), color: const Color(0xFF334155)),
            decoration: InputDecoration(
              hintText: 'e.g. headache, follow-up for diabetes',
              hintStyle: GoogleFonts.lexend(color: const Color(0xFF94A3B8)),
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
            style: GoogleFonts.lexend(
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
                  title: Text('Pay Online', style: GoogleFonts.lexend(fontSize: s(13), fontWeight: FontWeight.w600)),
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
                  title: Text('Pay at Clinic', style: GoogleFonts.lexend(fontSize: s(13), fontWeight: FontWeight.w600)),
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
              style: GoogleFonts.lexend(
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
                    style: GoogleFonts.lexend(
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
    final start = (widget.schedule['startTime'] ?? '').toString();
    final end = (widget.schedule['endTime'] ?? '').toString();

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
            'Booking Confirmed!',
            style: GoogleFonts.lexend(
              fontSize: s(22),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: s(8)),
          Text(
            'Your appointment has been successfully scheduled.',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
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
          SizedBox(height: s(32)),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Navigate back to Patient Home Dashboard View
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137FEC),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: s(14)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(s(12)),
                ),
              ),
              child: Text(
                'Go back to Home',
                style: GoogleFonts.lexend(
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
            style: GoogleFonts.lexend(
              fontSize: s(13),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.lexend(
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
}
