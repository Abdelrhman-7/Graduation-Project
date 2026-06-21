import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';
import 'doctor_clinics_view.dart';

class DoctorProfileView extends StatefulWidget {
  final int doctorId;
  final PatientBookingCubit cubit;
  final double scale;

  const DoctorProfileView({
    super.key,
    required this.doctorId,
    required this.cubit,
    required this.scale,
  });

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  double s(double v) => v * widget.scale;

  @override
  void initState() {
    super.initState();
    widget.cubit.fetchDoctorDetails(widget.doctorId);
  }

  // Deterministic fallbacks
  final List<String> _avatarPool = const [
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1594824813573-246434de83fb?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&q=80&w=250',
    'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&q=80&w=250',
  ];

  String _getDoctorAvatar(DoctorModel doctor) {
    if (doctor.imageUrl != null && doctor.imageUrl!.isNotEmpty) {
      return doctor.imageUrl!;
    }
    final index = doctor.id % _avatarPool.length;
    return _avatarPool[index];
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
            'Doctor Details',
            style: GoogleFonts.lexend(
              fontSize: s(18),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<PatientBookingCubit, PatientBookingState>(
            builder: (context, state) {
              if (state is PatientBookingLoading) {
                return _buildLoadingState();
              } else if (state is PatientBookingError) {
                return _buildErrorState(state.message);
              } else if (state is PatientBookingDoctorDetailsSuccess) {
                final doctor = state.doctor;
                final avatar = _getDoctorAvatar(doctor);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Centered avatar
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: EdgeInsets.all(s(4)),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF137FEC), Color(0xFF06B6D4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: s(50),
                                backgroundImage: NetworkImage(avatar),
                                backgroundColor: const Color(0xFFEFF6FF),
                              ),
                            ),
                            Container(
                              width: s(20),
                              height: s(20),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: s(12)),
                      // Doctor Name
                      Text(
                        doctor.fullName,
                        style: GoogleFonts.lexend(
                          fontSize: s(22),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: s(16)),

                      // Main details card
                      Container(
                        padding: EdgeInsets.all(s(20)),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.email_outlined, 'Email', doctor.email ?? 'N/A'),
                            _buildDivider(),
                            _buildInfoRow(Icons.phone_outlined, 'Phone Number', doctor.phoneNumber ?? 'N/A'),
                            _buildDivider(),
                            _buildInfoRow(Icons.person_outline_rounded, 'Gender', doctor.gender ?? 'N/A'),
                            _buildDivider(),
                            _buildInfoRow(Icons.cake_outlined, 'Age', doctor.age?.toString() ?? 'N/A'),
                            _buildDivider(),
                            _buildInfoRow(Icons.medical_services_outlined, 'Department', doctor.departmentName ?? 'General Department'),
                            _buildDivider(),
                            _buildInfoRow(
                              Icons.description_outlined,
                              'Department Description',
                              doctor.departmentDescription ?? 'Provides professional medical consulting and healthcare treatment.',
                            ),
                            _buildDivider(),
                            _buildInfoRow(Icons.info_outline_rounded, 'About Me', doctor.aboutMe ?? 'No introduction provided yet.'),
                          ],
                        ),
                      ),
                      SizedBox(height: s(24)),

                      // Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF475569),
                                side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                                padding: EdgeInsets.symmetric(vertical: s(14)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(s(12)),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.arrow_back_rounded, size: s(18)),
                                  SizedBox(width: s(8)),
                                  Text(
                                    'Back to List',
                                    style: GoogleFonts.lexend(
                                      fontSize: s(14),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: s(12)),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(s(12)),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF137FEC), Color(0xFF06B6D4)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF137FEC).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DoctorClinicsView(
                                        doctor: doctor,
                                        cubit: widget.cubit,
                                        scale: widget.scale,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(vertical: s(14)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(s(12)),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'View Clinics',
                                      style: GoogleFonts.lexend(
                                        fontSize: s(14),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(width: s(8)),
                                    Icon(Icons.arrow_forward_rounded, size: s(18)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: s(20)),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: s(20), color: const Color(0xFF137FEC)),
          SizedBox(width: s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lexend(
                    fontSize: s(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: s(2)),
                Text(
                  value,
                  style: GoogleFonts.lexend(
                    fontSize: s(14),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: s(10)),
      child: const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
            'Loading profile...',
            style: GoogleFonts.lexend(
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
              'Failed to load details',
              style: GoogleFonts.lexend(
                fontSize: s(18),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: s(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.lexend(fontSize: s(14), color: const Color(0xFF64748B)),
            ),
            SizedBox(height: s(24)),
            ElevatedButton(
              onPressed: () {
                widget.cubit.fetchDoctorDetails(widget.doctorId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137FEC),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: s(24), vertical: s(12)),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
