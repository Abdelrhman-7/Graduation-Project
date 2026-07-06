import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduationproject/data/models/schudule/doctorModel.dart';
import 'package:graduationproject/data/api/api_manager.dart';
import '../cubit/patient_booking_cubit.dart';
import '../cubit/patient_booking_state.dart';
import 'doctor_clinics_view.dart';

class DoctorProfileView extends StatefulWidget {
  final int doctorId;
  final PatientBookingCubit cubit;
  final double scale;
  final DoctorModel? initialDoctor;

  const DoctorProfileView({
    super.key,
    required this.doctorId,
    required this.cubit,
    required this.scale,
    this.initialDoctor,
  });

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  double s(double v) => v * widget.scale;
  
  String _averageRating = "0.0";
  String _reviewCount = "0";
  List<dynamic> _reviewsList = [];

  @override
  void initState() {
    super.initState();
    widget.cubit.fetchDoctorDetails(
      widget.doctorId,
      fallback: widget.initialDoctor,
    );
    _fetchRating();
  }

  Future<void> _fetchRating() async {
    try {
      final api = await ApiManager.create();
      final reviews = await api.getPatientDoctorReviews(widget.doctorId);
      if (reviews.isNotEmpty && mounted) {
        double total = 0;
        int count = 0;
        for (var review in reviews) {
          final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
          if (rating > 0) {
            total += rating;
            count++;
          }
        }
        if (count > 0) {
          setState(() {
            _averageRating = (total / count).toStringAsFixed(1);
            _reviewCount = count.toString();
            _reviewsList = reviews;
          });
        }
      }
    } catch (e) {
      print('Error fetching rating: $e');
    }
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
            onPressed: () {
              widget.cubit.restoreDoctorsList();
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text(
            'Doctor Details',
            style: GoogleFonts.cairo(
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
                        style: GoogleFonts.cairo(
                          fontSize: s(22),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_reviewCount != "0") ...[
                        SizedBox(height: s(8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFEAB308),
                              size: 20,
                            ),
                            SizedBox(width: s(4)),
                            Text(
                              '$_averageRating/5',
                              style: GoogleFonts.cairo(
                                fontSize: s(14),
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            SizedBox(width: s(4)),
                            Text(
                              '($_reviewCount reviews)',
                              style: GoogleFonts.cairo(
                                fontSize: s(14),
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
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

                      // Actions
                      Container(
                        width: double.infinity,
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
                            ).then((_) {
                              widget.cubit.restoreDoctorDetails(doctor);
                            });
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
                                style: GoogleFonts.cairo(
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
                      SizedBox(height: s(24)),
                      if (_reviewsList.isNotEmpty) ...[
                        Text(
                          'Patient Reviews',
                          style: GoogleFonts.cairo(
                            fontSize: s(18),
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: s(12)),
                        ..._reviewsList.map((review) {
                          final rating = (review['rating'] as num?)?.toDouble() ?? 0.0;
                          final comment = (review['comment'] ?? '').toString();
                          final patientName = (review['patientName'] ?? 'Anonymous Patient').toString();
                          return Container(
                            margin: EdgeInsets.only(bottom: s(12)),
                            padding: EdgeInsets.all(s(16)),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(s(16)),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: s(16),
                                      backgroundColor: const Color(0xFFEFF6FF),
                                      child: Icon(Icons.person, color: const Color(0xFF137FEC), size: s(18)),
                                    ),
                                    SizedBox(width: s(8)),
                                    Expanded(
                                      child: Text(
                                        patientName,
                                        style: GoogleFonts.cairo(
                                          fontSize: s(14),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star_rounded, color: const Color(0xFFEAB308), size: s(16)),
                                        SizedBox(width: s(4)),
                                        Text(
                                          rating.toStringAsFixed(1),
                                          style: GoogleFonts.cairo(
                                            fontSize: s(14),
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (comment.isNotEmpty) ...[
                                  SizedBox(height: s(8)),
                                  Text(
                                    comment,
                                    style: GoogleFonts.cairo(
                                      fontSize: s(14),
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }),
                      ],
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
                  style: GoogleFonts.cairo(
                    fontSize: s(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                SizedBox(height: s(2)),
                Text(
                  value,
                  style: GoogleFonts.cairo(
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
              'Failed to load details',
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
                widget.cubit.fetchDoctorDetails(
                  widget.doctorId,
                  fallback: widget.initialDoctor,
                );
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
